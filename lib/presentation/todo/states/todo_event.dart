import 'package:equatable/equatable.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

final class TodoCompletionToggled extends TodoEvent {
  final bool completion;

  const TodoCompletionToggled(this.completion);

  @override
  List<Object> get props => [completion];
}

final class TodoDescriptionChanged extends TodoEvent {
  final String description;

  const TodoDescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

final class TodoPriorityAdded extends TodoEvent {
  final String priority;

  const TodoPriorityAdded(this.priority);

  @override
  List<Object> get props => [priority];
}

final class TodoPriorityRemoved extends TodoEvent {
  const TodoPriorityRemoved();
}

final class TodoProjectAdded extends TodoEvent {
  final String project;

  const TodoProjectAdded(this.project);

  @override
  List<Object> get props => [project];
}

final class TodoProjectRemoved extends TodoEvent {
  final String project;

  const TodoProjectRemoved(this.project);

  @override
  List<Object> get props => [project];
}

final class TodoContextAdded extends TodoEvent {
  final String context;

  const TodoContextAdded(this.context);

  @override
  List<Object> get props => [context];
}

final class TodoContextRemoved extends TodoEvent {
  final String context;

  const TodoContextRemoved(this.context);

  @override
  List<Object> get props => [context];
}

final class TodoKeyValueAdded extends TodoEvent {
  final String keyValue;

  const TodoKeyValueAdded(this.keyValue);

  @override
  List<Object> get props => [keyValue];
}

final class TodoKeyValueRemoved extends TodoEvent {
  final String keyValue;

  const TodoKeyValueRemoved(this.keyValue);

  @override
  List<Object> get props => [keyValue];
}

final class TodoSubmitted extends TodoEvent {
  final int? id;

  const TodoSubmitted(this.id);

  @override
  List<Object?> get props => [id];
}

final class TodoDeleted extends TodoEvent {
  final int? id;

  const TodoDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
