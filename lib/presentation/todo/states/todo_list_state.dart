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
  final List<Todo> todoList;

  const TodoListState({
    this.todoList = const [],
  });

  /// Returns a list with all projects of all todos.
  Set<String> get projects {
    Set<String> projects = {};
    for (var todo in todoList) {
      projects.addAll(todo.projects);
    }

    // @todo: Sort
    return projects.toSet();
  }

  /// Returns a list with all contexts of all todos.
  Set<String> get contexts {
    Set<String> contexts = {};
    for (var todo in todoList) {
      contexts.addAll(todo.contexts);
    }

    // @todo: Sort
    return contexts.toSet();
  }

  /// Returns a list with all key values of all todos.
  Set<String> get keyValues {
    Set<String> keyValues = {};
    for (var todo in todoList) {
      keyValues.addAll(todo.fmtKeyValues);
    }

    // @todo: Sort
    return keyValues.toSet();
  }

  /// Returns true if at least one todo is selected, otherwise false.
  bool get isAnySelected =>
      todoList.firstWhereOrNull((todo) => todo.selected) != null;

  /// Returns true if selected todos are completed only.
  bool get isSelectedCompleted =>
      selectedTodos.firstWhereOrNull((todo) => !todo.completion) == null;

  Iterable<Todo> get selectedTodos => todoList.where((t) => t.selected);

  Iterable<Todo> filteredTodoList(Filter filter) => filter.apply(todoList);

  Map<String, Iterable<Todo>> groupedTodoList(Filter filter) {
    switch (filter.group) {
      case ListGroup.none:
        return filter.group.groupByNone(
          todoList: filteredTodoList(filter),
        );
      case ListGroup.upcoming:
        return filter.group.groupByUpcoming(
          todoList: filteredTodoList(filter),
        );
      case ListGroup.priority:
        return filter.group.groupByPriority(
          todoList: filteredTodoList(filter),
          sections: filter.order.sort(Priority.values).toSet(),
        );
      case ListGroup.project:
        return filter.group.groupByProject(
          todoList: filteredTodoList(filter),
          sections: projects,
        );
      case ListGroup.context:
        return filter.group.groupByContext(
          todoList: filteredTodoList(filter),
          sections: contexts,
        );
      default:
        // Default is none.
        return filter.group.groupByNone(
          todoList: filteredTodoList(filter),
        );
    }
  }

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

final class TodoListInitial extends TodoListState {
  const TodoListInitial({
    super.todoList,
  });

  @override
  TodoListInitial copyWith({
    List<Todo>? todoList,
  }) {
    return TodoListInitial(
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() => 'TodoListInitial { todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
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
  String toString() => 'TodoListLoading { todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
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
  String toString() => 'TodoListSuccess { todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
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
