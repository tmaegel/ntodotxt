import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart'
    show TodoListRepository;
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final TodoListRepository _repository;

  TodoListBloc({
    required TodoListRepository repository,
  })  : _repository = repository,
        super(const TodoListInitial()) {
    on<TodoListSubscriptionRequested>(_onTodoListSubscriptionRequested);
    on<TodoListSynchronizationRequested>(_onTodoListSynchronizationRequested);
    on<TodoListTodoSubmitted>(_onTodoSubmitted);
    on<TodoListTodoDeleted>(_onTodoDeleted);
    on<TodoListTodoCompletionToggled>(_onTodoCompletionToggled);
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
}
