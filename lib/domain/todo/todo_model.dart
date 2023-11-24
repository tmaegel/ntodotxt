import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

class Todo extends Equatable {
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

  /// VALID examples:
  ///
  /// Write some tests                        (When incomplete, no date is required)
  /// 2019-07-01 Write some tests             (The provided date is the creation date)
  /// x 2019-07-03 Write some test            (The provided date is the completion date)
  /// x 2019-07-03 2019-07-01 Write some test (The provided dates are, in order, completion then creation)

  /// INVALID examples:
  ///
  /// 2019-07-03 2019-07-01 Write some tests  (The task is incomplete, so can't have a completion date)
  /// x Write some tests                      (A completed task needs at least a completion date)

  static final RegExp patternWord = RegExp(r'^\S+$');
  static final RegExp patternPriority = RegExp(r'^\((?<priority>[A-Z])\)$');
  static final RegExp patternDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp patternProject = RegExp(r'^\+\S+$');
  static final RegExp patternContext = RegExp(r'^\@\S+$');
  static final RegExp patternKeyValue = RegExp(r'^\S+:\S+$');

  /// Unique identifier.
  /// Defaults to null (if unsaved todo).
  final int? id;

  /// Whether the `todo` is completed.
  /// Defaults to false.
  final bool completion;

  /// The priority of the `todo`.
  /// Priorities are A, B, C, ...
  final String? priority;

  /// The completion date of the `todo`.
  /// Defaults to null.
  final DateTime? completionDate;

  /// The creation date of the `todo`.
  /// Defaults to null.
  final DateTime? creationDate;

  /// The description of the `todo`.
  /// Defaults to empty string.
  final String description;

  /// The list of projects of the `todo`.
  /// Defaults to an empty list.
  final Set<String> projects;

  /// The list of contexts of the `todo`.
  /// Defaults to an empty list.
  final Set<String> contexts;

  /// The list of key value apirs of the `todo`.
  /// Defaults to an empty map.
  final Map<String, String> keyValues;

  /// Flag that indicates whether the todo
  /// was selected in the list.
  /// Defaults to false.
  final bool selected;

  /// Flag that force to init the creation date.
  /// Defaults to true.
  final bool forceCreationDate;

  // Core todo constructor with validation logic.
  Todo._({
    this.id,
    this.completion = false,
    this.priority,
    this.completionDate,
    this.creationDate,
    required this.description,
    this.projects = const {},
    this.contexts = const {},
    this.keyValues = const {},
    this.selected = false,
    this.forceCreationDate = true, // Initialize creationDate if not defined.
  }) {
    // Validate completion date.
    if (completion) {
      if (completionDate == null) {
        // A completed todo needs at least a completion date.
        throw const TodoMissingCompletionDate();
      }
    } else {
      if (completionDate != null) {
        throw const TodoForbiddenCompletionDate();
      }
    }
    // Validate project tags.
    for (var p in projects) {
      if (!patternWord.hasMatch(p)) {
        throw TodoInvalidProjectTag(tag: p);
      }
    }
    // Validate context tags.
    for (var c in contexts) {
      if (!patternWord.hasMatch(c)) {
        throw TodoInvalidContextTag(tag: c);
      }
    }
    // Validate key value tags.
    for (MapEntry<String, String> kv in keyValues.entries) {
      if (!patternWord.hasMatch(kv.key) || !patternWord.hasMatch(kv.value)) {
        throw TodoInvalidKeyValueTag(tag: '${kv.key}:${kv.value}');
      }
    }
  }

  const Todo.unsafe({
    this.id,
    this.completion = false,
    this.priority,
    this.completionDate,
    this.creationDate,
    required this.description,
    this.projects = const {},
    this.contexts = const {},
    this.keyValues = const {},
    this.selected = false,
    this.forceCreationDate = true, // Initialize creationDate if not defined.
  });

  /// Is only used for creating new todos, as these initially have no description.
  const Todo.empty() : this.unsafe(description: '');

  /// Factory for model creation with safety mechanisms.
  factory Todo({
    int? id,
    bool completion = false,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    required description,
    Set<String> projects = const {},
    Set<String> contexts = const {},
    Map<String, String> keyValues = const {},
    bool selected = false,
    bool forceCreationDate = true, // Initialize creationDate if not defined.
  }) {
    if (completionDate != null) {
      completionDate = DateTime(
        completionDate.year,
        completionDate.month,
        completionDate.day,
      );
    }
    if (creationDate != null) {
      creationDate = DateTime(
        creationDate.year,
        creationDate.month,
        creationDate.day,
      );
    } else {
      // Initialize creationDate to be sure there is always one set.
      if (forceCreationDate) {
        final DateTime now = DateTime.now();
        creationDate = DateTime(
          now.year,
          now.month,
          now.day,
        );
      }
    }
    projects = {
      for (var p in projects) p.toLowerCase(),
    };
    contexts = {
      for (var c in contexts) c.toLowerCase(),
    };
    keyValues = {
      for (MapEntry<String, String> kv in keyValues.entries)
        kv.key.toLowerCase(): kv.value.toLowerCase()
    };

    return Todo._(
      id: id,
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: description,
      projects: projects,
      contexts: contexts,
      keyValues: keyValues,
      selected: selected,
      forceCreationDate: forceCreationDate,
    );
  }

  /// Factory for model creation from string.
  factory Todo.fromString({
    required int id,
    required String value,
    bool forceCreationDate = true, // Initialize creationDate if not defined.
  }) {
    final todoStr = _trim(value); // Trim first.
    bool completion;
    String? priority;
    DateTime? completionDate;
    DateTime? creationDate;
    List<String>? fullDescriptionList;

    // Get completion
    completion = _completion(_todoStringElementAt(todoStr, 0));
    if (completion) {
      completionDate = str2Date(_todoStringElementAt(todoStr, 1));
      priority = _priority(_todoStringElementAt(todoStr, 2));
      // x <completionDate> [<priority>] [<creationDate>] <fullDescription>
      if (priority == null) {
        creationDate = str2Date(_todoStringElementAt(todoStr, 2));
      } else {
        creationDate = str2Date(_todoStringElementAt(todoStr, 3));
      }
    } else {
      priority = _priority(_todoStringElementAt(todoStr, 0));
      // [<priority>] [<creationDate>] <fullDescription>
      if (priority == null) {
        // The provided date is the creation date (todo incompleted).
        creationDate = str2Date(_todoStringElementAt(todoStr, 0));
      } else {
        // The provided date is the creation date (todo incompleted).
        creationDate = str2Date(_todoStringElementAt(todoStr, 1));
      }
      // The todo is not completed so two dates are forbidden.
      // Everything that comes after the creationDate is interpreted as a description.
    }

    // Get beginning of description.
    int descriptionIndex = 0;
    for (var prop in [completion, completionDate, priority, creationDate]) {
      if (prop != null && prop != false) {
        descriptionIndex += 1;
      }
    }
    fullDescriptionList = _fullDescriptionList(todoStr, descriptionIndex);

    return Todo(
      id: id,
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: _description(fullDescriptionList),
      projects: _projects(fullDescriptionList),
      contexts: _contexts(fullDescriptionList),
      keyValues: _keyValues(fullDescriptionList),
      forceCreationDate: forceCreationDate,
    );
  }

  static String _trim(String value) {
    // Trim leading, trailing and duplicate whitespaces.
    return value.trim().replaceAllMapped(RegExp(r'\s+'), (match) {
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

  static List<String> _fullDescriptionList(String value, int index) {
    final List<String> todoStrSplitted = value.split(' ');
    try {
      final List<String> fullDescriptionList = todoStrSplitted.sublist(index);
      if (fullDescriptionList.isNotEmpty) {
        return fullDescriptionList;
      } else {
        throw TodoStringMalformed(str: value);
      }
    } on RangeError {
      throw TodoStringMalformed(str: value);
    }
  }

  static bool _completion(String value) {
    // A completed task starts with an lowercase x character.
    return value == 'x';
  }

  static String? _priority(String value) {
    RegExpMatch? match = patternPriority.firstMatch(value);
    if (match != null) {
      return match.namedGroup("priority");
    } else {
      // Priority is optional.
      return null;
    }
  }

  /// Trim projects, contexts and key-values from description.
  static String _description(List<String> descriptionList) {
    final String description = _trim(
      descriptionList
          .join(' ')
          .replaceAll(RegExp(r'\+\S+'), '')
          .replaceAll(RegExp(r'\@\S+'), '')
          .replaceAll(RegExp(r'\S+:\S+'), ''),
    );
    if (description.isEmpty) {
      throw const TodoStringMalformed(str: '');
    }

    return description;
  }

  static Set<String> _projects(List<String> fullDescriptionList) {
    Set<String> projects = {};
    for (var project in fullDescriptionList) {
      if (patternProject.hasMatch(project)) {
        projects.add(project.substring(1)); // strip the leading '+'
      }
    }

    return projects;
  }

  static Set<String> _contexts(List<String> fullDescriptionList) {
    Set<String> contexts = {};
    for (var context in fullDescriptionList) {
      if (patternContext.hasMatch(context)) {
        contexts.add(context.substring(1)); // strip the leading '@'
      }
    }

    return contexts;
  }

  static Map<String, String> _keyValues(List<String> fullDescriptionList) {
    Map<String, String> keyValues = {};

    for (var keyValue in fullDescriptionList) {
      if (patternKeyValue.hasMatch(keyValue)) {
        final List<String> splittedKeyValue = keyValue.split(":");
        if (splittedKeyValue.length > 2) continue;
        keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
      }
    }

    return keyValues;
  }

  static DateTime? str2Date(String value) {
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
    return DateFormat('yyyy-MM-dd').format(date);
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

  DateTime? get dueDate {
    if (keyValues.containsKey('due')) {
      return str2Date(keyValues['due'] ?? '');
    }

    return null;
  }

  bool get isDescriptionEmpty => _trim(description).isEmpty;

  String get formattedCompletion => completion ? 'x' : '';

  String get formattedPriority => priority != null ? '($priority)' : '';

  String get formattedCompletionDate => date2Str(completionDate) ?? '';

  String get formattedCreationDate => date2Str(creationDate) ?? '';

  Set<String> get formattedProjects => {for (var p in projects) "+$p"};

  Set<String> get formattedContexts => {for (var c in contexts) "@$c"};

  Set<String> get formattedKeyValues =>
      {for (var k in keyValues.keys) "$k:${keyValues[k]}"};

  /// Returns a copy of this `todo` with the given values updated.
  Todo copyWith({
    int? id,
    bool? completion,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
    Set<String>? projects,
    Set<String>? contexts,
    Map<String, String>? keyValues,
    bool? selected,
    bool? forceCreationDate,
    bool unsetId = false,
    bool unsetPriority = false,
    bool unsetCompletionDate = false,
    bool unsetCreationDate = false,
  }) {
    return Todo(
      id: id ?? (unsetId ? null : this.id),
      completion: completion ?? this.completion,
      priority: priority ?? (unsetPriority ? null : this.priority),
      completionDate:
          completionDate ?? (unsetCompletionDate ? null : this.completionDate),
      creationDate:
          creationDate ?? (unsetCreationDate ? null : this.creationDate),
      description: description ?? this.description,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      keyValues: keyValues ?? this.keyValues,
      selected: selected ?? this.selected,
      forceCreationDate: forceCreationDate ?? this.forceCreationDate,
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
        projects,
        contexts,
        keyValues,
        selected,
        // Exclude forceCreationDate here,
      ];

  @override
  String toString() {
    final List<String?> items = [
      formattedCompletion,
      formattedCompletionDate,
      formattedPriority,
      formattedCreationDate,
      description,
      formattedProjects.isNotEmpty ? formattedProjects.join(' ') : null,
      formattedContexts.isNotEmpty ? formattedContexts.join(' ') : null,
      formattedKeyValues.isNotEmpty ? formattedKeyValues.join(' ') : null,
    ]..removeWhere(
        (value) {
          if (value == null) {
            return true;
          } else {
            if (value.isEmpty) {
              return true;
            }
          }
          return false;
        },
      );

    return items.join(' ');
  }

  String toDebugString() =>
      '${toString()} (DEBUG: id: $id, selected: $selected)';
}
