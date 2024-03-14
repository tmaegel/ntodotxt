import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
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
  }) : super(state ?? TodoFileLoading(localPath: defaultLocalPath));

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
      if (localPath == null) {
        await repository.insert(
          Setting(key: 'localPath', value: defaultLocalPath),
        );
        await checkPermission(
            '$defaultLocalPath${Platform.pathSeparator}${state.todoFilename}');
        emit(state.ready(localPath: defaultLocalPath));
      } else {
        await checkPermission(
            '${localPath.value}${Platform.pathSeparator}${state.todoFilename}');
        emit(state.ready(localPath: localPath.value));
      }
    } on Exception catch (e) {
      emit(state.error(localPath: defaultLocalPath, message: e.toString()));
    }
  }

  Future<void> updateLocalPath(String? value) async {
    try {
      if (value != null) {
        await repository.updateOrInsert(
          Setting(key: 'localPath', value: value),
        );
        emit(state.ready(localPath: value));
      }
    } on Exception catch (e) {
      emit(state.error(localPath: value, message: e.toString()));
    }
  }

  Future<void> updateRemotePath(String? value) async {
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
      for (var k in ['localPath', 'remotePath']) {
        await repository.delete(key: k);
      }
      emit(TodoFileLoading(localPath: defaultLocalPath));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
