import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

enum TodoListStatus {
  initial,
  loading,
  success,
  error,
}

sealed class TodoListState extends Equatable {
  final Filter filter;
  final List<Todo> todoList;

  const TodoListState({
    this.filter = const Filter(), // Default
    this.todoList = const [],
  });

  /// Returns a list with all priorities
  /// including 'Priority.none' of all todos.
  Set<Priority> get priorities {
    Set<Priority> priorities = {};
    for (var todo in filteredTodoList) {
      priorities.add(todo.priority);
    }

    return filter.order.sort(priorities).toSet();
  }

  /// Returns a list with all projects of all todos.
  Set<String> get projects {
    Set<String> projects = {};
    for (var todo in filteredTodoList) {
      projects.addAll(todo.projects);
    }

    return filter.order.sort(projects).toSet();
  }

  /// Returns a list with all contexts of all todos.
  Set<String> get contexts {
    Set<String> contexts = {};
    for (var todo in filteredTodoList) {
      contexts.addAll(todo.contexts);
    }

    return filter.order.sort(contexts).toSet();
  }

  /// Returns a list with all key values of all todos.
  Set<String> get keyValues {
    Set<String> keyValues = {};
    for (var todo in filteredTodoList) {
      keyValues.addAll(todo.fmtKeyValues);
    }

    return filter.order.sort(keyValues).toSet();
  }

  /// Returns true if at least one todo is selected, otherwise false.
  bool get isAnySelected =>
      todoList.firstWhereOrNull((todo) => todo.selected) != null;

  /// Returns true if selected todos are completed only.
  bool get isSelectedCompleted =>
      selectedTodos.firstWhereOrNull((todo) => !todo.completion) == null;

  /// Returns true if selected todos are incompleted only.
  bool get isSelectedIncompleted =>
      selectedTodos.firstWhereOrNull((todo) => todo.completion) == null;

  Iterable<Todo> get selectedTodos => todoList.where((t) => t.selected);

  Iterable<Todo> get unselectedTodos => todoList.where((t) => !t.selected);

  Iterable<Todo> get filteredTodoList =>
      filter.order.sort(filter.filter.apply(todoList));

  Map<String, Iterable<Todo>> get groupedByTodoList {
    switch (filter.group) {
      case ListGroup.none:
        return filter.group.groupByNone(
          todoList: filteredTodoList,
        );
      case ListGroup.upcoming:
        return filter.group.groupByUpcoming(
          todoList: filteredTodoList,
        );
      case ListGroup.priority:
        return filter.group.groupByPriority(
          todoList: filteredTodoList,
          sections: priorities,
        );
      case ListGroup.project:
        return filter.group.groupByProject(
          todoList: filteredTodoList,
          sections: projects,
        );
      case ListGroup.context:
        return filter.group.groupByContext(
          todoList: filteredTodoList,
          sections: contexts,
        );
      default:
        // Default is none.
        return filter.group.groupByNone(
          todoList: filteredTodoList,
        );
    }
  }

  TodoListState copyWith({
    Filter? filter,
    List<Todo>? todoList,
  });

  TodoListState loading({
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListLoading(
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  TodoListState success({
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListSuccess(
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  TodoListState error({
    required String message,
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListError(
      message: message,
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        filter,
        todoList,
      ];

  @override
  String toString() => 'TodoListState { filter: $filter }';
}

final class TodoListInitial extends TodoListState {
  const TodoListInitial({
    super.filter,
    super.todoList,
  });

  @override
  TodoListInitial copyWith({
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListInitial(
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() => 'TodoListInitial { filter: $filter todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
}

final class TodoListLoading extends TodoListState {
  const TodoListLoading({
    super.filter,
    super.todoList,
  });

  @override
  TodoListLoading copyWith({
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListLoading(
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() => 'TodoListLoading { filter: $filter todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
}

final class TodoListSuccess extends TodoListState {
  const TodoListSuccess({
    super.filter,
    super.todoList,
  });

  @override
  TodoListSuccess copyWith({
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListSuccess(
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() => 'TodoListSuccess { filter: $filter todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
}

final class TodoListError extends TodoListState {
  final String message;

  const TodoListError({
    required this.message,
    super.filter,
    super.todoList,
  });

  @override
  TodoListError copyWith({
    String? message,
    Filter? filter,
    List<Todo>? todoList,
  }) {
    return TodoListError(
      message: message ?? this.message,
      filter: filter ?? this.filter,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        message,
        filter,
        todoList,
      ];

  @override
  String toString() => 'TodoListError { message: $message filter: $filter }';
}
