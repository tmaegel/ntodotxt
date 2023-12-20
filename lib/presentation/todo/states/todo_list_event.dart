import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

sealed class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object?> get props => [];
}

final class TodoListSubscriptionRequested extends TodoListEvent {
  const TodoListSubscriptionRequested();
}

final class TodoListSynchronizationRequested extends TodoListEvent {
  const TodoListSynchronizationRequested();
}

final class TodoListTodoSubmitted extends TodoListEvent {
  final Todo todo;

  const TodoListTodoSubmitted({
    required this.todo,
  });

  @override
  List<Object?> get props => [todo];
}

final class TodoListTodoDeleted extends TodoListEvent {
  final Todo todo;

  const TodoListTodoDeleted({
    required this.todo,
  });

  @override
  List<Object?> get props => [todo];
}

final class TodoListTodoCompletionToggled extends TodoListEvent {
  final Todo todo;
  final bool completion;

  const TodoListTodoCompletionToggled({
    required this.todo,
    required this.completion,
  });

  @override
  List<Object?> get props => [todo, completion];
}
