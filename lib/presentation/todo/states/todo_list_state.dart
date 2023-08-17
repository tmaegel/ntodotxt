import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

enum TodoListStatus {
  initial,
  loading,
  success,
  failure,
}

enum TodoFilter {
  all,
  completedOnly,
  incompletedOnly,
}

extension TodoListFilter on TodoFilter {
  bool applyFilter(Todo todo) {
    switch (this) {
      case TodoFilter.all:
        return true;
      case TodoFilter.completedOnly:
        return todo.completion;
      case TodoFilter.incompletedOnly:
        return !todo.completion;
      default:
        return true;
    }
  }

  Iterable<Todo> apply(Iterable<Todo> todoList) {
    return todoList.where(applyFilter);
  }

  /// Return todo list filtered by priority.
  Iterable<Todo> applyPriority(Iterable<Todo> todoList, String? priority) {
    return todoList.where((todo) => (priority == todo.priority));
  }

  Iterable<Todo> applyPriorityExcludeCompleted(
      Iterable<Todo> todoList, String? priority) {
    return todoList
        .where((todo) => (priority == todo.priority && !todo.completion));
  }

  /// Return todo list filtered by completion state.
  Iterable<Todo> applyCompletion(Iterable<Todo> todoList, bool completion) {
    return todoList.where((todo) => (todo.completion == completion));
  }
}

final class TodoListState extends Equatable {
  final TodoListStatus status;
  final List<Todo> todoList;
  final TodoFilter filter;

  const TodoListState({
    this.status = TodoListStatus.initial,
    this.todoList = const [],
    this.filter = TodoFilter.all,
  });

  Iterable<Todo> get filteredTodoList => filter.apply(todoList);

  /// Return todo list filtered by completion state.
  Iterable<Todo> get filteredByCompleted =>
      filter.applyCompletion(filteredTodoList, true);
  Iterable<Todo> get filteredByIncompleted =>
      filter.applyCompletion(filteredTodoList, false);

  /// Return todo list filtered by priority.
  Iterable<Todo> filteredByPriority({
    required String? priority,
    bool excludeCompleted = true,
  }) {
    return excludeCompleted
        ? filter.applyPriorityExcludeCompleted(filteredTodoList, priority)
        : filter.applyPriority(filteredTodoList, priority);
  }

  TodoListState copyWith({
    TodoListStatus? status,
    List<Todo>? todoList,
    TodoFilter? filter,
  }) {
    return TodoListState(
      status: status ?? this.status,
      todoList: todoList ?? this.todoList,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        todoList,
        filter,
      ];

  @override
  String toString() => 'TodoListState { status: $status filter: $filter }';
}
