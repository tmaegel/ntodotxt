import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ntodotxt/common/constants/app.dart';

sealed class TodoFileState extends Equatable {
  final String todoFilename;
  final String doneFilename;
  final String localPath;
  final String remotePath;

  TodoFileState({
    this.todoFilename = defaultTodoFilename,
    this.doneFilename = defaultDoneFilename,
    String localPath = defaultLocalTodoPath,
    String remotePath = defaultLocalTodoPath,
  })  : localPath = localPath.endsWith(Platform.pathSeparator)
            ? localPath
            : '$localPath${Platform.pathSeparator}',
        remotePath = remotePath.endsWith(Platform.pathSeparator)
            ? remotePath
            : '$remotePath${Platform.pathSeparator}';

  String get localTodoFilePath => '$localPath$todoFilename';

  String get remoteTodoFilePath => '$remotePath$todoFilename';

  TodoFileLoading load({
    String? todoFilename,
    String? doneFilename,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileLoading(
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  TodoFileReady ready({
    String? todoFilename,
    String? doneFilename,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileReady(
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  TodoFileError error({
    required String message,
    String? todoFilename,
    String? doneFilename,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileError(
      message: message,
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  List<Object?> get props => [
        todoFilename,
        doneFilename,
        localPath,
        remotePath,
      ];

  @override
  String toString() =>
      'TodoFileState { localFile $localTodoFilePath remoteFile: $remoteTodoFilePath }';
}

final class TodoFileLoading extends TodoFileState {
  TodoFileLoading({
    super.todoFilename,
    super.doneFilename,
    super.localPath,
    super.remotePath,
  });

  TodoFileLoading copyWith({
    String? todoFilename,
    String? doneFilename,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileLoading(
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  String toString() =>
      'TodoFileLoading { localFile $localTodoFilePath remoteFile: $remoteTodoFilePath }';
}

final class TodoFileReady extends TodoFileState {
  TodoFileReady({
    super.todoFilename,
    super.doneFilename,
    super.localPath,
    super.remotePath,
  });

  TodoFileReady copyWith({
    String? todoFilename,
    String? doneFilename,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileReady(
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  String toString() =>
      'TodoFileReady { localFile $localTodoFilePath remoteFile: $remoteTodoFilePath }';
}

final class TodoFileError extends TodoFileState {
  final String message;

  TodoFileError({
    required this.message,
    super.todoFilename,
    super.doneFilename,
    super.localPath,
    super.remotePath,
  });

  TodoFileError copyWith({
    String? message,
    String? todoFilename,
    String? doneFilename,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileError(
      message: message ?? this.message,
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  List<Object?> get props => [
        message,
        todoFilename,
        doneFilename,
        localPath,
        remotePath,
      ];

  @override
  String toString() =>
      'TodoFileError { message $message localFile $localTodoFilePath remoteFile: $remoteTodoFilePath }';
}
