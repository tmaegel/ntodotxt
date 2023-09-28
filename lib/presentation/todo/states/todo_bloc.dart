import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoListRepository _todoListRepository;

  TodoBloc({
    required TodoListRepository todoListRepository,
    required Todo todo,
  })  : _todoListRepository = todoListRepository,
        super(TodoInitial(todo: todo)) {
    on<TodoSubmitted>(_onSubmitted);
    on<TodoDeleted>(_onDeleted);
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

  void _onSubmitted(
    TodoSubmitted event,
    Emitter<TodoState> emit,
  ) {
    try {
      _todoListRepository.saveTodo(state.todo);
      emit(state.success());
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) {
    try {
      _todoListRepository.deleteTodo(state.todo);
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onCompletionToggled(
    TodoCompletionToggled event,
    Emitter<TodoState> emit,
  ) {
    try {
      final Todo todo = state.todo.copyWith(
        completion: event.completion,
        completionDate: event.completion ? DateTime.now() : null,
        unsetCompletionDate: !event.completion,
      );
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
      final Todo todo = state.todo.copyWith(unsetPriority: true);
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
