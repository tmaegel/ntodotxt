import 'dart:async';
import 'dart:io';

import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

abstract class TodoListApi {
  const TodoListApi();

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList();

  /// Read [todoList] from source.
  Future<void> readFromFile();

  /// Write [todoList] to source.
  Future<void> writeToFile();

  /// Refresh (re-read) [todoList] from source.
  Future<void> syncTodoList();

  /// Saves a [todo].
  /// If a [todo] with the same id already exists, it will be replaced.
  /// If the id of [todo] is null, it will be created.
  void saveTodo(Todo todo);

  /// Saves multiple [todos] at once.
  void saveMultipleTodos(List<Todo> todos);

  /// Deletes the given [todo].
  /// If the [todo] not exists, a [TodoNotFound] error is thrown.
  void deleteTodo(Todo todo);

  /// Deletes multiple [todos] at once.
  void deleteMultipleTodos(List<Todo> todos);
}

class LocalStorageTodoListApi extends TodoListApi {
  static const String fileName = "todo.txt";

  /// Provides a [Stream] of all todos.
  // A special StreamController that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final _streamController = BehaviorSubject<List<Todo>>.seeded(const []);

  LocalStorageTodoListApi(List<Todo> todoList) {
    _streamController.add(todoList);
  }

  // Factory to read the todo list from list of strings.
  factory LocalStorageTodoListApi.fromList(List<String> rawTodoList) =>
      LocalStorageTodoListApi(_fromList(rawTodoList));

  // Factory function to async read the todo list from file.
  static Future<LocalStorageTodoListApi> fromFile() async =>
      LocalStorageTodoListApi(await _fromFile());

  static Future<List<Todo>> _fromFile() async {
    final file = await localFile;
    if (await file.exists() == false) {
      await file.create();
    }
    final lines = await file.readAsLines();
    return _fromList(lines);
  }

  static List<Todo> _fromList(List<String> rawTodoList) {
    // Index the todo objecte to get a unique id.
    rawTodoList.sort();
    return [
      for (var i = 0; i < rawTodoList.length; i++)
        Todo.fromString(id: i, value: rawTodoList[i])
    ];
  }

  static Future<String> get localPath async {
    final directory = await getApplicationSupportDirectory();

    return directory.path;
  }

  static Future<File> get localFile async {
    final directory = await localPath;

    return File('$directory${Platform.pathSeparator}$fileName');
  }

  int get newId {
    final List<Todo> todoList = [..._streamController.value];
    int maxId = 0;
    for (var todo in todoList) {
      if (todo.id != null) {
        if (todo.id! > maxId) maxId = todo.id!;
      }
    }

    return (maxId + 1);
  }

  List<Todo> _save(List<Todo> todoList, Todo todo) {
    if (todo.id == null) {
      todo = todo.copyWith(id: newId); // Overwrite todo with id.
      todoList.add(todo);
    } else {
      int index = todoList.indexWhere((t) => t.id == todo.id);
      if (index == -1) {
        throw TodoNotFound(id: todo.id);
      } else {
        // Call copyWith() to force validation logic.
        todoList[index] = todo.copyWith();
      }
    }

    return todoList;
  }

  List<Todo> _delete(List<Todo> todoList, Todo todo) {
    todoList.removeWhere((t) => t.id == todo.id);
    return todoList;
  }

  @override
  Stream<List<Todo>> getTodoList() => _streamController.asBroadcastStream();

  @override
  Future<void> readFromFile() async {
    _streamController.add(await _fromFile());
  }

  @override
  Future<void> writeToFile() async {
    final file = await localFile;
    final List<Todo> todoList = [..._streamController.value];
    await file.writeAsString(
      todoList.join(Platform.lineTerminator),
      flush: true,
    );
  }

  @override
  Future<void> syncTodoList() async {
    await writeToFile();
    await readFromFile();
  }

  @override
  void saveTodo(Todo todo) {
    List<Todo> todoList = [..._streamController.value];
    _streamController.add(_save(todoList, todo));
  }

  @override
  void saveMultipleTodos(List<Todo> todos) {
    List<Todo> todoList = [..._streamController.value];
    for (var todo in todos) {
      todoList = _save(todoList, todo);
    }
    _streamController.add(todoList);
  }

  @override
  void deleteTodo(Todo todo) {
    final List<Todo> todoList = [..._streamController.value];
    _streamController.add(_delete(todoList, todo));
  }

  @override
  void deleteMultipleTodos(List<Todo> todos) {
    List<Todo> todoList = [..._streamController.value];
    for (var todo in todos) {
      todoList = _delete(todoList, todo);
    }
    _streamController.add(todoList);
  }
}
