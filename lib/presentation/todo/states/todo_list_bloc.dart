import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final TodoListRepository _todoListRepository;

  TodoListBloc({
    SharedPreferences? prefs,
    required TodoListRepository todoListRepository,
  })  : _todoListRepository = todoListRepository,
        super(
          TodoListInitial(
            filter: TodoListFilter.values.byName(
              prefs == null ? 'all' : prefs.getString('todoFilter') ?? 'all',
            ),
            order: TodoListOrder.values.byName(
              prefs == null
                  ? 'ascending'
                  : prefs.getString('todoOrder') ?? 'ascending',
            ),
            group: TodoListGroupBy.values.byName(
              prefs == null
                  ? 'upcoming'
                  : prefs.getString('todoGrouping') ?? 'upcoming',
            ),
          ),
        ) {
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
    emit(state.loading());
    await emit.forEach<List<Todo>>(
      _todoListRepository.getTodoList(),
      onData: (todoList) => state.success(todoList: todoList),
      onError: (e, _) => state.error(message: e.toString()),
    );
  }

  Future<void> _onTodoListSynchronizationRequested(
    TodoListSynchronizationRequested event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      await _todoListRepository.readFromSource();
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoCompletionToggled(
    TodoListTodoCompletionToggled event,
    Emitter<TodoListState> emit,
  ) {
    try {
      final Todo todo = event.todo.copyWith(
        completion: event.completion,
        completionDate: event.completion ? DateTime.now() : null,
        unsetCompletionDate: !event.completion,
      );
      _todoListRepository.saveTodo(todo);
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoSelectedToggled(
    TodoListTodoSelectedToggled event,
    Emitter<TodoListState> emit,
  ) {
    try {
      final Todo todo = event.todo.copyWith(
        selected: event.selected,
      );
      _todoListRepository.saveTodo(todo);
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectedAll(
    TodoListSelectedAll event,
    Emitter<TodoListState> emit,
  ) {
    try {
      _todoListRepository.saveMultipleTodos(
        [
          for (var t in state.todoList)
            t.copyWith(
              selected: true,
            ),
        ],
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListUnselectedAll(
    TodoListUnselectedAll event,
    Emitter<TodoListState> emit,
  ) {
    try {
      _todoListRepository.saveMultipleTodos(
        [
          for (var t in state.todoList)
            t.copyWith(
              selected: false,
            ),
        ],
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectionCompleted(
    TodoListSelectionCompleted event,
    Emitter<TodoListState> emit,
  ) {
    try {
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
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectionIncompleted(
    TodoListSelectionIncompleted event,
    Emitter<TodoListState> emit,
  ) {
    try {
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
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectionDeleted(
    TodoListSelectionDeleted event,
    Emitter<TodoListState> emit,
  ) {
    try {
      _todoListRepository.deleteMultipleTodos(
        state.selectedTodos.toList(),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListOrderChanged(
    TodoListOrderChanged event,
    Emitter<TodoListState> emit,
  ) {
    try {
      emit(state.success(order: event.order));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListFilterChanged(
    TodoListFilterChanged event,
    Emitter<TodoListState> emit,
  ) {
    try {
      emit(state.success(filter: event.filter));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListGroupByChanged(
    TodoListGroupByChanged event,
    Emitter<TodoListState> emit,
  ) {
    try {
      emit(state.success(group: event.group));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
