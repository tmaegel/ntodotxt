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
    on<TodoListSubscriptionRequested>(_onTodoListSubscriptionRequested);
    on<TodoListSynchronizationRequested>(_onTodoListSynchronizationRequested);
    on<TodoListTodoCompletionToggled>(_onTodoCompletionToggled);
    on<TodoListTodoSelectedToggled>(_onTodoSelectedToggled);
    on<TodoListSelectedAll>(_onTodoListSelectedAll);
    on<TodoListUnselectedAll>(_onTodoListUnselectedAll);
    on<TodoListSelectionCompleted>(_onTodoListSelectionCompleted);
    on<TodoListSelectionIncompleted>(_onTodoListSelectionIncompleted);
    on<TodoListSelectionDeleted>(_onTodoListSelectionDeleted);
    on<TodoListOrderChanged>(_onTodoListOrderChanged);
    on<TodoListFilterChanged>(_onTodoListFilterChanged);
    on<TodoListGroupByChanged>(_onTodoListGroupByChanged);
  }

  Future<void> _onTodoListSubscriptionRequested(
    TodoListSubscriptionRequested event,
    Emitter<TodoListState> emit,
  ) async {
    emit(
      state.copyWith(status: TodoListStatus.loading),
    );

    await emit.forEach<List<Todo>>(
      _todoListRepository.getTodoList(),
      onData: (todoList) => state.copyWith(
        status: TodoListStatus.success,
        todoList: todoList,
      ),
      onError: (_, __) => state.copyWith(
        status: TodoListStatus.error,
      ),
    );
  }

  Future<void> _onTodoListSynchronizationRequested(
    TodoListSynchronizationRequested event,
    Emitter<TodoListState> emit,
  ) async {
    emit(
      state.copyWith(status: TodoListStatus.loading),
    );

    try {
      await _todoListRepository.syncTodoList();
    } catch (e) {
      emit(
        state.copyWith(status: TodoListStatus.error),
      );
    }
  }

  void _onTodoCompletionToggled(
    TodoListTodoCompletionToggled event,
    Emitter<TodoListState> emit,
  ) {
    final Todo todo = event.todo.copyWith(
      completion: event.completion,
      completionDate: event.completion ? DateTime.now() : null,
      unsetCompletionDate: !event.completion,
    );
    _todoListRepository.saveTodo(todo);
  }

  void _onTodoSelectedToggled(
    TodoListTodoSelectedToggled event,
    Emitter<TodoListState> emit,
  ) {
    final Todo todo = event.todo.copyWith(
      selected: event.selected,
    );
    _todoListRepository.saveTodo(todo);
  }

  void _onTodoListSelectedAll(
    TodoListSelectedAll event,
    Emitter<TodoListState> emit,
  ) {
    _todoListRepository.saveMultipleTodos(
      [
        for (var t in state.todoList)
          t.copyWith(
            selected: true,
          ),
      ],
    );
  }

  void _onTodoListUnselectedAll(
    TodoListUnselectedAll event,
    Emitter<TodoListState> emit,
  ) {
    _todoListRepository.saveMultipleTodos(
      [
        for (var t in state.todoList)
          t.copyWith(
            selected: false,
          ),
      ],
    );
  }

  void _onTodoListSelectionCompleted(
    TodoListSelectionCompleted event,
    Emitter<TodoListState> emit,
  ) {
    _todoListRepository.saveMultipleTodos(
      [
        for (var t in state.selectedTodos)
          t.copyWith(
            selected: false,
            completion: true,
            completionDate: DateTime.now(),
          )
      ],
    );
  }

  void _onTodoListSelectionIncompleted(
    TodoListSelectionIncompleted event,
    Emitter<TodoListState> emit,
  ) {
    _todoListRepository.saveMultipleTodos(
      [
        for (var t in state.selectedTodos)
          t.copyWith(
            selected: false,
            completion: false,
            unsetCompletionDate: true,
          )
      ],
    );
  }

  void _onTodoListSelectionDeleted(
    TodoListSelectionDeleted event,
    Emitter<TodoListState> emit,
  ) {
    _todoListRepository.deleteMultipleTodos(state.selectedTodos.toList());
  }

  void _onTodoListOrderChanged(
    TodoListOrderChanged event,
    Emitter<TodoListState> emit,
  ) {
    emit(state.copyWith(order: event.order));
  }

  void _onTodoListFilterChanged(
    TodoListFilterChanged event,
    Emitter<TodoListState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onTodoListGroupByChanged(
    TodoListGroupByChanged event,
    Emitter<TodoListState> emit,
  ) {
    emit(state.copyWith(groupBy: event.groupBy));
  }
}
