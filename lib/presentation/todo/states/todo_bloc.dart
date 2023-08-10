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
    required int index,
    required Todo todo,
  })  : _todoListRepository = todoListRepository,
        super(
          TodoState(
            status: status,
            index: index,
            todo: todo,
          ),
        ) {
    on<TodoCompletionToggled>(_onCompletionToggled);
    on<TodoDescriptionChanged>(_onDescriptionChanged);
    on<TodoDeleted>(_onDeleted);
    on<TodoSubmitted>(_onSubmitted);
  }

  void _onCompletionToggled(
    TodoCompletionToggled event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(completion: event.completion);
    _todoListRepository.saveTodo(state.index, todo);
    emit(state.copyWith(todo: todo));
  }

  void _onDescriptionChanged(
    TodoDescriptionChanged event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(description: event.description);
    emit(state.copyWith(todo: todo));
  }

  void _onDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) {
    _todoListRepository.deleteTodo(state.index);
  }

  void _onSubmitted(
    TodoSubmitted event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith();
    _todoListRepository.saveTodo(state.index, todo);
    emit(state.copyWith(todo: todo));
  }
}
