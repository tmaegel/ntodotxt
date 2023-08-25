import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

enum TodoListStatus {
  initial,
  loading,
  success,
  failure,
}

enum TodoListFilter {
  all,
  completedOnly,
  incompletedOnly,
}

enum TodoListOrder {
  ascending,
  descending,
}

enum TodoListGroupBy {
  upcoming,
  priority,
  project,
  context,
}

extension TodoFilter on TodoListFilter {
  bool _apply(Todo todo) {
    switch (this) {
      case TodoListFilter.all:
        return true;
      case TodoListFilter.completedOnly:
        return todo.completion;
      case TodoListFilter.incompletedOnly:
        return !todo.completion;
      default:
        // Default is all.
        return true;
    }
  }

  Iterable<Todo> apply(Iterable<Todo> todoList) {
    return todoList.where(_apply);
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

extension TodoOrder on TodoListOrder {
  // A negative integer if a is smaller than b,
  // zero if a is equal to b, and
  // a positive integer if a is greater than b.
  int _sort<T>(T a, T b) {
    switch (this) {
      case TodoListOrder.ascending:
        return ascending(a, b);
      // return a.toString().compareTo(b.toString());
      case TodoListOrder.descending:
        return descending(a, b);
      default:
        // Default is ascending.
        return ascending(a, b);
    }
  }

  int ascending<T>(T a, T b) {
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return a.toString().compareTo(b.toString());
  }

  int descending<T>(T a, T b) {
    if (a == null) {
      return -1;
    }
    if (b == null) {
      return 1;
    }
    return b.toString().compareTo(a.toString());
  }

  Iterable<T> sort<T>(Iterable<T> todoList) => todoList.toList()..sort(_sort);
}

extension TodoGroupBy on TodoListGroupBy {
  // Map<String, Iterable<Todo>> _groupByUpcoming(Iterable<Todo> todoList) {}

  Map<String, Iterable<Todo>?> priority({
    required Iterable<Todo> todoList,
    required List<String?> sections,
  }) {
    Map<String, Iterable<Todo>> groupBy = {};
    for (var p in sections) {
      final Iterable<Todo> items =
          todoList.where((todo) => todo.priority == p && !todo.completion);
      if (items.isNotEmpty) {
        groupBy[p ?? 'No priority'] = items;
      }
    }

    return _appendCompleted(groupBy: groupBy, todoList: todoList);
  }

  Map<String, Iterable<Todo>> project({
    required Iterable<Todo> todoList,
    required List<String?> sections,
  }) {
    Map<String, Iterable<Todo>> groupBy = {};
    // Consider also todos without projects.
    for (var p in [...sections, null]) {
      Iterable<Todo> items;
      if (p == null) {
        items =
            todoList.where((todo) => todo.projects.isEmpty && !todo.completion);
      } else {
        items = todoList
            .where((todo) => todo.projects.contains(p) && !todo.completion);
      }
      if (items.isNotEmpty) {
        groupBy[p ?? 'No project'] = items;
      }
    }

    return _appendCompleted(groupBy: groupBy, todoList: todoList);
  }

  Map<String, Iterable<Todo>> context({
    required Iterable<Todo> todoList,
    required List<String?> sections,
  }) {
    Map<String, Iterable<Todo>> groupBy = {};
    // Consider also todos without projects.
    for (var c in [...sections, null]) {
      Iterable<Todo> items;
      if (c == null) {
        items =
            todoList.where((todo) => todo.contexts.isEmpty && !todo.completion);
      } else {
        items = todoList
            .where((todo) => todo.contexts.contains(c) && !todo.completion);
      }
      if (items.isNotEmpty) {
        groupBy[c ?? 'No context'] = items;
      }
    }

    return _appendCompleted(groupBy: groupBy, todoList: todoList);
  }

  Map<String, Iterable<Todo>> _appendCompleted({
    required Map<String, Iterable<Todo>> groupBy,
    required Iterable<Todo> todoList,
  }) {
    // Add completed items last.
    final Iterable<Todo> completedItems =
        todoList.where((todo) => todo.completion);
    if (completedItems.isNotEmpty) {
      groupBy['Done'] = completedItems;
    }

    return groupBy;
  }
}

final class TodoListState extends Equatable {
  final TodoListStatus status;
  final TodoListFilter filter;
  final TodoListOrder order;
  final TodoListGroupBy groupBy;
  final List<Todo> todoList;

  const TodoListState({
    this.status = TodoListStatus.initial,
    this.filter = TodoListFilter.all,
    this.order = TodoListOrder.ascending,
    this.groupBy = TodoListGroupBy.priority,
    this.todoList = const [],
  });

  /// Returns a list with all priorities including 'no priority' of all todos.
  List<String?> get priorities {
    List<String?> priorities = [];
    for (var todo in filteredTodoList) {
      priorities.add(todo.priority);
    }

    return order.sort(priorities.toSet().toList()).toList();
  }

  /// Returns a list with all projects of all todos.
  List<String> get projects {
    List<String> projects = [];
    for (var todo in filteredTodoList) {
      projects = projects + todo.projects;
    }

    return order.sort(projects.toSet().toList()).toList();
  }

  /// Returns a list with all contexts of all todos.
  List<String> get contexts {
    List<String> contexts = [];
    for (var todo in filteredTodoList) {
      contexts = contexts + todo.contexts;
    }

    return order.sort(contexts.toSet().toList()).toList();
  }

  /// Returns a list with all key values of all todos.
  List<String> get keyValues {
    List<String> keyValues = [];
    for (var todo in filteredTodoList) {
      keyValues = keyValues + todo.formattedKeyValues;
    }

    return order.sort(keyValues.toSet().toList()).toList();
  }

  Iterable<Todo> get filteredTodoList => order.sort(filter.apply(todoList));

  Map<String, Iterable<Todo>?> get groupedByTodoList {
    switch (groupBy) {
      // case TodoListGroupBy.upcoming:
      // return groupBy.priority(filteredTodoList);
      case TodoListGroupBy.priority:
        return groupBy.priority(
          todoList: filteredTodoList,
          sections: priorities,
        );
      case TodoListGroupBy.project:
        return groupBy.project(
          todoList: filteredTodoList,
          sections: projects,
        );
      case TodoListGroupBy.context:
        return groupBy.context(
          todoList: filteredTodoList,
          sections: contexts,
        );
      default:
        // Default is priority.
        return groupBy.priority(
          todoList: filteredTodoList,
          sections: priorities,
        );
    }
  }

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
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? groupBy,
    List<Todo>? todoList,
  }) {
    return TodoListState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      order: order ?? this.order,
      groupBy: groupBy ?? this.groupBy,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        status,
        todoList,
        filter,
        order,
        groupBy,
      ];

  @override
  String toString() =>
      'TodoListState { status: $status filter: $filter order: $order groupBy: $groupBy }';
}
