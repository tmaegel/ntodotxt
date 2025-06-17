import 'package:equatable/equatable.dart';
import 'package:ntodotxt/todo/model/todo_model.dart'
    show Priorities, Priority, Todo;

enum ListOrder {
  ascending,
  descending,
}

enum ListFilter {
  all,
  completedOnly,
  incompletedOnly,
}

enum ListGroup {
  none,
  upcoming,
  priority,
  project,
  context,
}

extension Order on ListOrder {
  static Set<ListOrder> get types => {
        for (var t in ListOrder.values) t,
      };

  static ListOrder byName(String? name) {
    if (name != null) {
      try {
        return ListOrder.values.byName(name);
      } on ArgumentError {
        // Returns ListOrder.ascending
      }
    }

    return ListOrder.ascending;
  }

  // A negative integer if a is smaller than b,
  // zero if a is equal to b, and
  // a positive integer if a is greater than b.
  int _sort<T>(T a, T b) {
    switch (this) {
      case ListOrder.ascending:
        return ascending(a, b);
      // return a.toString().compareTo(b.toString());
      case ListOrder.descending:
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
    if (a is Todo && b is Todo) {
      return a.description.toLowerCase().compareTo(b.description.toLowerCase());
    } else {
      return a.toString().compareTo(b.toString());
    }
  }

  int descending<T>(T a, T b) {
    if (a == null) {
      return -1;
    }
    if (b == null) {
      return 1;
    }
    if (a is Todo && b is Todo) {
      return b.description.toLowerCase().compareTo(a.description.toLowerCase());
    } else {
      return b.toString().compareTo(a.toString());
    }
  }

  Iterable<T> sort<T>(Iterable<T> list) => list.toList()..sort(_sort);
}

extension Filters on ListFilter {
  static Set<ListFilter> get types => {
        for (var f in ListFilter.values) f,
      };

  static ListFilter byName(String? name) {
    if (name != null) {
      try {
        return ListFilter.values.byName(name);
      } on ArgumentError {
        // Returns ListFilter.all
      }
    }

    return ListFilter.all;
  }

  bool _apply(Todo todo) {
    switch (this) {
      case ListFilter.all:
        return true;
      case ListFilter.completedOnly:
        return todo.completion;
      case ListFilter.incompletedOnly:
        return !todo.completion;
      default:
        // Default is all.
        return true;
    }
  }

  Iterable<Todo> apply(Iterable<Todo> todoList) => todoList.where(_apply);
}

extension Groups on ListGroup {
  static Set<ListGroup> get types => {
        for (var g in ListGroup.values) g,
      };

  static ListGroup byName(String? name) {
    if (name != null) {
      try {
        return ListGroup.values.byName(name);
      } on ArgumentError {
        // Returns ListGroup.none
      }
    }

    return ListGroup.none;
  }

  Map<String, Iterable<Todo>> groupByNone({
    required Iterable<Todo> todoList,
  }) {
    Map<String, Iterable<Todo>> groups = {'All': todoList};
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }

  Map<String, Iterable<Todo>> groupByUpcoming({
    required Iterable<Todo> todoList,
  }) {
    Map<String, Iterable<Todo>> groups = {
      'Deadline passed': todoList.where(
        (Todo t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) < 0) ? true : false;
        },
      ),
      'Today': todoList.where(
        (Todo t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) == 0) ? true : false;
        },
      ),
      'Upcoming': todoList.where(
        (Todo t) {
          DateTime? due = t.dueDate;
          return (due != null && Todo.compareToToday(due) > 0) ? true : false;
        },
      ),
      'No deadline': todoList.where(
        (Todo t) => t.dueDate == null,
      ),
    };
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }

  Map<String, Iterable<Todo>> groupByPriority({
    required Iterable<Todo> todoList,
    required Set<Priority> sections,
  }) {
    Map<String, Iterable<Todo>> groups = {};
    for (var p in sections) {
      final Iterable<Todo> items = todoList.where((Todo t) => t.priority == p);
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
        items = todoList.where((Todo t) => t.projects.isEmpty);
      } else {
        items = todoList.where((Todo t) => t.projects.contains(p));
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
        items = todoList.where((Todo t) => t.contexts.isEmpty);
      } else {
        items = todoList.where((Todo t) => t.contexts.contains(c));
      }
      if (items.isNotEmpty) {
        groups[c ?? 'No context'] = items;
      }
    }
    groups.removeWhere((k, v) => v.isEmpty); // Remove empty sections.

    return groups;
  }
}

class Filter extends Equatable {
  final int? id;
  final String name;
  final Set<Priority> priorities;
  final Set<String> projects;
  final Set<String> contexts;
  final ListOrder order;
  final ListFilter filter;
  final ListGroup group;

  const Filter({
    this.id,
    this.name = '',
    this.priorities = const {},
    this.projects = const {},
    this.contexts = const {},
    this.order = ListOrder.ascending,
    this.filter = ListFilter.all,
    this.group = ListGroup.none,
  });

  factory Filter.fromMap(Map<dynamic, dynamic> map) {
    return Filter(
      id: map['id'] as int,
      name: map['name'] as String,
      priorities: {
        for (var p in map['priorities'].split(',')..sort())
          if (p != null && p.isNotEmpty) Priorities.byName(p)
      },
      projects: {
        for (var p in map['projects'].split(',')..sort())
          if (p != null && p.isNotEmpty) p,
      },
      contexts: {
        for (var c in map['contexts'].split(',')..sort())
          if (c != null && c.isNotEmpty) c,
      },
      order: Order.byName(map['order']),
      filter: Filters.byName(map['filter']),
      group: Groups.byName(map['group']),
    );
  }

  static String get tableRepr {
    return '''CREATE TABLE IF NOT EXISTS filters(
      `id` INTEGER PRIMARY KEY,
      `name` TEXT NOT NULL,
      `priorities` TEXT,
      `projects` TEXT,
      `contexts` TEXT,
      `order` TEXT,
      `filter` TEXT,
      `group` TEXT
    )''';
  }

  Iterable<Todo> apply(List<Todo> todoList) {
    Iterable<Todo> filtered = filter.apply(todoList);
    if (priorities.isNotEmpty) {
      filtered = filtered.where(_applyPriority);
    }
    if (projects.isNotEmpty) {
      filtered = filtered.where(_applyProject);
    }
    if (contexts.isNotEmpty) {
      filtered = filtered.where(_applyContext);
    }

    // Completed todos come always at last.
    filtered = order.sort(filtered);
    return (filtered.where((Todo t) => !t.completion).toList() +
        filtered.where((Todo t) => t.completion).toList());
  }

  bool _applyPriority(Todo todo) => priorities.contains(todo.priority);

  bool _applyProject(Todo todo) {
    for (String p in projects) {
      if (todo.projects.contains(p)) {
        return true;
      }
    }
    return false;
  }

  bool _applyContext(Todo todo) {
    for (String c in contexts) {
      if (todo.contexts.contains(c)) {
        return true;
      }
    }
    return false;
  }

  Map<String, Iterable<Todo>> grouped(Iterable<Todo> todoList) {
    switch (group) {
      case ListGroup.none:
        return group.groupByNone(todoList: todoList);
      case ListGroup.upcoming:
        return group.groupByUpcoming(todoList: todoList);
      case ListGroup.priority:
        return group.groupByPriority(
          todoList: todoList,
          sections: order.sort(Priority.values).toSet(),
        );
      case ListGroup.project:
        final Set<String> projects =
            todoList.map((Todo todo) => todo.projects).fold<Set<String>>(
          {},
          (Set<String> previousValue, Set<String> value) {
            return previousValue..addAll(value);
          },
        );
        return group.groupByProject(
          todoList: todoList,
          sections: order.sort(projects).toSet(),
        );
      case ListGroup.context:
        Set<String> contexts =
            todoList.map((Todo todo) => todo.contexts).fold<Set<String>>(
          {},
          (Set<String> previousValue, Set<String> value) {
            return previousValue..addAll(value);
          },
        );
        return group.groupByContext(
          todoList: todoList,
          sections: order.sort(contexts).toSet(),
        );
      default:
        // Default is none.
        return group.groupByNone(todoList: todoList);
    }
  }

  Filter copyWith({
    int? id,
    String? name,
    Set<Priority>? priorities,
    Set<String>? projects,
    Set<String>? contexts,
    ListOrder? order,
    ListFilter? filter,
    ListGroup? group,
  }) {
    return Filter(
      id: id ?? this.id,
      name: name ?? this.name,
      priorities: Priorities.sort(priorities ?? this.priorities),
      projects: projects != null
          ? (projects.toList()..sort()).toSet()
          : this.projects,
      contexts: contexts != null
          ? (contexts.toList()..sort()).toSet()
          : this.contexts,
      order: order ?? this.order,
      filter: filter ?? this.filter,
      group: group ?? this.group,
    );
  }

  Filter copyWithUnsaved({
    Set<Priority>? priorities,
    Set<String>? projects,
    Set<String>? contexts,
    ListOrder? order,
    ListFilter? filter,
    ListGroup? group,
  }) {
    return Filter(
      priorities: priorities ?? this.priorities,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      order: order ?? this.order,
      filter: filter ?? this.filter,
      group: group ?? this.group,
    );
  }

  /// Convert a [Filter] into Map.
  /// The keys must correspond to the names of the
  /// columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'priorities': [for (var p in priorities) p.name].join(','),
      'projects': projects.join(','),
      'contexts': contexts.join(','),
      'order': order.name,
      'filter': filter.name,
      'group': group.name,
    };
  }

  @override
  String toString() {
    return 'Filter { id: $id, name: $name order: ${order.name} filter: ${filter.name} group: ${group.name} priorities: ${[
      for (var p in priorities) p.name
    ]} projects: ${[for (var p in projects) p]} contexts: ${[
      for (var c in contexts) c
    ]} }';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        priorities,
        projects,
        contexts,
        order,
        filter,
        group,
      ];
}
