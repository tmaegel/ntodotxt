import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

class Todo extends Equatable {
  /// Structure of a valid todoStr
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

  Todo._({
    this.id,
    this.completion = false,
    this.priority,
    DateTime? completionDate,
    DateTime? creationDate,
    required this.description,
    Set<String> projects = const {},
    Set<String> contexts = const {},
    Map<String, String> keyValues = const {},
    this.selected = false,
  })  : completionDate = completionDate == null
            ? null
            : DateTime(
                completionDate.year,
                completionDate.month,
                completionDate.day,
              ),
        creationDate = creationDate == null
            ? null
            : DateTime(
                creationDate.year,
                creationDate.month,
                creationDate.day,
              ),
        projects = {for (var p in projects) p.toLowerCase()},
        contexts = {for (var c in contexts) c.toLowerCase()},
        keyValues = {
          for (MapEntry<String, String> kv in keyValues.entries)
            kv.key.toLowerCase(): kv.value.toLowerCase()
        } {
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
    // @todo: Validate description.
    // if (description.isEmpty) {
    //   throw const TodoMissingDescription();
    // }
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

  const Todo.noValidation({
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
  });

  const Todo.empty() : this.noValidation(description: '');

  /// Factory for model creation (fallback).
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
  }) {
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
    );
  }

  /// Factory for model creation from string.
  factory Todo.fromString({required int id, required String todoStr}) {
    final List<String> todoSplitted = _trim(todoStr).split(' ');
    bool completion;
    String? priority;
    DateTime? completionDate;
    DateTime? creationDate;
    List<String>? fullDescriptionList;

    // Get completion
    completion = _completion(_strElement(todoSplitted, 0));
    if (completion) {
      completionDate = str2Date(_strElement(todoSplitted, 1));
      priority = _priority(_strElement(todoSplitted, 2));
      if (priority == null) {
        // x [completionDate] [fullDescription]
        // x [completionDate] [creationDate] [fullDescription]
        creationDate = str2Date(_strElement(todoSplitted, 2));
      } else {
        // x [completionDate] [priority] [fullDescription]
        // x [completionDate] [priority] [creationDate] [fullDescription]
        creationDate = str2Date(_strElement(todoSplitted, 3));
      }
    } else {
      priority = _priority(_strElement(todoSplitted, 0));
      if (priority == null) {
        // [creationDate] [fullDescription]
        // The provided date is the creation date (todo incompleted).
        creationDate = str2Date(_strElement(todoSplitted, 0));
        // The todo is not completed so two dates are forbidden.
        completionDate = str2Date(_strElement(todoSplitted, 1));
      } else {
        // [priority] [creationDate] [fullDescription]
        // The provided date is the creation date (todo incompleted).
        creationDate = str2Date(_strElement(todoSplitted, 1));
        // The todo is not completed so two dates are forbidden.
        completionDate = str2Date(_strElement(todoSplitted, 2));
      }
    }

    // Get beginning of description.
    int descriptionIndex = 0;
    for (var prop in [completion, completionDate, priority, creationDate]) {
      if (prop != null && prop != false) {
        descriptionIndex += 1;
      }
    }
    fullDescriptionList = _fullDescriptionList(todoSplitted, descriptionIndex);

    return Todo._(
      id: id,
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: _description(fullDescriptionList),
      projects: _projects(fullDescriptionList),
      contexts: _contexts(fullDescriptionList),
      keyValues: _keyValues(fullDescriptionList),
    );
  }

  static String _trim(String value) {
    // Trim leading, trailing and duplicate whitespaces.
    return value.trim().replaceAllMapped(RegExp(r'\s+'), (match) {
      return ' ';
    });
  }

  static String _strElement(List<String> splitted, int index) {
    try {
      return splitted[index];
    } on RangeError {
      throw const TodoStringMalformed();
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

  static List<String> _fullDescriptionList(List<String> splitted, int index) {
    try {
      final List<String> fullDescriptionList = splitted.sublist(index);
      if (fullDescriptionList.isNotEmpty) {
        return fullDescriptionList;
      } else {
        throw const TodoStringMalformed();
      }
    } on RangeError {
      throw const TodoStringMalformed();
    }
  }

  /// Trim projects, contexts and key-values from description.
  static String _description(List<String> descriptionList) {
    return _trim(
      descriptionList
          .join(' ')
          .replaceAll(RegExp(r'\+\S+'), '')
          .replaceAll(RegExp(r'\@\S+'), '')
          .replaceAll(RegExp(r'\S+:\S+'), ''),
    );
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

  static int compareToToday(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return date.compareTo(today);
  }

  DateTime? get dueDate {
    if (keyValues.containsKey('due')) {
      return str2Date(keyValues['due'] ?? '');
    }

    return null;
  }

  Set<String> get formattedProjects {
    return {for (var p in projects) "+$p"};
  }

  Set<String> get formattedContexts {
    return {for (var c in contexts) "@$c"};
  }

  Set<String> get formattedKeyValues {
    return {for (var k in keyValues.keys) "$k:${keyValues[k]}"};
  }

  String? formattedDate(DateTime? date) {
    if (date == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

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
    bool unsetId = false,
    bool unsetPriority = false,
    bool unsetCompletionDate = false,
    bool unsetCreationDate = false,
  }) {
    return Todo._(
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
      ];

  @override
  String toString() {
    final List<String?> items = [
      completion ? 'x' : null,
      formattedDate(completionDate),
      priority != null ? '($priority)' : null,
      formattedDate(creationDate),
      description,
      formattedProjects.isNotEmpty ? formattedProjects.join(' ') : null,
      formattedContexts.isNotEmpty ? formattedContexts.join(' ') : null,
      formattedKeyValues.isNotEmpty ? formattedKeyValues.join(' ') : null,
    ]..removeWhere((value) => value == null);

    return items.join(' ');
  }
}
