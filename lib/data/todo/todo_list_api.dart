import 'dart:async';
import 'dart:io';

import 'package:ntodotxt/client/webdav_client.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:ntodotxt/main.dart' show log;
import 'package:rxdart/subjects.dart';
import 'package:watcher/watcher.dart';

abstract class TodoListApi {
  final File todoFile;

  const TodoListApi({required this.todoFile});

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList();

  /// Watch for changes on source.
  Stream<WatchEvent> watchSource();

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
  LocalTodoListApi({required super.todoFile}) {
    // Use synchronize versions here.
    if (todoFile.existsSync() == false) {
      log.fine('File ${todoFile.path} does not exist. Creating.');
      todoFile.createSync();
    } else {
      log.fine('File ${todoFile.path} exists already.');
    }
    updateList(_fromFileSync()); // Read synchrone here.
  }

  /// Provides a [Stream] of all todos.
  // A special Streamcontroller that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final controller = BehaviorSubject<List<Todo>>.seeded(const []);

  List<Todo> get _todoList => controller.value;

  void updateList(List<Todo> todoList) {
    log.fine('Update todo list');
    _dispatch(todoList);
  }

  void addToList(Todo value) {
    log.fine('Add todo to todo list');
    List<Todo> todoList = [..._todoList, value];
    _dispatch(todoList);
  }

  void _dispatch(List<Todo> todoList) {
    controller.add(todoList);
    log.finest(
      'Updated todos ${[for (var todo in _todoList) todo.toDebugString()]}',
    );
  }

  void dispose() {
    controller.close();
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

  List<Todo> _fromFileSync() {
    final lines = todoFile.readAsLinesSync();
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
    log.fine('Watch file ${todoFile.path} for changes');
    FileWatcher watcher = FileWatcher(todoFile.path);
    return watcher.events;
  }

  @override
  Future<void> readFromSource() async {
    log.info('Reading todos from file');
    updateList(await _fromFile());
  }

  @override
  Future<void> writeToSource() async {
    log.info('Writing todos to file');
    // Using the sync version here.
    // Otherwise it produces multiple MODIFY events.
    todoFile.writeAsStringSync(_todoList.join(Platform.lineTerminator));
  }

  @override
  void saveTodo(Todo todo) {
    log.info('Saving todo ${todo.toDebugString()}');
    List<Todo> todoList = [..._todoList];
    updateList(_save(todoList, todo));
  }

  @override
  void saveMultipleTodos(List<Todo> todos) {
    log.info('Saving todos $todos');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _save(todoList, todo);
    }
    updateList(todoList);
  }

  @override
  void deleteTodo(Todo todo) {
    log.info('Deleting todo ${todo.toDebugString()}');
    List<Todo> todoList = [..._todoList];
    updateList(_delete(todoList, todo));
  }

  @override
  void deleteMultipleTodos(List<Todo> todos) {
    log.info('Deleting todos $todos');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _delete(todoList, todo);
    }
    updateList(todoList);
  }
}

class WebDAVTodoListApi extends LocalTodoListApi {
  final WebDAVClient client;

  WebDAVTodoListApi._({
    required File todoFile,
    required this.client,
  }) : super(todoFile: todoFile);

  factory WebDAVTodoListApi({
    required File todoFile,
    required String server,
    required String baseUrl,
    required String username,
    required String password,
  }) {
    late WebDAVClient client;
    final RegExp exp =
        RegExp(r"(?<schema>^(http|https)):\/\/(?<host>\w+):(?<port>\d+)$");
    final RegExpMatch? match = exp.firstMatch(server);
    if (match != null) {
      String schema = match.namedGroup('schema')!;
      String host = match.namedGroup('host')!;
      int port = int.parse(match.namedGroup('port')!);
      client = WebDAVClient(
        schema: schema,
        host: host,
        port: port,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );
    } else {
      throw const FormatException('Invalid server foramt.');
    }

    return WebDAVTodoListApi._(
      todoFile: todoFile,
      client: client,
    );
  }

  // Future<void> readFromSource() async {}

  @override
  Future<void> writeToSource() async {
    await super.writeToSource();
    await uploadToSource();
  }

  @override
  Future<void> downloadFromSource() async {
    log.info('Downloading todos from server');
    String content = await client.download();
  }

  Future<void> uploadToSource() async {
    log.info('Uploading todos to server');
    await client.upload(
      content: _todoList.join(Platform.lineTerminator),
    );
  }
}
