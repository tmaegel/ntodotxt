import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

sealed class TodoState extends Equatable {
  final Todo todo;

  const TodoState({
    required this.todo,
  });

  TodoSuccess success({
    Todo? todo,
  }) {
    return TodoSuccess(
      todo: todo ?? this.todo,
    );
  }

  TodoError error({
    required String message,
    Todo? todo,
  }) {
    return TodoError(
      message: message,
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoState { todo: $todo }';
}

final class TodoSuccess extends TodoState {
  const TodoSuccess({
    required super.todo,
  });

  TodoSuccess copyWith({
    Todo? todo,
  }) {
    return TodoSuccess(
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoSuccess { todo: "$todo" }';
}

final class TodoError extends TodoState {
  final String message;

  const TodoError({
    required this.message,
    required super.todo,
  });

  TodoError copyWith({
    String? message,
    Todo? todo,
  }) {
    return TodoError(
      message: message ?? this.message,
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object> get props => [
        message,
        todo,
      ];

  @override
  String toString() => 'TodoError { message: $message todo: "$todo" }';
}
