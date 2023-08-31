import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc({
    TodoStatus status = TodoStatus.initial,
    required Todo todo,
  }) : super(
          TodoState(
            status: status,
            todo: todo,
          ),
        ) {
    on<TodoCompletionToggled>(_onCompletionToggled);
    on<TodoDescriptionChanged>(_onDescriptionChanged);
    on<TodoPriorityAdded>(_onPriorityAdded);
    on<TodoPriorityRemoved>(_onPriorityRemoved);
    on<TodoProjectAdded>(_onProjectAdded);
    on<TodoProjectRemoved>(_onProjectRemoved);
    on<TodoContextAdded>(_onContextAdded);
    on<TodoContextRemoved>(_onContextRemoved);
    on<TodoKeyValueAdded>(_onKeyValueAdded);
    on<TodoKeyValueRemoved>(_onKeyValueRemoved);
  }

  void _onCompletionToggled(
    TodoCompletionToggled event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(
      completion: event.completion,
      completionDate: event.completion ? DateTime.now() : null,
      unsetCompletionDate: !event.completion,
    );
    emit(state.copyWith(todo: todo));
  }

  void _onDescriptionChanged(
    TodoDescriptionChanged event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(description: event.description);
    emit(state.copyWith(todo: todo));
  }

  void _onPriorityAdded(
    TodoPriorityAdded event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(priority: event.priority);
    emit(state.copyWith(todo: todo));
  }

  void _onPriorityRemoved(
    TodoPriorityRemoved event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(unsetPriority: true);
    emit(state.copyWith(todo: todo));
  }

  void _onProjectAdded(
    TodoProjectAdded event,
    Emitter<TodoState> emit,
  ) {
    List<String> projects = [...state.todo.projects];
    if (!projects.contains(event.project)) {
      projects.add(event.project);
    }
    final Todo todo = state.todo.copyWith(projects: projects);
    emit(state.copyWith(todo: todo));
  }

  void _onProjectRemoved(
    TodoProjectRemoved event,
    Emitter<TodoState> emit,
  ) {
    List<String> projects = [...state.todo.projects];
    projects.remove(event.project);
    final Todo todo = state.todo.copyWith(projects: projects);
    emit(state.copyWith(todo: todo));
  }

  void _onContextAdded(
    TodoContextAdded event,
    Emitter<TodoState> emit,
  ) {
    List<String> contexts = [...state.todo.contexts];
    if (!contexts.contains(event.context)) {
      contexts.add(event.context);
    }
    final Todo todo = state.todo.copyWith(contexts: contexts);
    emit(state.copyWith(todo: todo));
  }

  void _onContextRemoved(
    TodoContextRemoved event,
    Emitter<TodoState> emit,
  ) {
    List<String> contexts = [...state.todo.contexts];
    contexts.remove(event.context);
    final Todo todo = state.todo.copyWith(contexts: contexts);
    emit(state.copyWith(todo: todo));
  }

  void _onKeyValueAdded(
    TodoKeyValueAdded event,
    Emitter<TodoState> emit,
  ) {
    Map<String, String> keyValues = {...state.todo.keyValues};
    final List<String> splittedKeyValue = event.keyValue.split(":");
    if (splittedKeyValue.length == 2) {
      keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
    }
    final Todo todo = state.todo.copyWith(keyValues: keyValues);
    emit(state.copyWith(todo: todo));
  }

  void _onKeyValueRemoved(
    TodoKeyValueRemoved event,
    Emitter<TodoState> emit,
  ) {
    Map<String, String> keyValues = {...state.todo.keyValues};
    final List<String> splittedKeyValue = event.keyValue.split(":");
    if (splittedKeyValue.length == 2) {
      keyValues.remove(splittedKeyValue[0]);
    }
    final Todo todo = state.todo.copyWith(keyValues: keyValues);
    emit(state.copyWith(todo: todo));
  }
}
