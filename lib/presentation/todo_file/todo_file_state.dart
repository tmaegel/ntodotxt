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

  TodoFileState copyWith({
    String? localPath,
    String? remotePath,
  }) {
    return TodoFileReady(
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

  @override
  String toString() =>
      'TodoFileReady { todoFilename: $todoFilename localPath: $localPath remotePath: $remotePath }';
}
