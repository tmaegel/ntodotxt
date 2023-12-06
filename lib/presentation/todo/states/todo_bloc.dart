import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc({
    required Todo todo,
  }) : super(TodoInitial(todo: todo)) {
    on<TodoRefreshed>(_onRefreshed);
    on<TodoCompletionToggled>(_onCompletionToggled);
    on<TodoDescriptionChanged>(_onDescriptionChanged);
    on<TodoPriorityAdded>(_onPriorityAdded);
    on<TodoPriorityRemoved>(_onPriorityRemoved);
    on<TodoProjectsAdded>(_onProjectAdded);
    on<TodoProjectRemoved>(_onProjectRemoved);
    on<TodoContextsAdded>(_onContextAdded);
    on<TodoContextRemoved>(_onContextRemoved);
    on<TodoKeyValuesAdded>(_onKeyValueAdded);
    on<TodoKeyValueRemoved>(_onKeyValueRemoved);
  }

  void _onRefreshed(
    TodoRefreshed event,
    Emitter<TodoState> emit,
  ) {
    try {
      final Todo todo = event.todo.copyWith();
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onCompletionToggled(
    TodoCompletionToggled event,
    Emitter<TodoState> emit,
  ) {
    try {
      final Todo todo = state.todo.copyWith(completion: event.completion);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onDescriptionChanged(
    TodoDescriptionChanged event,
    Emitter<TodoState> emit,
  ) {
    try {
      final Todo todo = state.todo.copyWith(description: event.description);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onPriorityAdded(
    TodoPriorityAdded event,
    Emitter<TodoState> emit,
  ) {
    try {
      final Todo todo = state.todo.copyWith(priority: event.priority);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onPriorityRemoved(
    TodoPriorityRemoved event,
    Emitter<TodoState> emit,
  ) {
    try {
      final Todo todo = state.todo.copyWith(priority: Priority.none);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onProjectAdded(
    TodoProjectsAdded event,
    Emitter<TodoState> emit,
  ) {
    try {
      Set<String> projects = {...state.todo.projects};
      projects.addAll(event.projects);
      final Todo todo = state.todo.copyWith(projects: projects);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onProjectRemoved(
    TodoProjectRemoved event,
    Emitter<TodoState> emit,
  ) {
    try {
      Set<String> projects = {...state.todo.projects};
      projects.remove(event.project);
      final Todo todo = state.todo.copyWith(projects: projects);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onContextAdded(
    TodoContextsAdded event,
    Emitter<TodoState> emit,
  ) {
    try {
      Set<String> contexts = {...state.todo.contexts};
      contexts.addAll(event.contexts);
      final Todo todo = state.todo.copyWith(contexts: contexts);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onContextRemoved(
    TodoContextRemoved event,
    Emitter<TodoState> emit,
  ) {
    try {
      Set<String> contexts = {...state.todo.contexts};
      contexts.remove(event.context);
      final Todo todo = state.todo.copyWith(contexts: contexts);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onKeyValueAdded(
    TodoKeyValuesAdded event,
    Emitter<TodoState> emit,
  ) {
    try {
      Map<String, String> keyValues = {...state.todo.keyValues};
      for (var kv in event.keyValues) {
        if (!Todo.patternKeyValue.hasMatch(kv)) {
          throw TodoInvalidKeyValueTag(tag: kv);
        }
        final List<String> splittedKeyValue = kv.split(":");
        if (splittedKeyValue.length == 2) {
          keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
        }
      }
      final Todo todo = state.todo.copyWith(keyValues: keyValues);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onKeyValueRemoved(
    TodoKeyValueRemoved event,
    Emitter<TodoState> emit,
  ) {
    try {
      if (!Todo.patternKeyValue.hasMatch(event.keyValue)) {
        throw TodoInvalidKeyValueTag(tag: event.keyValue);
      }
      Map<String, String> keyValues = {...state.todo.keyValues};
      final List<String> splittedKeyValue = event.keyValue.split(":");
      if (splittedKeyValue.length == 2) {
        keyValues.remove(splittedKeyValue[0]);
      }
      final Todo todo = state.todo.copyWith(keyValues: keyValues);
      emit(state.change(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
