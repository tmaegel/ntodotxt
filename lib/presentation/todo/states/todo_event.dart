import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

final class TodoCompletionToggled extends TodoEvent {
  final bool completion;

  const TodoCompletionToggled(this.completion);

  @override
  List<Object> get props => [completion];
}

final class TodoSubmitted extends TodoEvent {
  final Todo todo;

  const TodoSubmitted(this.todo);

  @override
  List<Object> get props => [todo];
}

final class TodoDeleted extends TodoEvent {
  final int index;

  const TodoDeleted(this.index);

  @override
  List<Object> get props => [index];
}
