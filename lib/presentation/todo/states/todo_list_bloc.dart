import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/main.dart' show log;
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcher/watcher.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final TodoListRepository _repository;

  TodoListBloc({
    SharedPreferences? prefs,
    required TodoListRepository repository,
  })  : _repository = repository,
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
    // Watch for changes to the source to propagate errors to the ui.
    _repository.watchSource().listen(
      (WatchEvent event) async {
        try {
          if (event.type == ChangeType.MODIFY) {
            log.info('The file ${event.path} has been modified.');
            // No whenComplete callback here. The state is changed down below.
            await _repository.readFromSource();
          }
        } on Exception catch (e) {
          emit(state.error(
            message: 'Malformed todo: ${e.toString()}',
          ));
        }
      },
    );
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
      await _repository
          .readFromSource()
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
      final Todo todo = event.todo.copyWith(
        completion: event.completion,
        completionDate: event.completion ? DateTime.now() : null,
        unsetCompletionDate: !event.completion,
      );
      _repository.saveTodo(todo);
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
      final Todo todo = event.todo.copyWith();
      _repository.saveTodo(todo);
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
      final Todo todo = event.todo.copyWith();
      _repository.deleteTodo(todo);
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
      final Todo todo = event.todo.copyWith(
        selected: event.selected,
      );
      _repository.saveTodo(todo);
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
          for (var t in state.todoList)
            t.copyWith(
              selected: true,
            ),
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
          for (var t in state.todoList)
            t.copyWith(
              selected: false,
            ),
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
      _repository.saveMultipleTodos(
        [
          for (var t in state.selectedTodos)
            t.copyWith(
              selected: false,
              completion: true,
              completionDate: DateTime.now(),
            )
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
      _repository.saveMultipleTodos(
        [
          for (var t in state.selectedTodos)
            t.copyWith(
              selected: false,
              completion: false,
              unsetCompletionDate: true,
            )
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
      _repository.deleteMultipleTodos(
        state.selectedTodos.toList(),
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
