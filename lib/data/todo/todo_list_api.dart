import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:watcher/watcher.dart';

abstract class TodoListApi {
  const TodoListApi();

  /// Initialize api. Not needed for testing.
  Future<void> init({File? file});

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList();

  /// Watch for changes on source.
  Stream<WatchEvent> watchSource();

  /// Read [todoList] from source.
  Future<void> readFromSource();

  /// Write [todoList] to source.
  void writeToSource();

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
      debugPrint('Todo file ${todoFile.path} does not exist. Creating.');
      await todoFile.create();
    } else {
      debugPrint('Todo file ${todoFile.path} exists already.');
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
  Stream<WatchEvent> watchSource() {
    debugPrint('Watch for file changes on the file ${todoFile.path}');
    FileWatcher watcher = FileWatcher(todoFile.path);
    return watcher.events;
  }

  @override
  Future<void> readFromSource() async {
    debugPrint('Reading todos from file');
    updateList(await _fromFile());
  }

  @override
  void writeToSource() {
    debugPrint('Writing todos to file');
    // Using the sync version here.
    // Otherwise it produces multiple MODIFY events.
    todoFile.writeAsStringSync(_todoList.join(Platform.lineTerminator));
  }

  @override
  void saveTodo(Todo todo) {
    debugPrint('Saving todo ${todo.toDebugString()}');
    List<Todo> todoList = [..._todoList];
    updateList(_save(todoList, todo));
  }

  @override
  void saveMultipleTodos(List<Todo> todos) {
    debugPrint('Saving todos $todos');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _save(todoList, todo);
    }
    updateList(todoList);
  }

  @override
  void deleteTodo(Todo todo) {
    debugPrint('Deleting todo ${todo.toDebugString()}');
    List<Todo> todoList = [..._todoList];
    updateList(_delete(todoList, todo));
  }

  @override
  void deleteMultipleTodos(List<Todo> todos) {
    debugPrint('Deleting todos $todos');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _delete(todoList, todo);
    }
    updateList(todoList);
  }
}

class WebDAVTodoListApi extends LocalTodoListApi {
  final String server;
  final String username;
  final String password;

  WebDAVTodoListApi({
    required this.server,
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
  void writeToSource() {
    // @todo: Save to WebDAV here.
    return super.writeToSource();
  }
}
