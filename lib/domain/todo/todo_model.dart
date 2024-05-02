import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

enum Priority {
  none,
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
  I,
  J,
  K,
  L,
  M,
  N,
  O,
  P,
  Q,
  R,
  S,
  T,
  U,
  V,
  W,
  X,
  Y,
  Z
}

extension Priorities on Priority {
  static Set<Priority> get priorities => {
        for (var p in Priority.values)
          if (p != Priority.none) p,
      };

  static Set<String> get priorityNames => {
        for (var p in Priority.values)
          if (p != Priority.none) p.name,
      };

  static Priority byName(String name) {
    try {
      return Priority.values.byName(name);
    } on Exception {
      // Returns Priortity.none
    }

    return Priority.none;
  }

  static Set<Priority> sort(Set<Priority> priorities) {
    List<Priority> sorted = priorities.toList()
      ..sort(
        (Priority a, Priority b) => a.index.compareTo(b.index),
      );
    return sorted.toSet();
  }
}

///
/// Structure of a valid todo string
/// with some modification (https://github.com/todotxt/todo.txt/discussions/52)
///
/// [completion]      (optional)
/// [completionDate]  (forbidden if incompleted, mandatory if completed)
/// [priority]        (optional)
/// [creationDate]    (optional)
/// [
///
///   [fullDescription] (description + tags: projects, context, keyValues
///                      can be placed anywhere here)
///   [description]     (mandatory)
///   [projects]        (optional: preceded by a single space and a '+',
///                      contains any non-whitespace character)
///   [contexts]        (optional: preceded by a single space and a '@',
///                      contains any non-whitespace character)
///   [keyValues]       (optional: separated by a single colon,
///                      key value contains any non-whitespace character which are not colons)
/// ]
///
/// VALID examples:
///
/// Write some tests                        (When incomplete, no date is required)
/// 2019-07-01 Write some tests             (The provided date is the creation date)
/// x 2019-07-03 Write some test            (The provided date is the completion date)
/// x 2019-07-03 2019-07-01 Write some test (The provided dates are, in order, completion then creation)
///
/// INVALID examples:
///
/// 2019-07-03 2019-07-01 Write some tests  (The task is incomplete, so can't have a completion date)
/// x Write some tests                      (A completed task needs at least a completion date)
///
class Todo extends Equatable {
  static final RegExp patternWord = RegExp(r'^\S+$');
  // Limit priorities from A-F.
  static final RegExp patternPriority = RegExp(r'^\((?<priority>[A-Z])\)$');
  static final RegExp patternDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp patternProject = RegExp(r'^\+\S+$');
  static final RegExp patternContext = RegExp(r'^\@\S+$');
  // Prevent +, @ at the beginning and additional ':' within.
  static final RegExp patternKeyValue =
      RegExp(r'^([^\+\@].*[^:\s]):(.*[^:\s])$'); // @todo: a:b failed
  static final RegExp patternId = RegExp(r'^id:[a-zA-Z0-9\-]+$');

  /// Unique [id]
  /// [id] is mandatory.
  final String id;

  /// Whether the [Todo] is completed.
  /// Defaults to null (unset).
  final bool? _completion;

  /// The priority of the [Todo].
  /// Priorities are A, B, C, ...
  /// Defaults to null (empty, unset).
  final Priority? _priority;

  /// The completion date of the [Todo].
  /// Defaults to null (unset).
  final DateTime? _completionDate;

  /// The creation date of the [Todo].
  /// Defaults to null (unser).
  final DateTime? _creationDate;

  /// The description of the [Todo].
  /// Defaults to null (unset).
  final String? _description;

  String get fmtId => 'id:$id';

  /// Whether the [Todo] is completed.
  /// Defaults to false.
  bool get completion => _completion ?? false;

  String get fmtCompletion => completion ? 'x' : '';

  /// The priority of the [Todo].
  /// Allowed values are A, B, C, ... or null (no empty string).
  /// Empty string value is used to reset the priority.
  Priority get priority => _priority ?? Priority.none;

  String get fmtPriority {
    if (priority == Priority.none) {
      return '';
    }
    return '(${priority.name})';
  }

  /// The completion date of the [Todo].
  /// Defaults to null.
  DateTime? get completionDate => _completionDate;

  String get fmtCompletionDate => date2Str(completionDate) ?? '';

  /// The creation date of the [Todo].
  /// Defaults to null.
  DateTime? get creationDate => _creationDate;

  String get fmtCreationDate => date2Str(creationDate) ?? '';

  /// The description of the [Todo].
  /// Returns the description or an empty string (if null).
  String get description => _description ?? '';

  String get fmtDescription {
    final List<String> descriptionList = [];
    for (String item in description.split(' ')) {
      if (patternId.hasMatch(item)) continue;
      if (matchProject(item)) continue;
      if (matchContext(item)) continue;
      if (matchKeyValue(item)) continue;
      descriptionList.add(item);
    }

    return descriptionList.join(' ');
  }

  /// The list of contexts of the [Todo].
  /// Defaults to an empty [Set].
  Set<String> get projects {
    List<String> projects = [];
    for (String item in description.split(' ')) {
      if (matchProject(item)) {
        projects.add(item.substring(1).toLowerCase());
      }
    }

    return (projects..sort()).toSet();
  }

  Set<String> get fmtProjects => {for (var p in projects) '+$p'};

  static fmtProject(String p) =>
      p.startsWith('+') ? p.toLowerCase() : '+${p.toLowerCase()}';

  bool containsProject(String project) {
    String p = project.toLowerCase();
    if (p.startsWith('+')) {
      return projects.contains(p.substring(1));
    } else {
      return projects.contains(p);
    }
  }

  static bool matchProject(String project) => patternProject.hasMatch(project);

  /// The list of contexts of the [Todo].
  /// Defaults to an empty [Set].
  Set<String> get contexts {
    List<String> contexts = [];
    for (String item in description.split(' ')) {
      if (matchContext(item)) {
        contexts.add(item.substring(1).toLowerCase());
      }
    }

    return (contexts..sort()).toSet();
  }

  Set<String> get fmtContexts => {for (var c in contexts) '@$c'};

  static fmtContext(String c) =>
      c.startsWith('@') ? c.toLowerCase() : '@${c.toLowerCase()}';

  bool containsContext(String context) {
    String c = context.toLowerCase();
    if (c.startsWith('@')) {
      return contexts.contains(c.substring(1));
    } else {
      return contexts.contains(c);
    }
  }

  static bool matchContext(String context) => patternContext.hasMatch(context);

  /// The list of key value pairs of the [Todo].
  /// Defaults to an empty [Map].
  Set<String> get keyValues {
    List<String> keyValues = [];
    for (String item in description.split(' ')) {
      if (matchKeyValue(item)) {
        List<String> kvSplitted = item.split(':');
        if (kvSplitted.length > 2) continue;
        if (kvSplitted[0] == 'id') continue; // Exclude id here.
        keyValues.add(item.toLowerCase());
      }
    }

    return (keyValues..sort()).toSet();
  }

  Set<String> get fmtKeyValues => keyValues;

  static fmtKeyValue(String keyValue) => keyValue.toLowerCase();

  /// Checks if a key value pair with specific key already exists.
  bool containsKeyValue(String keyValue) {
    for (String kv in keyValues) {
      if (kv.toLowerCase().split(':')[0] ==
          keyValue.toLowerCase().split(':')[0]) {
        return true;
      }
    }

    return false;
  }

  static bool matchKeyValue(String kv) => patternKeyValue.hasMatch(kv);

  DateTime? get dueDate {
    for (String kv in keyValues) {
      List<String> kvSplitted = kv.split(':');
      if (kvSplitted[0] == 'due') {
        return str2date(kvSplitted[1]);
      }
    }

    return null;
  }

  String get fmtDueDate {
    final String? dueDateStr = date2Str(dueDate);
    return dueDateStr != null ? 'due:$dueDateStr' : '';
  }

  // Core todo constructor with validation logic.
  Todo._({
    required this.id,
    bool? completion,
    Priority? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
  })  : _completion = completion,
        _priority = priority,
        _completionDate = completionDate,
        _creationDate = creationDate,
        _description = description {
    // Validate completion date.
    if (completion == true) {
      if (completionDate == null) {
        // A completed todo needs at least a completion date.
        throw const TodoMissingCompletionDate();
      }
    } else {
      if (completionDate != null) {
        // A completed todo cannot have a completion date.
        throw const TodoForbiddenCompletionDate();
      }
    }
  }

  /// Factory for model creation with safety mechanisms.
  factory Todo({
    String? id,
    bool? completion,
    Priority? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
  }) {
    final DateTime now = DateTime.now();

    if (completion == true) {
      if (completionDate == null) {
        completionDate = DateTime(now.year, now.month, now.day);
      } else {
        completionDate = DateTime(
            completionDate.year, completionDate.month, completionDate.day);
      }
    } else {
      completionDate = null;
    }

    if (creationDate == null) {
      // Initialize creationDate to be sure there is always one set.
      creationDate = DateTime(now.year, now.month, now.day);
    } else {
      creationDate =
          DateTime(creationDate.year, creationDate.month, creationDate.day);
    }

    return Todo._(
      id: id ?? Todo.genId(),
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: description != null ? _trim(description) : description,
    );
  }

  factory Todo.fromString({
    required String value,
  }) {
    final todoStr = _trim(value);

    bool completion = _str2completion(
      _todoStringElementAt(todoStr, 0),
    );
    Priority priority;
    DateTime? completionDate;
    DateTime? creationDate;
    List<String>? fullDescriptionList;

    // Get completion
    if (completion) {
      completionDate = str2date(
        _todoStringElementAt(todoStr, 1),
      );
      priority = _str2priority(
        _todoStringElementAt(todoStr, 2),
      );
      // x <completionDate> [<priority>] [<creationDate>] <fullDescription>
      if (priority == Priority.none) {
        creationDate = str2date(
          _todoStringElementAt(todoStr, 2),
        );
      } else {
        creationDate = str2date(
          _todoStringElementAt(todoStr, 3),
        );
      }
    } else {
      priority = _str2priority(
        _todoStringElementAt(todoStr, 0),
      );
      // [<priority>] [<creationDate>] <fullDescription>
      if (priority == Priority.none) {
        // The provided date is the creation date (todo incompleted).
        creationDate = str2date(
          _todoStringElementAt(todoStr, 0),
        );
      } else {
        // The provided date is the creation date (todo incompleted).
        creationDate = str2date(
          _todoStringElementAt(todoStr, 1),
        );
      }
      // The todo is not completed so two dates are forbidden.
      // Everything that comes after the creationDate is interpreted as the description.
    }

    // Get beginning of description.
    int descriptionIndex = 0;
    for (var prop in [completion, completionDate, priority, creationDate]) {
      if (prop != null && prop != false && prop != Priority.none) {
        descriptionIndex += 1;
      }
    }
    try {
      fullDescriptionList = todoStr.split(' ').sublist(descriptionIndex);
    } on RangeError {
      fullDescriptionList = [];
    }

    return Todo(
      id: _str2Id(fullDescriptionList) ?? Todo.genId(),
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: _str2description(fullDescriptionList), // Including tags.
    );
  }

  /// A regular copyWith function.
  Todo copyWith({
    bool? completion,
    Priority? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
  }) {
    return Todo(
      id: id,
      completion: completion ?? this.completion,
      priority: priority ?? this.priority,
      completionDate: completionDate ?? this.completionDate,
      creationDate: creationDate ?? this.creationDate,
      description: description ?? this.description,
    );
  }

  /// Creates a todo object that only sets the values
  /// that have been explicitly edited.
  /// The other values remain to null.
  Todo copyDiff({
    bool? completion,
    Priority? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
  }) {
    return Todo(
      id: id,
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      // Once the creationDate is set, keep it.
      creationDate: creationDate ?? this.creationDate,
      description: description,
    );
  }

  /// Copy only the explicitly set attributes into the new object.
  /// Use the existing values for the rest.
  /// If the values of _<variables> are not null, they have been
  /// explicitly edited.
  Todo copyMerge(Todo todo) {
    return Todo(
      id: id,
      completion: _completion ?? todo.completion,
      priority: _priority ?? todo.priority,
      completionDate: _completionDate ?? todo.completionDate,
      creationDate: _creationDate ?? todo.creationDate,
      description: _description ?? todo.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        completion,
        completionDate,
        priority,
        creationDate,
        description,
      ];

  @override
  String toString({
    bool includeId = true,
  }) {
    final List<String> items = [
      fmtCompletion,
      fmtCompletionDate,
      fmtPriority,
      fmtCreationDate,
      description,
      if (includeId) fmtId,
    ]..removeWhere((value) => value.isEmpty);

    return items.join(' ');
  }

  static String genId({int len = 10}) {
    final Random r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  static DateTime? str2date(String value) {
    if (patternDate.hasMatch(value)) {
      return DateTime.parse(value);
    } else {
      return null;
    }
  }

  static String? date2Str(DateTime? date) {
    if (date == null) {
      return null;
    }
    return "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static int compareToToday(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return date.compareTo(today);
  }

  static String differenceToToday(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final Duration difference = today.difference(date);
    final int days = difference.inDays;

    if (days < 0) {
      return 'In future'; // In real this should never the case.
    } else if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Yesterday';
    } else if (days > 1 && days <= 6) {
      return '$days days ago';
    } else if (days > 6 && days <= 30) {
      final int weeks = days ~/ 7;
      return weeks == 1 ? '$weeks week ago' : '$weeks weeks ago';
    } else if (days > 30 && days <= 364) {
      final int months = days ~/ 31;
      return months == 1 ? '$months month ago' : '$months months ago';
    } else {
      final int years = days ~/ 365;
      return years == 1 ? '$years year ago' : '$years years ago';
    }
  }

  static String _trim(String value) {
    // Trim duplicate whitespaces.
    return value.trim().replaceAllMapped(RegExp(r'\s{2,}'), (match) {
      return ' ';
    });
  }

  static String _todoStringElementAt(String value, int index) {
    final List<String> todoStrSplitted = value.split(' ');
    try {
      return todoStrSplitted[index];
    } on RangeError {
      return '';
    }
  }

  static bool _str2completion(String value) {
    // A completed task starts with an lowercase x character.
    return value == 'x';
  }

  static Priority _str2priority(String value) {
    RegExpMatch? match = patternPriority.firstMatch(value);
    if (match != null) {
      String? priority = match.namedGroup('priority');
      if (priority != null) {
        return Priorities.byName(priority);
      }
    }

    // Priority is optional.
    return Priority.none;
  }

  /// Trim projects, contexts and key-values from description.
  static String _str2description(List<String> strList) {
    final List<String> descriptionList = [];
    for (var item in strList) {
      if (patternId.hasMatch(item)) continue;
      descriptionList.add(item);
    }

    return descriptionList.join(' ');
  }

  static String? _str2Id(List<String> strList) {
    for (var item in strList) {
      if (patternId.hasMatch(item)) {
        final List<String> splittedId = item.split(':');
        return splittedId[1];
      }
    }

    return null;
  }
}
