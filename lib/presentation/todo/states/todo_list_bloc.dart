import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final TodoListRepository _todoListRepository;

  TodoListBloc({
    required TodoListRepository todoListRepository,
  })  : _todoListRepository = todoListRepository,
        super(const TodoListState()) {
    on<TodoListSubscriptionRequested>(_onSubscriptionRequested);
    on<TodoListTodoCompletionToggled>(_onTodoCompletionToggled);
  }

  void _onSubscriptionRequested(
    TodoListSubscriptionRequested event,
    Emitter<TodoListState> emit,
  ) async {
    await emit.forEach<List<Todo>>(
      _todoListRepository.getTodoList(),
      onData: (todoList) => state.copyWith(
        status: TodoListStatus.success,
        todoList: todoList,
      ),
      onError: (_, __) => state.copyWith(
        status: TodoListStatus.failure,
      ),
    );
  }

  void _onTodoCompletionToggled(
    TodoListTodoCompletionToggled event,
    Emitter<TodoListState> emit,
  ) {
    final todo = _todoListRepository.getTodo(event.index);
    _todoListRepository.saveTodo(
      event.index,
      todo.copyWith(completion: event.completion ?? !todo.completion),
    );
  }
}
