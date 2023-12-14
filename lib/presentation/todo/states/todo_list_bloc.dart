import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final TodoListRepository _repository;

  TodoListBloc({
    SharedPreferences? prefs,
    required TodoListRepository repository,
  })  : _repository = repository,
        super(
          TodoListInitial(
            filter: Filter(
              filter: TodoListFilter.values.byName(
                prefs == null ? 'all' : prefs.getString('todoFilter') ?? 'all',
              ),
              order: TodoListOrder.values.byName(
                prefs == null
                    ? 'ascending'
                    : prefs.getString('todoOrder') ?? 'ascending',
              ),
              groupBy: TodoListGroupBy.values.byName(
                prefs == null
                    ? 'none'
                    : prefs.getString('todoGrouping') ?? 'none',
              ),
            ),
          ),
        ) {
    on<TodoListSubscriptionRequested>(_onTodoListSubscriptionRequested);
    on<TodoListSynchronizationRequested>(_onTodoListSynchronizationRequested);
    on<TodoListTodoSubmitted>(_onTodoSubmitted);
    on<TodoListTodoDeleted>(_onTodoDeleted);
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
    await emit.forEach<List<Todo>>(
      _repository.getTodoList(),
      onData: (todoList) {
        if (state is TodoListInitial) {
          return state.success(todoList: todoList);
        } else {
          // Use copyWith here to keep the state (e.g. if loading)
          return state.copyWith(todoList: todoList);
        }
      },
      onError: (e, _) => state.error(message: e.toString()),
    );
  }

  void _onTodoListSynchronizationRequested(
    TodoListSynchronizationRequested event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      await _repository.initSource();
      await _repository.readFromSource();
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoSubmitted(
    TodoListTodoSubmitted event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      // Re-read file and update state manually before write the changes.
      await _repository.readFromSource();
      _repository.saveTodo(event.todo.copyWith());
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoDeleted(
    TodoListTodoDeleted event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      // Re-read file and update state manually before write the changes.
      await _repository.readFromSource();
      _repository.deleteTodo(event.todo.copyWith());
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoCompletionToggled(
    TodoListTodoCompletionToggled event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      // Re-read file and update state manually before write the changes.
      await _repository.readFromSource();
      if (_repository.existsTodo(event.todo)) {
        _repository.saveTodo(
          event.todo.copyDiff(completion: event.completion),
        );
      } else {
        _repository.saveTodo(
          event.todo.copyWith(completion: event.completion),
        );
      }
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoSelectedToggled(
    TodoListTodoSelectedToggled event,
    Emitter<TodoListState> emit,
  ) {
    try {
      if (_repository.existsTodo(event.todo)) {
        _repository.saveTodo(
          event.todo.copyDiff(selected: event.selected),
        );
      } else {
        _repository.saveTodo(
          event.todo.copyWith(selected: event.selected),
        );
      }
      // We dont want to write changes to file here.
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectedAll(
    TodoListSelectedAll event,
    Emitter<TodoListState> emit,
  ) {
    try {
      _repository.saveMultipleTodos(
        [
          for (var t in state.todoList) t.copyDiff(selected: true),
        ],
      );
      // We dont want to write changes to file here.
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListUnselectedAll(
    TodoListUnselectedAll event,
    Emitter<TodoListState> emit,
  ) {
    try {
      _repository.saveMultipleTodos(
        [
          for (var t in state.todoList) t.copyDiff(selected: false),
        ],
      );
      // We dont want to write changes to file here.
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectionCompleted(
    TodoListSelectionCompleted event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      // Re-read file and update state manually before write the changes.
      await _repository.readFromSource();
      _repository.saveMultipleTodos(
        [
          for (var t in state.selectedTodos)
            t.copyDiff(selected: false, completion: true)
        ],
      );
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectionIncompleted(
    TodoListSelectionIncompleted event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      // Re-read file and update state manually before write the changes.
      await _repository.readFromSource();
      _repository.saveMultipleTodos(
        [
          for (var t in state.selectedTodos)
            t.copyDiff(selected: false, completion: false)
        ],
      );
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListSelectionDeleted(
    TodoListSelectionDeleted event,
    Emitter<TodoListState> emit,
  ) async {
    emit(state.loading());
    try {
      // Re-read file and update state manually before write the changes.
      await _repository.readFromSource();
      _repository.deleteMultipleTodos(
        [
          for (var t in state.selectedTodos.toList()) t.copyWith(),
        ],
      );
      await _repository
          .writeToSource()
          .whenComplete(() => emit(state.success()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListOrderChanged(
    TodoListOrderChanged event,
    Emitter<TodoListState> emit,
  ) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(order: event.order),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListFilterChanged(
    TodoListFilterChanged event,
    Emitter<TodoListState> emit,
  ) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(filter: event.filter),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void _onTodoListGroupByChanged(
    TodoListGroupByChanged event,
    Emitter<TodoListState> emit,
  ) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(groupBy: event.groupBy),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
