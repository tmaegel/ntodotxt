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

  TodoState change({
    Todo? todo,
  }) {
    return TodoChange(
      todo: todo ?? this.todo,
    );
  }

  TodoState success({
    Todo? todo,
  }) {
    return TodoSuccess(
      todo: todo ?? this.todo,
    );
  }

  TodoState error({
    required String message,
    Todo? todo,
  }) {
    return TodoError(
      message: message,
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object?> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoState { todo: "$todo" }';
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
  String toString() => 'TodoInitial { todo: "$todo" }';
}

final class TodoChange extends TodoState {
  const TodoChange({
    required super.todo,
  });

  @override
  List<Object?> get props => [
        todo,
      ];

  @override
  String toString() => 'TodoChange { todo: "$todo" }';
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
  String toString() => 'TodoSuccess { todo: "$todo" }';
}

final class TodoError extends TodoState {
  final String message;

  const TodoError({
    required this.message,
    required super.todo,
  });

  @override
  List<Object?> get props => [
        message,
        todo,
      ];

  @override
  String toString() => 'TodoError { message: $message todo: "$todo" }';
}
