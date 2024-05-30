import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ntodotxt/client/webdav_client.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/main.dart' show log;
import 'package:rxdart/subjects.dart';

abstract class TodoListApi {
  final File localTodoFile;

  const TodoListApi({required this.localTodoFile});

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList();

  Future<void> initSource();

  /// Read [todoList] from source.
  Future<void> readFromSource();

  /// Write [todoList] to source.
  Future<void> writeToSource();

  bool existsTodo(Todo todo);

  /// Saves a [todo].
  /// If a [todo] with [id] already exists, it will be replaced.
  /// If the [todo] with [id] already exists it will be updated/merged.
  void saveTodo(Todo todo);

  /// Saves multiple [todos] by [id] at once.
  void saveMultipleTodos(List<Todo> todos);

  /// Deletes the given [todo] by [id].
  void deleteTodo(Todo todo);

  /// Deletes multiple [todos] by [id] at once.
  void deleteMultipleTodos(List<Todo> todos);
}

class LocalTodoListApi extends TodoListApi {
  LocalTodoListApi({
    required super.localTodoFile,
  }) {
    // Use synchronize versions here.
    if (localTodoFile.existsSync() == false) {
      log.fine('File ${localTodoFile.path} does not exist. Creating.');
      localTodoFile.createSync();
    } else {
      log.fine('File ${localTodoFile.path} exists already.');
    }
    updateList(readSync()); // Read synchrone here.
  }

  /// Provides a [Stream] of all todos.
  // A special Streamcontroller that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final BehaviorSubject<List<Todo>> controller =
      BehaviorSubject<List<Todo>>.seeded(const []);

  List<Todo> get _todoList => controller.value;

  String get filename => localTodoFile.uri.pathSegments.last;

  void updateList(List<Todo> todoList) {
    // Update only if list does'nt match to prevent weird state changes.
    if (const ListEquality().equals(_todoList, todoList) == false) {
      log.fine('Update todo list.');
      _dispatch(todoList);
    } else {
      log.fine('Skip update todo list. List matches with the previous one.');
    }
  }

  void _dispatch(List<Todo> todoList) {
    controller.add(todoList);
    log.finest(
      'Updated todos ${[for (var todo in _todoList) todo]}',
    );
  }

  void dispose() {
    controller.close();
  }

  List<Todo> _read(List<String> rawTodoList) {
    return [
      for (var t in rawTodoList)
        if (t.isNotEmpty) Todo.fromString(value: t)
    ];
  }

  Future<List<Todo>> read() async {
    log.info('Async-read todos from file');
    return _read(await localTodoFile.readAsLines());
  }

  List<Todo> readSync() {
    log.info('Sync-read todos from file');
    return _read(localTodoFile.readAsLinesSync());
  }

  Future<void> write(String content) async {
    log.info('Sync-write todos to file');
    await localTodoFile.writeAsString(content);
  }

  @override
  Stream<List<Todo>> getTodoList() => controller.asBroadcastStream();

  @override
  Future<void> initSource() async {
    log.info('Initialize todo file');
    if (await localTodoFile.exists() == false) {
      await localTodoFile.create();
    }
  }

  @override
  Future<void> readFromSource() async => updateList(await read());

  @override
  Future<void> writeToSource() async => write(
        _todoList.join(Platform.lineTerminator),
      );

  @override
  bool existsTodo(Todo todo) =>
      _todoList.indexWhere((t) => t.id == todo.id) == -1 ? false : true;

  List<Todo> _save(List<Todo> todoList, Todo todo) {
    int index = todoList.indexWhere((t) => t.id == todo.id);
    if (index == -1) {
      // If not exist save the todo.
      log.info('Create new todo');
      todoList.add(todo.copyWith());
    } else {
      // If exist update todo and merge changes only.
      log.info('Update existing todo');
      todoList[index] = todo.copyMerge(todoList[index]);
    }

    return todoList;
  }

  @override
  void saveTodo(Todo todo) {
    log.info('Save todo ${todo.id}');
    List<Todo> todoList = [..._todoList];
    updateList(_save(todoList, todo));
  }

  @override
  void saveMultipleTodos(List<Todo> todos) {
    log.info('Save todos ${[for (var t in todos) t.id]}');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _save(todoList, todo);
    }
    updateList(todoList);
  }

  List<Todo> _delete(List<Todo> todoList, Todo todo) {
    todoList.removeWhere((t) => t.id == todo.id);
    return todoList;
  }

  @override
  void deleteTodo(Todo todo) {
    log.info('Delete todo ${todo.id}');
    List<Todo> todoList = [..._todoList];
    updateList(_delete(todoList, todo));
  }

  @override
  void deleteMultipleTodos(List<Todo> todos) {
    log.info('Delete todos ${[for (var t in todos) t.id]}');
    List<Todo> todoList = [..._todoList];
    for (var todo in todos) {
      todoList = _delete(todoList, todo);
    }
    updateList(todoList);
  }
}

class WebDAVTodoListApi extends LocalTodoListApi {
  final WebDAVClient client;
  final String remoteTodoFile;

  WebDAVTodoListApi._({
    required super.localTodoFile,
    required this.remoteTodoFile,
    required this.client,
  });

  factory WebDAVTodoListApi({
    required File localTodoFile,
    required String remoteTodoFile,
    required String server,
    required String baseUrl,
    required String username,
    required String password,
  }) {
    late WebDAVClient client;
    final RegExp exp = RegExp(
        r'(?<schema>^(http|https)):\/\/(?<host>[a-zA-Z0-9.-]+)(:(?<port>\d+)){0,1}$');
    final RegExpMatch? match = exp.firstMatch(server);
    if (match != null) {
      String schema = match.namedGroup('schema')!;
      String host = match.namedGroup('host')!;
      int? port = match.namedGroup('port') != null
          ? int.parse(match.namedGroup('port')!)
          : null;
      client = WebDAVClient(
        schema: schema,
        host: host,
        port: port,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );
    } else {
      throw const FormatException('Invalid server format');
    }

    return WebDAVTodoListApi._(
      localTodoFile: localTodoFile,
      remoteTodoFile: remoteTodoFile,
      client: client,
    );
  }

  @override
  Future<void> initSource() async {
    await super.initSource();
    await client.ping();
    if (await client.fileExists(filename: filename)) {
      await readFromSource();
    } else {
      await writeToSource();
    }
  }

  @override
  Future<void> readFromSource() async {
    await write(await downloadFromSource());
    await super.readFromSource();
  }

  @override
  Future<void> writeToSource() async {
    await super.writeToSource();
    await uploadToSource();
  }

  Future<String> downloadFromSource() async {
    log.info('Download todos from server');
    return await client.download(filename: remoteTodoFile);
  }

  Future<void> uploadToSource() async {
    log.info('Upload todos to server');
    await client.upload(
      filename: remoteTodoFile,
      content: _todoList.join(Platform.lineTerminator),
    );
  }
}
