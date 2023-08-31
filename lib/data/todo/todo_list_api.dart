import 'dart:async';
import 'dart:io';

import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:rxdart/subjects.dart';

abstract class TodoListApi {
  const TodoListApi();

  /// Provides a [Stream] of all todos.
  Stream<List<Todo>> getTodoList();

  /// Read [todoList]
  Future<List<Todo>> readTodoList();

  /// Write [todoList]
  // void writeTodoList(List<Todo> todoList);

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

  factory LocalStorageTodoListApi.fromList(List<String> rawTodoList) {
    return LocalStorageTodoListApi(_fromList(rawTodoList));
  }

  static List<Todo> _fromList(List<String> rawTodoList) {
    // Index the todo objecte to get a unique id.
    rawTodoList.sort();
    return [
      for (var i = 0; i < rawTodoList.length; i++)
        Todo.fromString(id: i, todoStr: rawTodoList[i])
    ];
  }

  Future<List<Todo>> _fromFile(String fileName) async {
    return await readTodoList();
  }

  @override
  Stream<List<Todo>> getTodoList() => _streamController.asBroadcastStream();

  @override
  Future<List<Todo>> readTodoList() async {
    final file = await localFile;
    final lines = file.readAsLinesSync();
    return _fromList(lines);
  }

  // @override
  // void writeTodoList(List<Todo> todoList) async {
  //   final file = await localFile;
  //   file.writeAsStringSync(rawTodoList.join('\n'));
  // }

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
        todoList[index] = todo;
      }
    }

    return todoList;
  }

  List<Todo> _delete(List<Todo> todoList, Todo todo) {
    todoList.removeWhere((t) => t.id == todo.id);
    return todoList;
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

  static Future<String> get localPath async {
    // Find the path to the documents directory.
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get localFile async {
    final directory = await localPath;

    return File('$directory/$fileName');
  }
}
