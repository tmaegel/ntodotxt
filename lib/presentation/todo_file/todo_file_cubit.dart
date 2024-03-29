import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';

class TodoFileCubit extends Cubit<TodoFileState> {
  final SettingRepository repository;
  final String defaultLocalPath;

  TodoFileCubit({
    required this.repository,
    required this.defaultLocalPath,
    TodoFileState? state,
  }) : super(state ??
            TodoFileLoading(
              localPath: defaultLocalPath,
              localFilename: defaultTodoFilename,
            ));

  Future<void> checkPermission(String filename) async {
    try {
      await File(filename).create();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> load() async {
    try {
      final Setting? localPath = await repository.get(key: 'localPath');
      final Setting? localFilename = await repository.get(key: 'localFilename');
      if (localFilename != null) {
        emit(state.load(localFilename: localFilename.value));
      }
      if (localPath != null) {
        emit(state.load(localPath: localPath.value));
      }
      await checkPermission(
        '${state.localPath}${Platform.pathSeparator}${state.localFilename}',
      );
      emit(state.ready());
    } on Exception catch (e) {
      emit(
        state.error(
          message: e.toString(),
          localPath: defaultLocalPath,
          localFilename: defaultTodoFilename,
        ),
      );
    }
  }

  Future<void> updateLocalPath(String? value) async {
    if (value != null) {
      emit(state.load(localPath: value));
    }
  }

  Future<void> saveLocalPath(String? value) async {
    try {
      if (value != null) {
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

  Future<void> updateLocalFilename(String? value) async {
    if (value != null) {
      emit(state.load(localFilename: value));
    }
  }

  Future<void> saveLocalFilename(String? value) async {
    try {
      if (value != null) {
        await repository.updateOrInsert(
          Setting(key: 'localFilename', value: value),
        );
        emit(state.ready(localFilename: value));
      }
    } on Exception catch (e) {
      emit(
        state.error(
          message: e.toString(),
          localFilename: value,
        ),
      );
    }
  }

  Future<void> updateRemotePath(String? value) async {
    if (value != null) {
      emit(state.load(remotePath: value));
    }
  }

  Future<void> saveRemotePath(String? value) async {
    try {
      if (value != null) {
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
      for (var k in [
        'localPath',
        'localFilename',
        'remotePath',
      ]) {
        await repository.delete(key: k);
      }
      emit(
        TodoFileLoading(
          localPath: defaultLocalPath,
          localFilename: defaultTodoFilename,
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
