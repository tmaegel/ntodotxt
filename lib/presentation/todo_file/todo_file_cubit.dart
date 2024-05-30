import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/main.dart' show log;
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';

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
      Setting? todoFilename;
      log.info('Retrieving setting \'todoFilename\'.');
      todoFilename = await repository.get(key: 'todoFilename');
      if (todoFilename == null) {
        // @todo: Keep 'localFilename' for backward compatibility.
        // Revert in a later realease.
        log.info(
          'Setting todoFilename doesn\'t exist. Retrieving setting \'localFilename\' as fallback.',
        );
        todoFilename = await repository.get(key: 'localFilename');
        log.info('Saving new setting new \'todoFilename\'.');
        await repository.updateOrInsert(
          Setting(
              key: 'todoFilename',
              value: todoFilename == null
                  ? defaultTodoFilename
                  : todoFilename.value),
        );
        log.info('Deleting old setting \'localFilename\'.');
        await repository.delete(key: 'localFilename');
        emit(state.load(
            todoFilename: todoFilename == null
                ? defaultTodoFilename
                : todoFilename.value));
      } else {
        emit(state.load(todoFilename: todoFilename.value));
      }

      log.info('Retrieving setting \'localPath\'.');
      final Setting? localPath = await repository.get(key: 'localPath');
      if (localPath != null) {
        emit(state.load(localPath: localPath.value));
      }
      await checkLocalPermission(
        '${state.localPath}${Platform.pathSeparator}${state.todoFilename}',
      );

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

  Future<void> updateLocalPath(String? value) async {
    if (value != null) {
      log.fine('Updating \'localPath\'.');
      emit(state.load(localPath: value));
    }
  }

  Future<void> saveLocalPath(String? value) async {
    try {
      if (value != null) {
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

  Future<void> updateTodoFilename(String? value) async {
    if (value != null) {
      log.fine('Updating \'todoFilename\'.');
      emit(state.load(todoFilename: value));
    }
  }

  Future<void> saveLocalFilename(String? value) async {
    try {
      if (value != null) {
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

  Future<void> updateRemotePath(String? value) async {
    if (value != null) {
      log.fine('Updating \'remotePath\'.');
      emit(state.load(remotePath: value));
    }
  }

  Future<void> saveRemotePath(String? value) async {
    try {
      if (value != null) {
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

  Future<void> resetTodoFileSettings() async {
    try {
      log.fine('Resetting todofile settings.');
      for (var k in [
        'todoFilename',
        'localFilename', // @todo: Keep for backwards compatibility.
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

  Future<void> resetToDefaults() async {
    try {
      log.fine('Resetting to the defaults.');
      await resetTodoFileSettings();
      emit(
        const TodoFileLoading(
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
}
