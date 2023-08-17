import 'dart:async';
import 'dart:io';

import 'package:ntodotxt/constants/placeholder.dart';
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

  /// Get a single [todo] by id.
  Todo getTodo(int id);

  /// Saves a [todo].
  /// If a [todo] with the same id already exists, it will be replaced.
  void saveTodo(int? id, Todo todo);

  /// Deletes the `todo` with the given id.
  /// If no `todo` with the given id exists, a [TodoNotFoundException] error is thrown.
  void deleteTodo(int id);

  List<String?> getAllPriorities();

  List<String> getAllProjects();

  List<String> getAllContexts();
}

class LocalStorageTodoListApi extends TodoListApi {
  static const String fileName = "todo.txt";

  /// Provides a [Stream] of all todos.
  // A special StreamController that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final _streamController = BehaviorSubject<List<Todo>>.seeded(const []);

  LocalStorageTodoListApi() {
    _streamController.add(_fromList(rawTodoList));
  }

  List<Todo> _fromList(List<String> rawTodoList) {
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

  @override
  Todo getTodo(int id) {
    final todoList = [..._streamController.value];
    int index = todoList.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      throw TodoNotFoundException();
    }
    return todoList[index];
  }

  @override
  void saveTodo(int? id, Todo todo) {
    final todoList = [..._streamController.value];
    if (id == null) {
      todoList.add(todo);
    } else {
      int index = todoList.indexWhere((todo) => todo.id == id);
      if (index == -1) {
        throw TodoNotFoundException();
      } else {
        todoList[index] = todo;
      }
    }

    _streamController.add(todoList);
  }

  @override
  void deleteTodo(int id) {
    final todoList = [..._streamController.value];
    todoList.removeWhere((todo) => todo.id == id);
    _streamController.add(todoList);
  }

  /// Returns a list of all priorities of all todos.
  @override
  List<String?> getAllPriorities() {
    bool containsNullPriority = false;
    List<String?> priorities = [];
    for (var todo in _streamController.value) {
      if (todo.priority == null) {
        containsNullPriority = true;
      } else {
        if (!priorities.contains(todo.priority)) {
          priorities.add(todo.priority!);
        }
      }
    }
    priorities = priorities.toSet().toList();
    priorities.sort();
    // Consider the zero priorities
    if (containsNullPriority) {
      priorities.add(null);
    }
    return priorities;
  }

  /// Returns a list with all projects of all todos.
  @override
  List<String> getAllProjects() {
    List<String> projects = [];
    for (var todo in _streamController.value) {
      projects = projects + todo.projects;
    }
    projects = projects.toSet().toList();
    projects.sort();
    return projects;
  }

  /// Returns a list with all contexts of all todos.
  @override
  List<String> getAllContexts() {
    List<String> contexts = [];
    for (var todo in _streamController.value) {
      contexts = contexts + todo.contexts;
    }
    contexts = contexts.toSet().toList();
    contexts.sort();
    return contexts;
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
