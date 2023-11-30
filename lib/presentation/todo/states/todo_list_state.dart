import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
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
  Map<String, Iterable<Todo>> groupByUpcoming({
    required Iterable<Todo> todoList,
  }) {
    final Iterable<Todo> incompletedTodoList =
        todoList.where((t) => !t.completion);
    Map<String, Iterable<Todo>> groups = {
      'Deadline passed': incompletedTodoList.where(
        (t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) < 0) ? true : false;
        },
      ),
      'Today': incompletedTodoList.where(
        (t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) == 0) ? true : false;
        },
      ),
      'Upcoming': incompletedTodoList.where(
        (t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) > 0) ? true : false;
        },
      ),
      'No deadline': incompletedTodoList.where(
        (t) => t.dueDate == null,
      ),
    };

    return _appendCompleted(groups: groups, todoList: todoList);
  }

  Map<String, Iterable<Todo>?> groupByPriority({
    required Iterable<Todo> todoList,
    required Set<String?> sections,
  }) {
    Map<String, Iterable<Todo>> groups = {};
    for (var p in sections) {
      final Iterable<Todo> items =
          todoList.where((t) => t.priority == p && !t.completion);
      if (items.isNotEmpty) {
        groups[p ?? 'No priority'] = items;
      }
    }

    return _appendCompleted(groups: groups, todoList: todoList);
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
        items = todoList.where((t) => t.projects.isEmpty && !t.completion);
      } else {
        items = todoList.where((t) => t.projects.contains(p) && !t.completion);
      }
      if (items.isNotEmpty) {
        groups[p ?? 'No project'] = items;
      }
    }

    return _appendCompleted(groups: groups, todoList: todoList);
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
        items = todoList.where((t) => t.contexts.isEmpty && !t.completion);
      } else {
        items = todoList.where((t) => t.contexts.contains(c) && !t.completion);
      }
      if (items.isNotEmpty) {
        groups[c ?? 'No context'] = items;
      }
    }

    return _appendCompleted(groups: groups, todoList: todoList);
  }

  Map<String, Iterable<Todo>> _appendCompleted({
    required Map<String, Iterable<Todo>> groups,
    required Iterable<Todo> todoList,
  }) {
    // Add completed items last.
    final Iterable<Todo> completedItems = todoList.where((t) => t.completion);
    if (completedItems.isNotEmpty) {
      groups['Done'] = completedItems;
    }

    return groups;
  }
}

sealed class TodoListState extends Equatable {
  final TodoListFilter filter;
  final TodoListOrder order;
  final TodoListGroupBy group;
  final List<Todo> todoList;

  const TodoListState({
    this.filter = TodoListFilter.all,
    this.order = TodoListOrder.ascending,
    this.group = TodoListGroupBy.upcoming,
    this.todoList = const [],
  });

  /// Returns a list with all priorities including 'no priority' of all todos.
  Set<String?> get priorities {
    Set<String?> priorities = {};
    for (var todo in filteredTodoList) {
      priorities.add(todo.priority);
    }

    return order.sort(priorities).toSet();
  }

  /// Returns a list with all projects of all todos.
  Set<String> get projects {
    Set<String> projects = {};
    for (var todo in filteredTodoList) {
      projects.addAll(todo.projects);
    }

    return order.sort(projects).toSet();
  }

  /// Returns a list with all contexts of all todos.
  Set<String> get contexts {
    Set<String> contexts = {};
    for (var todo in filteredTodoList) {
      contexts.addAll(todo.contexts);
    }

    return order.sort(contexts).toSet();
  }

  /// Returns a list with all key values of all todos.
  Set<String> get keyValues {
    Set<String> keyValues = {};
    for (var todo in filteredTodoList) {
      keyValues.addAll(todo.formattedKeyValues);
    }

    return order.sort(keyValues).toSet();
  }

  /// Returns true if at least one todo is selected, otherwise false.
  bool get isSelected =>
      todoList.firstWhereOrNull((todo) => todo.selected) != null;

  /// Returns true if selected todos are completed only.
  bool get isSelectedCompleted =>
      selectedTodos.firstWhereOrNull((todo) => !todo.completion) == null;

  /// Returns true if selected todos are incompleted only.
  bool get isSelectedIncompleted =>
      selectedTodos.firstWhereOrNull((todo) => todo.completion) == null;

  Iterable<Todo> get selectedTodos => todoList.where((t) => t.selected);

  Iterable<Todo> get unselectedTodos => todoList.where((t) => !t.selected);

  Iterable<Todo> get filteredTodoList => order.sort(filter.apply(todoList));

  Map<String, Iterable<Todo>?> get groupedByTodoList {
    switch (group) {
      case TodoListGroupBy.upcoming:
        return group.groupByUpcoming(
          todoList: filteredTodoList,
        );
      case TodoListGroupBy.priority:
        return group.groupByPriority(
          todoList: filteredTodoList,
          sections: priorities,
        );
      case TodoListGroupBy.project:
        return group.groupByProject(
          todoList: filteredTodoList,
          sections: projects,
        );
      case TodoListGroupBy.context:
        return group.groupByContext(
          todoList: filteredTodoList,
          sections: contexts,
        );
      default:
        // Default is upcoming.
        return group.groupByUpcoming(
          todoList: filteredTodoList,
        );
    }
  }

  TodoListState copyWith({
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  });

  TodoListState loading({
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListLoading(
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  TodoListState success({
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListSuccess(
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  TodoListState error({
    required String message,
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListError(
      message: message,
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        filter,
        order,
        group,
        todoList,
      ];

  @override
  String toString() =>
      'TodoListState { filter: ${filter.name} order: ${order.name} group: ${group.name} }';
}

final class TodoListInitial extends TodoListState {
  const TodoListInitial({
    super.filter,
    super.order,
    super.group,
    super.todoList,
  });

  @override
  TodoListInitial copyWith({
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListInitial(
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() =>
      'TodoListInitial { filter: ${filter.name} order: ${order.name} group: ${group.name} }';
}

final class TodoListLoading extends TodoListState {
  const TodoListLoading({
    super.filter,
    super.order,
    super.group,
    super.todoList,
  });

  @override
  TodoListLoading copyWith({
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListLoading(
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() =>
      'TodoListLoading { filter: ${filter.name} order: ${order.name} group: ${group.name} todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
}

final class TodoListSuccess extends TodoListState {
  const TodoListSuccess({
    super.filter,
    super.order,
    super.group,
    super.todoList,
  });

  @override
  TodoListSuccess copyWith({
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListSuccess(
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  String toString() =>
      'TodoListSuccess { filter: ${filter.name} order: ${order.name} group: ${group.name} todos: ${[
        for (var t in todoList) '$t ${t.selected}'
      ]} }';
}

final class TodoListError extends TodoListState {
  final String message;

  const TodoListError({
    required this.message,
    super.filter,
    super.order,
    super.group,
    super.todoList,
  });

  @override
  TodoListError copyWith({
    String? message,
    TodoListFilter? filter,
    TodoListOrder? order,
    TodoListGroupBy? group,
    List<Todo>? todoList,
  }) {
    return TodoListError(
      message: message ?? this.message,
      filter: filter ?? this.filter,
      order: order ?? this.order,
      group: group ?? this.group,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        message,
        filter,
        order,
        group,
        todoList,
      ];

  @override
  String toString() =>
      'TodoListError { message: $message filter: ${filter.name} order: ${order.name} group: ${group.name} }';
}
