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
    on<TodoCompletionChanged>(_onCompletionChanged);
    on<TodoSubmitted>(_onSubmitted);
    on<TodoDeleted>(_onDeleted);
  }

  void _onCompletionChanged(
    TodoCompletionChanged event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = state.todo.copyWith(completion: event.completion);
    _todoListRepository.saveTodo(state.index, todo);
    emit(state.copyWith(todo: todo));
  }

  void _onSubmitted(
    TodoSubmitted event,
    Emitter<TodoState> emit,
  ) {
    final Todo todo = event.todo.copyWith();
    _todoListRepository.saveTodo(state.index, todo);
    emit(state.copyWith(todo: todo));
  }

  void _onDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) {
    _todoListRepository.deleteTodo(state.index);
  }
}
