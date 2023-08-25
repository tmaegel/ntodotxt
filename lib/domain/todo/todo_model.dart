import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

class Todo extends Equatable {
  /// Structure of a valid todoStr
  /// with some modification (https://github.com/todotxt/todo.txt/discussions/52)
  ///
  /// [completion]      (optional)
  /// [priority]        (optional)
  /// [completionDate]  (forbidden if incompleted, mandatory if completed)
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
  final List<String> projects;

  /// The list of contexts of the `todo`.
  /// Defaults to an empty list.
  final List<String> contexts;

  /// The list of key value apirs of the `todo`.
  /// Defaults to an empty map.
  final Map<String, String> keyValues;

  const Todo({
    this.id,
    this.completion = false,
    this.priority,
    this.completionDate,
    this.creationDate,
    this.description = '',
    this.projects = const [],
    this.contexts = const [],
    this.keyValues = const {},
  });
  const Todo.empty() : this();

  factory Todo.fromString({required int id, required String todoStr}) {
    final List<String> todoSplitted = _trim(todoStr).split(' ');
    bool completion;
    String? priority;
    DateTime? completionDate;
    DateTime? creationDate;

    int descriptionIndex = 0;
    List<String>? fullDescriptionList;

    // Get completion
    completion = _completion(_strElement(todoSplitted, 0));
    if (completion) {
      descriptionIndex += 1;
      priority = _priority(_strElement(todoSplitted, 1));
      if (priority == null) {
        // x [completionDate] [fullDescription]
        // x [completionDate] [creationDate] [fullDescription]
        completionDate = _date(_strElement(todoSplitted, 1));
        creationDate = _date(_strElement(todoSplitted, 2));
      } else {
        descriptionIndex += 1;
        // x [priority] [completionDate] [fullDescription]
        // x [priority] [completionDate] [creationDate] [fullDescription]
        completionDate = _date(_strElement(todoSplitted, 2));
        creationDate = _date(_strElement(todoSplitted, 3));
      }
      // A completed task needs at least a completion date.
      if (completionDate == null) {
        throw MissingTodoCompletionDate();
      }
      if (creationDate != null) {
        descriptionIndex += 1;
      }
      fullDescriptionList = _fullDescriptionList(todoSplitted,
          descriptionIndex + 1); // +1 for completion date (mandatory)
    } else {
      priority = _priority(_strElement(todoSplitted, 0));
      if (priority == null) {
        // [creationDate] [fullDescription]
        // The provided date is the creation date (todo incompleted).
        creationDate = _date(_strElement(todoSplitted, 0));
        // The todo is not completed so two dates are forbidden.
        if (_date(_strElement(todoSplitted, 1)) != null) {
          throw ForbiddenTodoCompletionDate();
        }
      } else {
        descriptionIndex += 1;
        // [priority] [creationDate] [fullDescription]
        // The provided date is the creation date (todo incompleted).
        creationDate = _date(_strElement(todoSplitted, 1));
        // The todo is not completed so two dates are forbidden.
        if (_date(_strElement(todoSplitted, 2)) != null) {
          throw ForbiddenTodoCompletionDate();
        }
      }
      if (creationDate != null) {
        descriptionIndex += 1;
      }
      fullDescriptionList =
          _fullDescriptionList(todoSplitted, descriptionIndex);
    }

    return Todo(
      id: id,
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: fullDescriptionList.join(' '),
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
      throw InvalidTodoString();
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

  static DateTime? _date(String value) {
    if (patternDate.hasMatch(value)) {
      return DateTime.parse(value);
    } else {
      return null;
    }
  }

  static List<String> _fullDescriptionList(List<String> splitted, int index) {
    try {
      final List<String> fullDescriptionList = splitted.sublist(index);
      if (fullDescriptionList.isNotEmpty) {
        return fullDescriptionList;
      } else {
        throw InvalidTodoString();
      }
    } on RangeError {
      throw InvalidTodoString();
    }
  }

  static List<String> _projects(List<String> fullDescriptionList) {
    List<String> projects = [];
    for (var project in fullDescriptionList) {
      if (patternProject.hasMatch(project)) {
        projects.add(project.substring(1)); // strip the leading '+'
      }
    }

    return projects;
  }

  static List<String> _contexts(List<String> fullDescriptionList) {
    List<String> contexts = [];
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

  /// Trim projects, contexts and key-values from description.
  String get strippedDescription {
    String strippedDescription = description
        .replaceAll(RegExp(r'\+\S+'), "")
        .replaceAll(RegExp(r'\@\S+'), "")
        .replaceAll(RegExp(r'\S+:\S+'), "");

    return _trim(strippedDescription);
  }

  List<String> get formattedProjects {
    return [for (var p in projects) "+$p"];
  }

  List<String> get formattedContexts {
    return [for (var c in contexts) "@$c"];
  }

  List<String> get formattedKeyValues {
    return [for (var k in keyValues.keys) "$k:${keyValues[k]}"];
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
    List<String>? projects,
    List<String>? contexts,
    Map<String, String>? keyValues,
  }) {
    return Todo(
      id: id ?? this.id,
      completion: completion ?? this.completion,
      priority: priority != '' ? priority ?? this.priority : null,
      completionDate: completionDate ?? this.completionDate,
      creationDate: creationDate ?? this.creationDate,
      description: description ?? this.description,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      keyValues: keyValues ?? this.keyValues,
    );
  }

  @override
  List<Object?> get props => [
        id,
        completion,
        priority,
        completionDate,
        creationDate,
        description,
        projects,
        contexts,
        keyValues,
      ];

  @override
  String toString() {
    final List<String?> items = [
      completion ? 'x' : '',
      priority != '' ? '($priority)' : '',
      formattedDate(completionDate) ?? '',
      formattedDate(creationDate) ?? '',
      description,
    ];

    return items.join(' ');
  }
}
