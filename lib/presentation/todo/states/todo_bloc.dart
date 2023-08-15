import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoListRepository _todoListRepository;

  TodoBloc({
    TodoStatus status = TodoStatus.initial,
    required TodoListRepository todoListRepository,
    required Todo todo,
  })  : _todoListRepository = todoListRepository,
        super(
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
    on<TodoDeleted>(_onDeleted);
    on<TodoSubmitted>(_onSubmitted);
  }

  void _onCompletionToggled(
    TodoCompletionToggled event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(completion: event.completion);
    _todoListRepository.saveTodo(state.todo.id, todo);
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
    Todo todo = state.todo.copyWith();
    todo.priority = null;
    emit(state.copyWith(todo: todo));
  }

  void _onProjectAdded(
    TodoProjectAdded event,
    Emitter<TodoState> emit,
  ) {
    List<String> projects = [...state.todo.projects];
    projects.add(event.project);
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
    contexts.add(event.context);
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

  void _onDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) {
    _todoListRepository.deleteTodo(state.todo.id);
  }

  void _onSubmitted(
    TodoSubmitted event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith();
    _todoListRepository.saveTodo(state.todo.id, todo);
    emit(state.copyWith(todo: todo));
  }
}
