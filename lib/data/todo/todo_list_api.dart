import 'dart:async';
import 'dart:io';

import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

abstract class TodoListApi {
  const TodoListApi();

  /// Initialize api. Not needed for testing.
  void init();

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList();

  /// Read [todoList] from source.
  Future<void> readFromSource();

  /// Write [todoList] to source.
  Future<void> writeToSource();

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

class LocalTodoListApi extends TodoListApi {
  static const String fileName = "todo.txt";

  /// Provides a [Stream] of all todos.
  // A special StreamController that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final _streamController = BehaviorSubject<List<Todo>>.seeded(const []);

  LocalTodoListApi();

  /// For testing purpose.
  LocalTodoListApi.fromList(List<Todo> todoList) {
    _streamController.add(todoList);
  }

  @override
  void init() async {
    _streamController.add(await _fromFile());
  }

  static Future<List<Todo>> _fromFile() async {
    final file = await localFile;
    if (await file.exists() == false) {
      await file.create();
    }
    final lines = await file.readAsLines();
    // Index the todo objecte to get a unique id.
    lines.sort();
    return [
      for (var i = 0; i < lines.length; i++)
        Todo.fromString(id: i, value: lines[i])
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
  Future<void> readFromSource() async {
    _streamController.add(await _fromFile());
  }

  @override
  Future<void> writeToSource() async {
    final file = await localFile;
    final List<Todo> todoList = [..._streamController.value];
    await file.writeAsString(
      todoList.join(Platform.lineTerminator),
      flush: true,
    );
  }

  @override
  void saveTodo(Todo todo) {
    List<Todo> todoList = [..._streamController.value];
    _streamController.add(_save(todoList, todo));
    writeToSource(); // Write changes to the source.
  }

  @override
  void saveMultipleTodos(List<Todo> todos) {
    List<Todo> todoList = [..._streamController.value];
    for (var todo in todos) {
      todoList = _save(todoList, todo);
    }
    _streamController.add(todoList);
    writeToSource(); // Write changes to the source.
  }

  @override
  void deleteTodo(Todo todo) {
    final List<Todo> todoList = [..._streamController.value];
    _streamController.add(_delete(todoList, todo));
    writeToSource(); // Write changes to the source.
  }

  @override
  void deleteMultipleTodos(List<Todo> todos) {
    List<Todo> todoList = [..._streamController.value];
    for (var todo in todos) {
      todoList = _delete(todoList, todo);
    }
    _streamController.add(todoList);
    writeToSource(); // Write changes to the source.
  }
}

class WebDAVTodoListApi extends LocalTodoListApi {
  final String serverURI;
  final String username;
  final String password;

  WebDAVTodoListApi({
    required this.serverURI,
    required this.username,
    required this.password,
  }) : super();

  @override
  void init() {
    // @todo: Initial loading todo.txt from webdav here.
    super.init();
  }

  @override
  Future<void> readFromSource() {
    // @todo: Load from WebDAV here.
    return super.readFromSource();
  }

  @override
  Future<void> writeToSource() {
    // @todo: Save to WebDAV here.
    return super.writeToSource();
  }
}
