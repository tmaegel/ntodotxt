import 'package:equatable/equatable.dart';
import 'package:ntodotxt/filter/model/filter_model.dart';
import 'package:ntodotxt/todo/model/todo_model.dart';

sealed class TodoListState extends Equatable {
  final List<Todo> todoList;

  const TodoListState({
    this.todoList = const [],
  });

  /// Returns a list with all projects of all todos.
  Set<String> get projects {
    // @todo: Sort
    return todoList.map((Todo todo) => todo.projects).fold<Set<String>>(
      {},
      (Set<String> previousValue, Set<String> value) =>
          previousValue..addAll(value),
    );
  }

  /// Returns a list with all contexts of all todos.
  Set<String> get contexts {
    // @todo: Sort
    return todoList.map((Todo todo) => todo.contexts).fold<Set<String>>(
      {},
      (Set<String> previousValue, Set<String> value) =>
          previousValue..addAll(value),
    );
  }

  /// Returns a list with all key values of all todos.
  Set<String> get keyValues {
    // @todo: Sort
    return todoList.map((Todo todo) => todo.fmtKeyValues).fold<Set<String>>(
      {},
      (Set<String> previousValue, Set<String> value) =>
          previousValue..addAll(value),
    );
  }

  Iterable<Todo> filteredTodoList(Filter filter) => filter.apply(todoList);

  Map<String, Iterable<Todo>> groupedTodoList(Filter filter) =>
      filter.grouped(filteredTodoList(filter));

  TodoListState copyWith({
    List<Todo>? todoList,
  });

  TodoListState loading({
    List<Todo>? todoList,
  }) {
    return TodoListLoading(
      todoList: todoList ?? this.todoList,
    );
  }

  TodoListState success({
    List<Todo>? todoList,
  }) {
    return TodoListSuccess(
      todoList: todoList ?? this.todoList,
    );
  }

  TodoListState error({
    required String message,
    List<Todo>? todoList,
  }) {
    return TodoListError(
      message: message,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        todoList,
      ];

  @override
  String toString() => 'TodoListState { }';
}

final class TodoListLoading extends TodoListState {
  const TodoListLoading({
    super.todoList,
  });

  @override
  TodoListLoading copyWith({
    List<Todo>? todoList,
  }) {
    return TodoListLoading(
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() =>
      'TodoListLoading { todos: ${[for (var t in todoList) t]} }';
}

final class TodoListSuccess extends TodoListState {
  const TodoListSuccess({
    super.todoList,
  });

  @override
  TodoListSuccess copyWith({
    List<Todo>? todoList,
  }) {
    return TodoListSuccess(
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() =>
      'TodoListSuccess { todos: ${[for (var t in todoList) t]} }';
}

final class TodoListError extends TodoListState {
  final String message;

  const TodoListError({
    required this.message,
    super.todoList,
  });

  @override
  TodoListError copyWith({
    String? message,
    List<Todo>? todoList,
  }) {
    return TodoListError(
      message: message ?? this.message,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        message,
        todoList,
      ];

  @override
  String toString() => 'TodoListError { message: $message }';
}
