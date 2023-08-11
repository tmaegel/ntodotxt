import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  /// Task string format:
  /// completion (priority) [completion_date] [creation_date] description [+project] [@context] [key:val]

  /// General:
  /// A context is preceded by a single space and an at-sign (@).
  /// A project is preceded by a single space and a plus-sign (+).
  /// A project or context contains any non-whitespace character.
  /// A task may have zero, one, or more than one projects and contexts included in it.

  /// Incomplete Tasks: Format rules
  /// 1) If priority exists, it ALWAYS appears first. Discard priority on task completion.
  /// 2) A task's creation date may optionally appear directly after priority and a space.
  /// 3) Contexts and Projects may appear anywhere in the line after priority/prepended date.

  /// Complete Tasks: Format rules
  /// 1) A completed task starts with an lowercase x character followed directly by a space character.
  /// 2) The date of completion appears directly after the x, separated by a space.

  /// Additional File Format Definitions
  /// Developers should use the format key:value to define additional metadata (e.g. due:2010-01-02 as a due date).
  /// Both key and value must consist of non-whitespace characters, which are not colons.
  /// Only one colon separates the key and value.

  static const String patternCompletion = r'^x\s+';
  static const String patternPriority = r'\((?<priority>[a-zA-Z])\)\s+';
  static const String patternDates = r'((?<date>\d{4}-\d{2}-\d{2}))\s+';
  static const String patternProjects =
      r'(\s+(?<project>\+\S+))'; // Any non-whitespace character is allowed.
  static const String patternContexts =
      r'(\s+(?<context>\@\S+))'; // Any non-whitespace character is allowed.
  static const String patternKeyValues =
      r'(\s+(?<keyvalue>\S+:\S+))'; // Any non-whitespace character is allowed.
  static const String patternDescription =
      r'^(x\s?)?(\([a-zA-Z]\)\s?)?(\d{4}-\d{2}-\d{2}\s?){0,2}((?<description>.+))?$';

  /// Whether the `todo` is completed.
  /// Required attribute.
  bool completion;

  /// The priority of the `todo`.
  /// Priorities are A, B, C, ...
  String? priority;

  /// The completion date of the `todo`.
  /// Defaults to null.
  DateTime? completionDate;

  /// The creation date of the `todo`.
  /// Defaults to null.
  DateTime? creationDate;

  /// The description of the `todo`.
  /// Required attribute.
  String description;

  /// The list of projects of the `todo`.
  /// Defaults to an empty list.
  List<String> projects;

  /// The list of contexts of the `todo`.
  /// Defaults to an empty list.
  List<String> contexts;

  /// The list of key value apirs of the `todo`.
  /// Defaults to an empty map.
  Map<String, String> keyValues;

  Todo({
    required this.completion,
    required this.description,
    this.priority,
    this.completionDate,
    this.creationDate,
    this.projects = const [],
    this.contexts = const [],
    this.keyValues = const {},
  });

  factory Todo.fromString(String todoStr) {
    final bool completion = getCompletion(todoStr);
    final dates = getDates(todoStr);
    DateTime? completionDate;
    DateTime? creationDate;
    if (dates.isNotEmpty && dates.length < 2) {
      // If status is set there should a completion date too.
      if (completion) {
        throw const FormatException(
            "Completion date is mandatory if status is set.");
      }
      // If one date detected its the creation date.
      creationDate = dates[0];
    } else if (dates.length >= 2) {
      // Status is mandatory if the completion date is set.
      if (!completion) {
        throw const FormatException(
            "Status is mandatory if completion date is set.");
      }
      // If two dates detected completion date appears first
      // and creation date must defined.
      completionDate = dates[0];
      creationDate = dates[1];
    }
    return Todo(
      completion: completion,
      priority: getPriority(todoStr),
      completionDate: completionDate,
      creationDate: creationDate,
      description: getDescription(todoStr),
      projects: getProjects(todoStr),
      contexts: getContexts(todoStr),
      keyValues: getKeyValues(todoStr),
    );
  }

  static String trimWhitespaces(String value) {
    // Trim leading, trailing and duplicate whitespaces.
    return value.trim().replaceAllMapped(RegExp(r'\s+'), (match) {
      return ' ';
    });
  }

  static bool getCompletion(String todoStr) {
    return RegExp(patternCompletion).hasMatch(todoStr);
  }

  static String? getPriority(String todoStr) {
    final match = RegExp(patternPriority).firstMatch(todoStr);
    final String? priority = match?.namedGroup("priority");
    // Priority is optional.
    if (priority == null) {
      return null;
    }

    return priority.toUpperCase();
  }

  static String getDescription(String todoStr) {
    final match = RegExp(patternDescription).firstMatch(todoStr);
    String? description = match?.namedGroup("description");
    if (description == null) {
      throw const FormatException("Description is mandatory.");
    }

    // Trim projects from description value
    description = description.replaceAll(RegExp(r'\+\S+'), "");
    // Trim contexts from description value
    description = description.replaceAll(RegExp(r'\@\S+'), "");
    // Trim key-values from description value
    description = description.replaceAll(RegExp(r'\S+:\S+'), "");

    return trimWhitespaces(description);
  }

  static List<DateTime> getDates(String todoStr) {
    List<DateTime> dates = [];
    final matches = RegExp(patternDates).allMatches(todoStr);
    for (var match in matches) {
      final date = match.namedGroup("date");
      if (date != null) {
        dates.add(DateTime.parse(date));
      }
    }

    return dates;
  }

  static List<String> getProjects(String todoStr) {
    List<String> projects = [];
    final matches = RegExp(patternProjects).allMatches(todoStr);
    for (var match in matches) {
      final project = match.namedGroup("project");
      if (project != null) {
        projects.add(project.replaceFirst("+", ""));
      }
    }

    return projects;
  }

  static List<String> getContexts(String todoStr) {
    List<String> contexts = [];
    final matches = RegExp(patternContexts).allMatches(todoStr);
    for (var match in matches) {
      final context = match.namedGroup("context");
      if (context != null) {
        contexts.add(context.replaceFirst("@", ""));
      }
    }

    return contexts;
  }

  static Map<String, String> getKeyValues(String todoStr) {
    Map<String, String> keyValues = {};
    final matches = RegExp(patternKeyValues).allMatches(todoStr);
    for (var match in matches) {
      final keyValue = match.namedGroup("keyvalue");
      if (keyValue != null) {
        final splittedKeyValue = keyValue.split(":");
        if (splittedKeyValue.length > 2) continue;
        keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
      }
    }

    return keyValues;
  }

  /// Returns a copy of this `todo` with the given values updated.
  Todo copyWith({
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
      completion: completion ?? this.completion,
      priority: priority ?? this.priority,
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
  String toString() => 'Todo { $completion }';
}
