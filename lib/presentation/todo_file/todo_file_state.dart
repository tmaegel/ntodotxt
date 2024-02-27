import 'package:equatable/equatable.dart';

sealed class TodoFileState extends Equatable {
  final String todoFilename;
  final String? localPath;
  final String? remotePath;

  const TodoFileState({
    this.todoFilename = 'todo.txt',
    this.localPath,
    this.remotePath,
  });

  TodoFileLoading load({
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileLoading(
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  TodoFileReady ready({
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileReady(
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  TodoFileError error({
    required String message,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileError(
      message: message,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  List<Object?> get props => [
        todoFilename,
        localPath,
        remotePath,
      ];

  @override
  String toString() =>
      'TodoFileState { todoFilename $todoFilename localPath: $localPath remotePath: $remotePath }';
}

final class TodoFileLoading extends TodoFileState {
  const TodoFileLoading({
    super.todoFilename,
    super.localPath,
    super.remotePath,
  });

  TodoFileLoading copyWith({
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileLoading(
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  String toString() =>
      'TodoFileLoading { todoFilename: $todoFilename localPath: $localPath remotePath: $remotePath }';
}

final class TodoFileReady extends TodoFileState {
  const TodoFileReady({
    super.todoFilename,
    super.localPath,
    super.remotePath,
  });

  TodoFileReady copyWith({
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileReady(
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  String toString() =>
      'TodoFileReady { todoFilename: $todoFilename localPath: $localPath remotePath: $remotePath }';
}

final class TodoFileError extends TodoFileState {
  final String message;

  const TodoFileError({
    required this.message,
    super.todoFilename,
    super.localPath,
    super.remotePath,
  });

  TodoFileError copyWith({
    String? message,
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileError(
      message: message ?? this.message,
      localPath: localPath ?? this.localPath,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  List<Object?> get props => [
        message,
        todoFilename,
        localPath,
        remotePath,
      ];

  @override
  String toString() =>
      'TodoFileError { message $message todoFilename: $todoFilename localPath: $localPath remotePath: $remotePath }';
}
