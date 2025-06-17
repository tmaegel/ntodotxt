import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/todo_file/state/todo_file_state.dart';

void main() {
  group('TodoFileLoading', () {
    test('localPath with trailing /', () {
      TodoFileLoading state = TodoFileLoading(localPath: 'path/');
      expect(state.localPath, 'path/');
    });
    test('localPath without trailing /', () {
      TodoFileLoading state = TodoFileLoading(localPath: 'path');
      expect(state.localPath, 'path/');
    });
    test('remotePath with trailing /', () {
      TodoFileLoading state = TodoFileLoading(remotePath: 'path/');
      expect(state.remotePath, 'path/');
    });
    test('remotePath without trailing /', () {
      TodoFileLoading state = TodoFileLoading(remotePath: 'path');
      expect(state.remotePath, 'path/');
    });
    test('copyWith() with todoFilename', () {
      TodoFileLoading state = TodoFileLoading(
        todoFilename: 'todo.txt',
      );
      TodoFileLoading state2 = state.copyWith(todoFilename: 'todo2.txt');
      expect(state2.todoFilename, 'todo2.txt');
    });
    test('copyWith() with doneFilename', () {
      TodoFileLoading state = TodoFileLoading(
        doneFilename: 'done.txt',
      );
      TodoFileLoading state2 = state.copyWith(doneFilename: 'done2.txt');
      expect(state2.doneFilename, 'done2.txt');
    });
    test('copyWith() with localPath', () {
      TodoFileLoading state = TodoFileLoading(
        localPath: '/local',
      );
      TodoFileLoading state2 = state.copyWith(localPath: '/local2/');
      expect(state2.localPath, '/local2/');
    });
    test('copyWith() with remotePath', () {
      TodoFileLoading state = TodoFileLoading(
        remotePath: '/remote',
      );
      TodoFileLoading state2 = state.copyWith(remotePath: '/remote2/');
      expect(state2.remotePath, '/remote2/');
    });
    test('toString() without trailing /', () {
      TodoFileLoading state = TodoFileLoading(
        todoFilename: 'todo.txt',
        localPath: '/local',
        remotePath: '/remote',
      );
      expect('$state',
          'TodoFileLoading { localFile /local/todo.txt remoteFile: /remote/todo.txt }');
    });
    test('toString() with trailing /', () {
      TodoFileLoading state = TodoFileLoading(
        todoFilename: 'todo.txt',
        localPath: '/local/',
        remotePath: '/remote/',
      );
      expect('$state',
          'TodoFileLoading { localFile /local/todo.txt remoteFile: /remote/todo.txt }');
    });
    test('load()', () {
      TodoFileLoading state = TodoFileLoading();
      TodoFileLoading state2 = state.load();
      expect(state2, isA<TodoFileLoading>());
    });
    test('ready()', () {
      TodoFileLoading state = TodoFileLoading();
      TodoFileReady state2 = state.ready();
      expect(state2, isA<TodoFileReady>());
    });
    test('error()', () {
      TodoFileLoading state = TodoFileLoading();
      TodoFileError state2 = state.error(message: 'error');
      expect(state2, isA<TodoFileError>());
    });
  });

  group('TodoFileReady', () {
    test('localPath with trailing /', () {
      TodoFileReady state = TodoFileReady(localPath: 'path/');
      expect(state.localPath, 'path/');
    });
    test('localPath without trailing /', () {
      TodoFileReady state = TodoFileReady(localPath: 'path');
      expect(state.localPath, 'path/');
    });
    test('remotePath with trailing /', () {
      TodoFileReady state = TodoFileReady(remotePath: 'path/');
      expect(state.remotePath, 'path/');
    });
    test('remotePath without trailing /', () {
      TodoFileReady state = TodoFileReady(remotePath: 'path');
      expect(state.remotePath, 'path/');
    });
    test('copyWith() with todoFilename', () {
      TodoFileReady state = TodoFileReady(
        todoFilename: 'todo.txt',
      );
      TodoFileReady state2 = state.copyWith(todoFilename: 'todo2.txt');
      expect(state2.todoFilename, 'todo2.txt');
    });
    test('copyWith() with doneFilename', () {
      TodoFileReady state = TodoFileReady(
        doneFilename: 'done.txt',
      );
      TodoFileReady state2 = state.copyWith(doneFilename: 'done2.txt');
      expect(state2.doneFilename, 'done2.txt');
    });
    test('copyWith() with localPath', () {
      TodoFileReady state = TodoFileReady(
        localPath: '/local',
      );
      TodoFileReady state2 = state.copyWith(localPath: '/local2/');
      expect(state2.localPath, '/local2/');
    });
    test('copyWith() with remotePath', () {
      TodoFileReady state = TodoFileReady(
        remotePath: '/remote',
      );
      TodoFileReady state2 = state.copyWith(remotePath: '/remote2/');
      expect(state2.remotePath, '/remote2/');
    });
    test('toString() without trailing /', () {
      TodoFileReady state = TodoFileReady(
        todoFilename: 'todo.txt',
        localPath: '/local',
        remotePath: '/remote',
      );
      expect('$state',
          'TodoFileReady { localFile /local/todo.txt remoteFile: /remote/todo.txt }');
    });
    test('toString() with trailing /', () {
      TodoFileReady state = TodoFileReady(
        todoFilename: 'todo.txt',
        localPath: '/local/',
        remotePath: '/remote/',
      );
      expect('$state',
          'TodoFileReady { localFile /local/todo.txt remoteFile: /remote/todo.txt }');
    });
    test('load()', () {
      TodoFileReady state = TodoFileReady();
      TodoFileLoading state2 = state.load();
      expect(state2, isA<TodoFileLoading>());
    });
    test('ready()', () {
      TodoFileReady state = TodoFileReady();
      TodoFileReady state2 = state.ready();
      expect(state2, isA<TodoFileReady>());
    });
    test('error()', () {
      TodoFileReady state = TodoFileReady();
      TodoFileError state2 = state.error(message: 'error');
      expect(state2, isA<TodoFileError>());
    });
  });

  group('TodoFileError', () {
    test('localPath with trailing /', () {
      TodoFileError state = TodoFileError(localPath: 'path/', message: '');
      expect(state.localPath, 'path/');
    });
    test('localPath without trailing /', () {
      TodoFileError state = TodoFileError(localPath: 'path', message: '');
      expect(state.localPath, 'path/');
    });
    test('remotePath with trailing /', () {
      TodoFileError state = TodoFileError(remotePath: 'path/', message: '');
      expect(state.remotePath, 'path/');
    });
    test('remotePath without trailing /', () {
      TodoFileError state = TodoFileError(remotePath: 'path', message: '');
      expect(state.remotePath, 'path/');
    });
    test('copyWith() with todoFilename', () {
      TodoFileError state = TodoFileError(
        message: 'error',
        todoFilename: 'todo.txt',
      );
      TodoFileError state2 = state.copyWith(todoFilename: 'todo2.txt');
      expect(state2.todoFilename, 'todo2.txt');
    });
    test('copyWith() with doneFilename', () {
      TodoFileError state = TodoFileError(
        message: 'error',
        doneFilename: 'done.txt',
      );
      TodoFileError state2 = state.copyWith(doneFilename: 'done2.txt');
      expect(state2.doneFilename, 'done2.txt');
    });
    test('copyWith() with localPath', () {
      TodoFileError state = TodoFileError(
        message: 'error',
        localPath: '/local',
      );
      TodoFileError state2 = state.copyWith(localPath: '/local2/');
      expect(state2.localPath, '/local2/');
    });
    test('copyWith() with remotePath', () {
      TodoFileError state = TodoFileError(
        message: 'error',
        remotePath: '/remote',
      );
      TodoFileError state2 = state.copyWith(remotePath: '/remote2/');
      expect(state2.remotePath, '/remote2/');
    });
    test('toString() without trailing /', () {
      TodoFileError state = TodoFileError(
        message: 'error',
        todoFilename: 'todo.txt',
        localPath: '/local',
        remotePath: '/remote',
      );
      expect('$state',
          'TodoFileError { message error localFile /local/todo.txt remoteFile: /remote/todo.txt }');
    });
    test('toString() with trailing /', () {
      TodoFileError state = TodoFileError(
        message: 'error',
        todoFilename: 'todo.txt',
        localPath: '/local/',
        remotePath: '/remote/',
      );
      expect('$state',
          'TodoFileError { message error localFile /local/todo.txt remoteFile: /remote/todo.txt }');
    });
    test('load()', () {
      TodoFileError state = TodoFileError(message: 'error');
      TodoFileLoading state2 = state.load();
      expect(state2, isA<TodoFileLoading>());
    });
    test('ready()', () {
      TodoFileError state = TodoFileError(message: 'error');
      TodoFileReady state2 = state.ready();
      expect(state2, isA<TodoFileReady>());
    });
    test('error()', () {
      TodoFileError state = TodoFileError(message: 'error');
      TodoFileError state2 = state.error(message: 'error');
      expect(state2, isA<TodoFileError>());
    });
  });
}
