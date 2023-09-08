import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

sealed class TodoState extends Equatable {
  final Todo todo;

  const TodoState({
    required this.todo,
  });

  /// Initial state.
  TodoState copyWith({
    Todo? todo,
  }) {
    return TodoInitial(
      todo: todo ?? this.todo,
    );
  }

  /// Status after successful submission.
  TodoState copyWithSubmit({
    Todo? todo,
  }) {
    return TodoSuccess(
      todo: todo ?? this.todo,
    );
  }

  /// Error state
  TodoState copyWithError({
    required String error,
    Todo? todo,
  }) {
    return TodoError(
      error: error,
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object?> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoState { id: ${todo.id} todo: "$todo" }';
}

final class TodoInitial extends TodoState {
  const TodoInitial({
    required super.todo,
  });

  @override
  List<Object?> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoInitial { id: ${todo.id} todo: "$todo" }';
}

final class TodoSuccess extends TodoState {
  const TodoSuccess({
    required super.todo,
  });

  @override
  List<Object?> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoSuccess { id: ${todo.id} todo: "$todo" }';
}

final class TodoError extends TodoState {
  final String error;

  const TodoError({
    required this.error,
    required super.todo,
  });

  @override
  List<Object?> get props => [
        error,
        todo,
      ];

  @override
  String toString() =>
      'TodoError { error: $error id: ${todo.id} todo: "$todo" }';
}
