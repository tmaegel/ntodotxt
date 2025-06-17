import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common/constants/app.dart';
import 'package:ntodotxt/main.dart' show log;
import 'package:ntodotxt/setting/model/setting_model.dart' show Setting;
import 'package:ntodotxt/setting/repository/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/todo_file/state/todo_file_state.dart';

class TodoFileCubit extends Cubit<TodoFileState> {
  final SettingRepository repository;

  TodoFileCubit({
    required this.repository,
    String todoFilename = defaultTodoFilename,
    String doneFilename = defaultDoneFilename,
    String localPath = defaultLocalTodoPath,
    String remotePath = defaultRemoteTodoPath,
    TodoFileState? state,
  }) : super(
          state ??
              TodoFileLoading(
                todoFilename: todoFilename,
                doneFilename: doneFilename,
                localPath: localPath,
                remotePath: remotePath,
              ),
        );

  Future<void> checkLocalPermission(String filename) async {
    try {
      await File(filename).create();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> load() async {
    try {
      log.info('Retrieving setting \'todoFilename\'.');
      Setting? todoFilename = await repository.get(key: 'todoFilename');
      if (todoFilename != null) {
        emit(state.load(todoFilename: todoFilename.value));
      }

      log.info('Retrieving setting \'localPath\'.');
      final Setting? localPath = await repository.get(key: 'localPath');
      if (localPath != null) {
        emit(state.load(localPath: localPath.value));
      }
      await checkLocalPermission(state.localTodoFilePath);

      log.info('Retrieving setting \'remotePath\'.');
      final Setting? remotePath = await repository.get(key: 'remotePath');
      if (remotePath != null) {
        emit(state.load(remotePath: remotePath.value));
      }

      emit(state.ready());
    } on Exception catch (e) {
      emit(
        state.error(
          message: e.toString(),
          todoFilename: defaultTodoFilename,
          doneFilename: defaultDoneFilename,
          localPath: defaultLocalTodoPath,
          remotePath: defaultRemoteTodoPath,
        ),
      );
    }
  }

  Future<void> saveLocalPath(String? value) async {
    try {
      if (value != null) {
        emit(state.load());
        log.fine('Saving setting \'localPath\'.');
        await repository.updateOrInsert(
          Setting(key: 'localPath', value: value),
        );
        emit(state.ready(localPath: value));
      }
    } on Exception catch (e) {
      emit(
        state.error(
          message: e.toString(),
          localPath: value,
        ),
      );
    }
  }

  Future<void> saveLocalFilename(String? value) async {
    try {
      if (value != null) {
        emit(state.load());
        log.fine('Saving setting \'todoFilename\'.');
        await repository.updateOrInsert(
          Setting(key: 'todoFilename', value: value),
        );
        emit(state.ready(todoFilename: value));
      }
    } on Exception catch (e) {
      emit(
        state.error(
          message: e.toString(),
          todoFilename: value,
        ),
      );
    }
  }

  Future<void> saveRemotePath(String? value) async {
    try {
      if (value != null) {
        emit(state.load());
        log.fine('Saving setting \'remotePath\'.');
        await repository.updateOrInsert(
          Setting(key: 'remotePath', value: value),
        );
        emit(state.ready(remotePath: value));
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> resetToDefaults() async {
    try {
      emit(state.load());
      log.fine('Resetting to the defaults.');
      await resetTodoFileSettings();
      emit(
        TodoFileLoading(
          todoFilename: defaultTodoFilename,
          doneFilename: defaultDoneFilename,
          localPath: defaultLocalTodoPath,
          remotePath: defaultRemoteTodoPath,
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> resetTodoFileSettings() async {
    try {
      log.fine('Resetting todofile settings.');
      for (var k in [
        'todoFilename',
        'localPath',
        'remotePath',
      ]) {
        log.fine('Deleting setting \'$k\'.');
        await repository.delete(key: k);
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
