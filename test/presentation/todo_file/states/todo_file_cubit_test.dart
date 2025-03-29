import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/settings/fake_setting_controller.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';

void main() {
  group('TodoFileCubit', () {
    test('Default values', () {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      expect(cubit.state, isA<TodoFileLoading>());
      expect(cubit.state.todoFilename, 'todo.txt');
      expect(cubit.state.doneFilename, 'done.txt');
      expect(cubit.state.localPath, '/');
      expect(cubit.state.remotePath, '/');
    });
  });
  group('saveLocalPath', () {
    test('Null value', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveLocalPath(null);
      expect(cubit.state.localPath, '/');
    });
    test('Without trailing /', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveLocalPath('/local');
      expect(cubit.state.localPath, '/local/');
    });
    test('With trailing /', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveLocalPath('/local/');
      expect(cubit.state.localPath, '/local/');
    });
  });
  group('saveRemotePath', () {
    test('Null value', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveRemotePath(null);
      expect(cubit.state.remotePath, '/');
    });
    test('Without trailing /', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveRemotePath('/remote');
      expect(cubit.state.remotePath, '/remote/');
    });
    test('With trailing /', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveRemotePath('/remote/');
      expect(cubit.state.remotePath, '/remote/');
    });
  });
  group('saveLocalFilename', () {
    test('Null value', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveLocalFilename(null);
      expect(cubit.state.todoFilename, 'todo.txt');
    });
    test('With value', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
      );
      await cubit.saveLocalFilename('todo2.txt');
      expect(cubit.state.todoFilename, 'todo2.txt');
    });
  });
  group('resetToDefaults', () {
    test('Reset to defaults', () async {
      final TodoFileCubit cubit = TodoFileCubit(
        repository: SettingRepository(FakeSettingController()),
        todoFilename: 'todo2.txt',
        doneFilename: 'done2.txt',
        localPath: '/local',
        remotePath: '/remote',
      );
      await cubit.resetToDefaults();
      expect(cubit.state, isA<TodoFileLoading>());
      expect(cubit.state.todoFilename, 'todo.txt');
      expect(cubit.state.doneFilename, 'done.txt');
      expect(cubit.state.localPath, '/');
      expect(cubit.state.remotePath, '/');
    });
  });
  group('resetTodoFileSettings', () {});
}
