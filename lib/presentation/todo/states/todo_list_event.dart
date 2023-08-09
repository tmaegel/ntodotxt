import 'package:equatable/equatable.dart';

sealed class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object?> get props => [];
}

final class TodoListSubscriptionRequested extends TodoListEvent {
  const TodoListSubscriptionRequested();
}

final class TodoListTodoCompletionToggled extends TodoListEvent {
  final int index;
  final bool? completion;

  const TodoListTodoCompletionToggled({
    required this.index,
    this.completion,
  });

  @override
  List<Object?> get props => [
        index,
        completion,
      ];
}

final class TodoListTodoDeleted extends TodoListEvent {
  final int index;

  const TodoListTodoDeleted({
    required this.index,
  });

  @override
  List<Object?> get props => [
        index,
      ];
}
