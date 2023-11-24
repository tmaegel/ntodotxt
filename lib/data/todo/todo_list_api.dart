import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

abstract class TodoListApi {
  const TodoListApi();

  /// Initialize api. Not needed for testing.
  Future<void> init({File? file});

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList();

  /// Read [todoList] from source.
  Future<void> readFromSource();

  /// Write [todoList] to source.
  Future<void> writeToSource();

  /// Saves a [todo].
  /// If a [todo] with the same id already exists, it will be replaced.
  /// If the id of [todo] is null, it will be created.
  Future<void> saveTodo(Todo todo);

  /// Saves multiple [todos] at once.
  Future<void> saveMultipleTodos(List<Todo> todos);

  /// Deletes the given [todo].
  /// If the [todo] not exists, a [TodoNotFound] error is thrown.
  Future<void> deleteTodo(Todo todo);

  /// Deletes multiple [todos] at once.
  Future<void> deleteMultipleTodos(List<Todo> todos);
}

class LocalTodoListApi extends TodoListApi {
  static const String filename = "todo.txt";
  late final File todoFile;

  LocalTodoListApi();

  /// Provides a [Stream] of all todos.
  // A special Streamcontroller that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final controller = BehaviorSubject<List<Todo>>.seeded(const []);

  List<Todo> get _todoList => controller.value;

  void updateList(List<Todo> todoList) {
    _dispatch(todoList);
  }

  void addToList(Todo value) {
    List<Todo> todoList = [..._todoList, value];
    _dispatch(todoList);
  }

  void _dispatch(List<Todo> todoList) {
    controller.add(todoList);
    debugPrint(
      'Updated todos ${[for (var todo in _todoList) todo.toDebugString()]}',
    );
  }

  void dispose() {
    controller.close();
  }

  @override
  Future<void> init({File? file}) async {
    debugPrint('Initializing');
    if (file == null) {
      // Initialize real file in user directory.
      final directory = await getApplicationSupportDirectory();
      final String directoryPath = directory.path;
      todoFile = File('$directoryPath${Platform.pathSeparator}$filename');
    } else {
      todoFile = file;
    }
    if (await todoFile.exists() == false) {
      await todoFile.create();
    }
    await readFromSource();
  }

  Future<List<Todo>> _fromFile() async {
    final lines = await todoFile.readAsLines();
    // Index the todo objecte to get a unique id.
    lines.sort();
    return [
      for (var i = 0; i < lines.length; i++)
        Todo.fromString(id: i, value: lines[i])
    ];
  }

  int get newId {
    int maxId = -1; // If list is empty the newId should 0.
    for (var todo in _todoList) {
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
  Stream<List<Todo>> getTodoList() => controller.asBroadcastStream();

  @override
  Future<void> readFromSource() async {
    debugPrint('Reading todos from file');
    updateList(await _fromFile());
  }

  @override
  Future<void> writeToSource() async {
    debugPrint('Writing todos to file');
    await todoFile.writeAsString(
      _todoList.join(Platform.lineTerminator),
      flush: true,
    );
  }

  @override
  Future<void> saveTodo(Todo todo) async {
    debugPrint('Saving todo ${todo.toDebugString()}');
    List<Todo> todoList = [..._todoList];
    updateList(_save(todoList, todo));
    await writeToSource(); // Write changes to the source.
  }

  @override
  Future<void> saveMultipleTodos(List<Todo> todos) async {
    debugPrint('Saving todos $todos');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _save(todoList, todo);
    }
    updateList(todoList);
    await writeToSource(); // Write changes to the source.
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    debugPrint('Deleting todo ${todo.toDebugString()}');
    List<Todo> todoList = [..._todoList];
    updateList(_delete(todoList, todo));
    await writeToSource(); // Write changes to the source.
  }

  @override
  Future<void> deleteMultipleTodos(List<Todo> todos) async {
    debugPrint('Deleting todos $todos');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _delete(todoList, todo);
    }
    updateList(todoList);
    await writeToSource(); // Write changes to the source.
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
  Future<void> init({File? file}) {
    // @todo: Initial loading todo.txt from webdav here.
    return super.init(file: file);
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
