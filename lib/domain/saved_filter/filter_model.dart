import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart'
    show TodoListGroupBy, TodoListOrder;

class Filter extends Equatable {
  final int? id;
  final String name;
  final Set<Priority> priorities;
  final Set<String> projects;
  final Set<String> contexts;
  final TodoListOrder order;
  final TodoListGroupBy groupBy;

  const Filter({
    this.id,
    this.name = '',
    this.priorities = const {},
    this.projects = const {},
    this.contexts = const {},
    this.order = TodoListOrder.ascending,
    this.groupBy = TodoListGroupBy.none,
  });

  static String get tableRepr {
    return '''CREATE TABLE saved_filters(
      `id` INTEGER PRIMARY KEY,
      `name` TEXT,
      `priorities` TEXT,
      `projects` TEXT,
      `contexts` TEXT,
      `order` TEXT,
      `groupBy` TEXT
    )''';
  }

  Filter copyWith({
    int? id,
    String? name,
    Set<Priority>? priorities,
    Set<String>? projects,
    Set<String>? contexts,
    TodoListOrder? order,
    TodoListGroupBy? groupBy,
  }) {
    return Filter(
      id: id ?? this.id,
      name: name ?? this.name,
      priorities: priorities ?? this.priorities,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      order: order ?? this.order,
      groupBy: groupBy ?? this.groupBy,
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
      'groupBy': groupBy.name,
    };
  }

  @override
  String toString() {
    return 'Filter { id: $id, name: $name order: ${order.name} groupBy: ${groupBy.name} priorities: ${[
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
        groupBy,
      ];
}
