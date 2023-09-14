import 'package:equatable/equatable.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

final class TodoSubmitted extends TodoEvent {
  const TodoSubmitted();

  @override
  List<Object> get props => [];
}

final class TodoDeleted extends TodoEvent {
  const TodoDeleted();

  @override
  List<Object> get props => [];
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

final class TodoProjectsAdded extends TodoEvent {
  final List<String> projects;

  const TodoProjectsAdded(this.projects);

  @override
  List<Object> get props => [projects];
}

final class TodoProjectRemoved extends TodoEvent {
  final String project;

  const TodoProjectRemoved(this.project);

  @override
  List<Object> get props => [project];
}

final class TodoContextsAdded extends TodoEvent {
  final List<String> contexts;

  const TodoContextsAdded(this.contexts);

  @override
  List<Object> get props => [contexts];
}

final class TodoContextRemoved extends TodoEvent {
  final String context;

  const TodoContextRemoved(this.context);

  @override
  List<Object> get props => [context];
}

final class TodoKeyValuesAdded extends TodoEvent {
  final List<String> keyValues;

  const TodoKeyValuesAdded(this.keyValues);

  @override
  List<Object> get props => [keyValues];
}

final class TodoKeyValueRemoved extends TodoEvent {
  final String keyValue;

  const TodoKeyValueRemoved(this.keyValue);

  @override
  List<Object> get props => [keyValue];
}
