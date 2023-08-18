import 'package:equatable/equatable.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

sealed class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object?> get props => [];
}

final class TodoListSubscriptionRequested extends TodoListEvent {
  const TodoListSubscriptionRequested();
}

final class TodoListTodoCompletionToggled extends TodoListEvent {
  final int? id;
  final bool? completion;

  const TodoListTodoCompletionToggled({
    this.id,
    this.completion,
  });

  @override
  List<Object?> get props => [id, completion];
}

final class TodoListTodoDeleted extends TodoListEvent {
  final int? id;

  const TodoListTodoDeleted({
    required this.id,
  });

  @override
  List<Object?> get props => [id];
}

final class TodoListOrderChanged extends TodoListEvent {
  final TodoListOrder order;

  const TodoListOrderChanged({
    required this.order,
  });

  @override
  List<Object> get props => [order];
}

final class TodoListFilterChanged extends TodoListEvent {
  final TodoListFilter filter;

  const TodoListFilterChanged({
    required this.filter,
  });

  @override
  List<Object> get props => [filter];
}
