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
  none,
  upcoming,
  priority,
  project,
  context,
}

extension TodoFilter on TodoListFilter {
  static Set<TodoListFilter> get types => {
        for (var f in TodoListFilter.values) f,
      };

  static TodoListFilter byName(String name) {
    try {
      return TodoListFilter.values.byName(name);
    } on Exception {
      // Returns TodoListFilter.all
    }

    return TodoListFilter.all;
  }

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
  Iterable<Todo> applyPriority(Iterable<Todo> todoList, Priority? priority) {
    return todoList.where((todo) => (priority == todo.priority));
  }

  Iterable<Todo> applyPriorityExcludeCompleted(
      Iterable<Todo> todoList, Priority? priority) {
    return todoList
        .where((todo) => (priority == todo.priority && !todo.completion));
  }

  /// Return todo list filtered by completion state.
  Iterable<Todo> applyCompletion(Iterable<Todo> todoList, bool completion) {
    return todoList.where((todo) => (todo.completion == completion));
  }
}

extension TodoOrder on TodoListOrder {
  static Set<TodoListOrder> get types => {
        for (var t in TodoListOrder.values) t,
      };

  static TodoListOrder byName(String name) {
    try {
      return TodoListOrder.values.byName(name);
    } on Exception {
      // Returns TodoListOrder.ascending
    }

    return TodoListOrder.ascending;
  }

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
  static Set<TodoListGroupBy> get types => {
        for (var g in TodoListGroupBy.values) g,
      };

  static TodoListGroupBy byName(String name) {
    try {
      return TodoListGroupBy.values.byName(name);
    } on Exception {
      // Returns TodoListGroupBy.none
    }

    return TodoListGroupBy.none;
  }

  Map<String, Iterable<Todo>> groupByNone({
    required Iterable<Todo> todoList,
  }) {
    Map<String, Iterable<Todo>> groups = {'All': todoList};

    return groups;
  }

  Map<String, Iterable<Todo>> groupByUpcoming({
    required Iterable<Todo> todoList,
  }) {
    Map<String, Iterable<Todo>> groups = {
      'Deadline passed': todoList.where(
        (t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) < 0) ? true : false;
        },
      ),
      'Today': todoList.where(
        (t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) == 0) ? true : false;
        },
      ),
      'Upcoming': todoList.where(
        (t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) > 0) ? true : false;
        },
      ),
      'No deadline': todoList.where(
        (t) => t.dueDate == null,
      ),
    };
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }

  Map<String, Iterable<Todo>?> groupByPriority({
    required Iterable<Todo> todoList,
    required Set<Priority> sections,
  }) {
    Map<String, Iterable<Todo>> groups = {};
    for (var p in sections) {
      final Iterable<Todo> items = todoList.where((t) => t.priority == p);
      if (p == Priority.none) {
        groups['No priority'] = items;
      } else {
        groups[p.name] = items;
      }
    }
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }

  Map<String, Iterable<Todo>> groupByProject({
    required Iterable<Todo> todoList,
    required Set<String?> sections,
  }) {
    Map<String, Iterable<Todo>> groups = {};
    // Consider also todos without projects.
    for (var p in [...sections, null]) {
      Iterable<Todo> items;
      if (p == null) {
        items = todoList.where((t) => t.projects.isEmpty);
      } else {
        items = todoList.where((t) => t.projects.contains(p));
      }
      if (items.isNotEmpty) {
        groups[p ?? 'No project'] = items;
      }
    }
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }

  Map<String, Iterable<Todo>> groupByContext({
    required Iterable<Todo> todoList,
    required Set<String?> sections,
  }) {
    Map<String, Iterable<Todo>> groups = {};
    // Consider also todos without contexts.
    for (var c in [...sections, null]) {
      Iterable<Todo> items;
      if (c == null) {
        items = todoList.where((t) => t.contexts.isEmpty);
      } else {
        items = todoList.where((t) => t.contexts.contains(c));
      }
      if (items.isNotEmpty) {
        groups[c ?? 'No context'] = items;
      }
    }
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }
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

  Map<String, Iterable<Todo>?> get groupedByTodoList {
    switch (filter.groupBy) {
      case TodoListGroupBy.none:
        return filter.groupBy.groupByNone(
          todoList: filteredTodoList,
        );
      case TodoListGroupBy.upcoming:
        return filter.groupBy.groupByUpcoming(
          todoList: filteredTodoList,
        );
      case TodoListGroupBy.priority:
        return filter.groupBy.groupByPriority(
          todoList: filteredTodoList,
          sections: priorities,
        );
      case TodoListGroupBy.project:
        return filter.groupBy.groupByProject(
          todoList: filteredTodoList,
          sections: projects,
        );
      case TodoListGroupBy.context:
        return filter.groupBy.groupByContext(
          todoList: filteredTodoList,
          sections: contexts,
        );
      default:
        // Default is none.
        return filter.groupBy.groupByNone(
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
