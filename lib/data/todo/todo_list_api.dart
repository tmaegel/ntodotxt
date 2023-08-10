import 'dart:async';
import 'dart:io';

import 'package:ntodotxt/constants/placeholder.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

abstract class TodoListApi {
  const TodoListApi();

  /// Provides a [Stream] of all todos.
  Stream<List<Todo>> getTodoList();

  /// Read [todoList]
  Future<List<Todo>> readTodoList();

  /// Write [todoList]
  // void writeTodoList(List<Todo> todoList);

  /// Get a single [todo] by index.
  Todo getTodo(int index);

  /// Saves a [todo].
  /// If a [todo] with the same index already exists, it will be replaced.
  void saveTodo(int? index, Todo todo);

  /// Deletes the `todo` with the given index.
  /// If no `todo` with the given id exists, a [TodoNotFoundException] error is thrown.
  void deleteTodo(int index);

  List<String> getAllPriorities();

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
    return [for (var todo in rawTodoList) Todo.fromString(todo)];
  }

  Future<List<Todo>> _fromFile(String fileName) async {
    return await readTodoList();
  }

  @override
  Stream<List<Todo>> getTodoList() => _streamController.asBroadcastStream();

  @override
  Future<List<Todo>> readTodoList() async {
    final List<Todo> todoList = [];
    final file = await localFile;
    final lines = file.readAsLinesSync();
    for (var line in lines) {
      todoList.add(Todo.fromString(line));
    }

    return todoList;
  }

  // @override
  // void writeTodoList(List<Todo> todoList) async {
  //   final file = await localFile;
  //   file.writeAsStringSync(rawTodoList.join('\n'));
  // }

  @override
  Todo getTodo(int index) {
    final todoList = [..._streamController.value];
    if (index > todoList.length) {
      throw TodoNotFoundException();
    }
    return todoList[index];
  }

  @override
  void saveTodo(int? index, Todo todo) {
    final todoList = [..._streamController.value];
    if (index != null && index > todoList.length) {
      throw TodoNotFoundException();
    }
    if (index == null) {
      debugPrint("Adding todo");
      todoList.add(todo);
    } else {
      debugPrint("Updating todo with index $index");
      todoList[index] = todo;
    }
    _streamController.add(todoList);
  }

  @override
  void deleteTodo(int index) {
    final todoList = [..._streamController.value];
    if (index > todoList.length) {
      throw TodoNotFoundException();
    }
    debugPrint("Deleting todo with index $index");
    todoList.removeAt(index);
    _streamController.add(todoList);
  }

  /// Returns a list of all priorities of all todos.
  @override
  List<String> getAllPriorities() {
    List<String> priorities = [];
    for (var todo in _streamController.value) {
      if (todo.priority != null) {
        if (!priorities.contains(todo.priority)) {
          priorities.add(todo.priority!);
        }
      }
    }
    return priorities.toSet().toList();
  }

  /// Returns a list with all projects of all todos.
  @override
  List<String> getAllProjects() {
    List<String> projects = [];
    for (var todo in _streamController.value) {
      projects = projects + todo.projects;
    }
    return projects.toSet().toList();
  }

  /// Returns a list with all contexts of all todos.
  @override
  List<String> getAllContexts() {
    List<String> contexts = [];
    for (var todo in _streamController.value) {
      contexts = contexts + todo.contexts;
    }
    return contexts.toSet().toList();
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
