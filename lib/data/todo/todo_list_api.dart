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
  Todo getTodo(int? id);

  /// Saves a [todo].
  /// If a [todo] with the same id already exists, it will be replaced.
  Todo saveTodo(int? id, Todo todo);

  /// Deletes the `todo` with the given id.
  /// If no `todo` with the given id exists, a [TodoNotFound] error is thrown.
  void deleteTodo(int? id);
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

  @override
  Todo getTodo(int? id) {
    final List<Todo> todoList = [..._streamController.value];
    int index = todoList.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      throw TodoNotFound(id: id);
    }
    return todoList[index];
  }

  @override
  Todo saveTodo(int? id, Todo todo) {
    final List<Todo> todoList = [..._streamController.value];
    if (id == null) {
      todo = todo.copyWith(id: newId); // Overwrite todo with id.
      todoList.add(todo);
    } else {
      int index = todoList.indexWhere((todo) => todo.id == id);
      if (index == -1) {
        throw TodoNotFound(id: id);
      } else {
        todoList[index] = todo;
      }
    }
    _streamController.add(todoList);

    return todo;
  }

  @override
  void deleteTodo(int? id) {
    final List<Todo> todoList = [..._streamController.value];
    todoList.removeWhere((todo) => todo.id == id);
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
