import 'package:equatable/equatable.dart';
import 'package:ntodotxt/constants/app.dart';

sealed class TodoFileState extends Equatable {
  final String todoFilename;
  final String doneFilename;
  final String localPath;
  final String remotePath;

  const TodoFileState({
    this.todoFilename = defaultTodoFilename,
    this.doneFilename = defaultDoneFilename,
    this.localPath = defaultLocalTodoPath,
    this.remotePath = defaultRemoteTodoPath,
  });

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
      'TodoFileState { localFile $localPath/$todoFilename remoteFile: $remotePath/$todoFilename }';
}

final class TodoFileLoading extends TodoFileState {
  const TodoFileLoading({
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
      'TodoFileLoading { localFile $localPath/$todoFilename remoteFile: $remotePath/$todoFilename }';
}

final class TodoFileReady extends TodoFileState {
  const TodoFileReady({
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
      'TodoFileReady { localFile $localPath/$todoFilename remoteFile: $remotePath/$todoFilename }';
}

final class TodoFileError extends TodoFileState {
  final String message;

  const TodoFileError({
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
      'TodoFileError { message $message localFile $localPath/$todoFilename remoteFile: $remotePath/$todoFilename }';
}
