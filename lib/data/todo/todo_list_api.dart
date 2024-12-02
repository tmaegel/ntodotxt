import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ntodotxt/client/webdav_client.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/main.dart' show log;
import 'package:rxdart/subjects.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class LocalFile {
  final File file;

  LocalFile(this.file);

  String get path => file.uri.pathSegments.last;

  Future<DateTime> get lastModified async => await file.lastModified();
}

class WebDAVFile {
  final String path;
  final WebDAVClient client;

  WebDAVFile(this.path, this.client);

  Future<webdav.File> get file async => await client.getFile(filename: path);

  Future<DateTime?> get lastModified async => (await file).mTime;
}

abstract class TodoListApi {
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
  final LocalFile localFile;

  LocalTodoListApi(this.localFile) {
    if (localFile.file.existsSync() == false) {
      log.fine('File ${localFile.path} does not exist. Creating.');
      localFile.file.createSync();
    } else {
      log.fine('File ${localFile.path} exists already.');
    }
    updateList(readSync()); // Read synchrone here.
  }

  LocalTodoListApi.fromString({
    required String localFilePath,
  }) : this(LocalFile(File(localFilePath)));

  LocalTodoListApi.fromFile({
    required File localFile,
  }) : this(LocalFile(localFile));

  /// Provides a [Stream] of all todos.
  // A special Streamcontroller that captures the latest item that has been
  // added to the controller, and emits that as the first item to any new listener.
  final BehaviorSubject<List<Todo>> controller =
      BehaviorSubject<List<Todo>>.seeded(const []);

  List<Todo> get _todoList => controller.value;

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
    return _read(await localFile.file.readAsLines());
  }

  List<Todo> readSync() {
    log.info('Sync-read todos from file');
    return _read(localFile.file.readAsLinesSync());
  }

  Future<void> write(String content) async {
    log.info('Sync-write todos to file');
    await localFile.file.writeAsString(content);
  }

  @override
  Stream<List<Todo>> getTodoList() => controller.asBroadcastStream();

  @override
  Future<void> initSource() async {
    log.info('Initialize todo file');
    if (await localFile.file.exists() == false) {
      await localFile.file.create();
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
  final WebDAVFile remoteFile;
  final WebDAVClient client;

  WebDAVTodoListApi(
    super.localFile,
    this.remoteFile,
    this.client,
  );

  WebDAVTodoListApi.fromString({
    required String localFilePath,
    required String remoteFilePath,
    required WebDAVClient client,
  }) : this(
          LocalFile(File(localFilePath)),
          WebDAVFile(remoteFilePath, client),
          client,
        );

  @override
  Future<void> initSource() async {
    await super.initSource();
    await client.ping();
    if (await client.fileExists(filename: remoteFile.path)) {
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
    return await client.download(filename: remoteFile.path);
  }

  Future<void> uploadToSource() async {
    log.info('Upload todos to server');
    await client.upload(
      filename: remoteFile.path,
      content: _todoList.join(Platform.lineTerminator),
    );
  }
}
