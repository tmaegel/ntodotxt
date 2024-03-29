import 'package:equatable/equatable.dart';

sealed class TodoFileState extends Equatable {
  final String localFilename;
  final String localPath;
  final String? remotePath;

  const TodoFileState({
    required this.localFilename,
    required this.localPath,
    this.remotePath,
  });

  TodoFileLoading load({
    String? localPath,
    String? localFilename,
    String? remotePath,
  }) {
    return TodoFileLoading(
      localPath: localPath ?? this.localPath,
      localFilename: localFilename ?? this.localFilename,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  TodoFileReady ready({
    String? localPath,
    String? localFilename,
    String? remotePath,
  }) {
    return TodoFileReady(
      localPath: localPath ?? this.localPath,
      localFilename: localFilename ?? this.localFilename,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  TodoFileError error({
    required String message,
    String? localPath,
    String? localFilename,
    String? remotePath,
  }) {
    return TodoFileError(
      message: message,
      localPath: localPath ?? this.localPath,
      localFilename: localFilename ?? this.localFilename,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  List<Object?> get props => [
        localFilename,
        localPath,
        remotePath,
      ];

  @override
  String toString() =>
      'TodoFileState { localFile $localPath/$localFilename remotePath: $remotePath }';
}

final class TodoFileLoading extends TodoFileState {
  const TodoFileLoading({
    required super.localFilename,
    required super.localPath,
    super.remotePath,
  });

  TodoFileLoading copyWith({
    String? localPath,
    String? localFilename,
    String? remotePath,
  }) {
    return TodoFileLoading(
      localPath: localPath ?? this.localPath,
      localFilename: localFilename ?? this.localFilename,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  String toString() =>
      'TodoFileLoading { localFile $localPath/$localFilename remotePath: $remotePath }';
}

final class TodoFileReady extends TodoFileState {
  const TodoFileReady({
    required super.localFilename,
    required super.localPath,
    super.remotePath,
  });

  TodoFileReady copyWith({
    String? localPath,
    String? localFilename,
    String? remotePath,
  }) {
    return TodoFileReady(
      localPath: localPath ?? this.localPath,
      localFilename: localFilename ?? this.localFilename,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  String toString() =>
      'TodoFileReady { localFile $localPath/$localFilename remotePath: $remotePath }';
}

final class TodoFileError extends TodoFileState {
  final String message;

  const TodoFileError({
    required this.message,
    required super.localFilename,
    required super.localPath,
    super.remotePath,
  });

  TodoFileError copyWith({
    String? message,
    String? localPath,
    String? localFilename,
    String? remotePath,
  }) {
    return TodoFileError(
      message: message ?? this.message,
      localPath: localPath ?? this.localPath,
      localFilename: localFilename ?? this.localFilename,
      remotePath: remotePath ?? this.remotePath,
    );
  }

  @override
  List<Object?> get props => [
        message,
        localFilename,
        localPath,
        remotePath,
      ];

  @override
  String toString() =>
      'TodoFileError { message $message localFile $localPath/$localFilename remotePath: $remotePath }';
}
