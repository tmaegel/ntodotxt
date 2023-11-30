import 'package:equatable/equatable.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:uuid/uuid.dart';

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
  static final RegExp patternPriority = RegExp(r'^\((?<priority>[A-Z])\)$');
  static final RegExp patternDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final RegExp patternProject = RegExp(r'^\+\S+$');
  static final RegExp patternContext = RegExp(r'^\@\S+$');
  static final RegExp patternKeyValue = RegExp(r'^\S+:\S+$');

  /// Whether the [Todo] is completed.
  /// Defaults to null (unset).
  final bool? _completion;

  /// The priority of the [Todo].
  /// Priorities are A, B, C, ...
  /// Defaults to null (empty, unset).
  final String? _priority;

  /// The completion date of the [Todo].
  /// Defaults to null (unset).
  final DateTime? _completionDate;

  /// The creation date of the [Todo].
  /// Defaults to null (unser).
  final DateTime? _creationDate;

  /// The description of the [Todo].
  /// Defaults to null (unset).
  final String? _description;

  /// The list of projects of the [Todo].
  /// Defaults to null (unset).
  final Set<String>? _projects;

  /// The list of contexts of the [Todo].
  /// Defaults to null (unset).
  final Set<String>? _contexts;

  /// The list of key value pairs of the [Todo].
  /// Defaults to null (unset).
  final Map<String, String>? _keyValues;

  /// Flag that indicates whether the [Todo]
  /// was selected in the list.
  /// Defaults to null (unset).
  final bool? _selected;

  /// Returns the uniqzue [id] of the [Todo]
  /// stored in the [keyValues].
  String get id {
    if (keyValues.containsKey('id')) {
      if (keyValues['id'] != null) {
        return keyValues['id']!;
      }
    }

    final String id = const Uuid().v4().toString();
    keyValues['id'] = id;

    return id;
  }

  /// Whether the [Todo] is completed.
  /// Defaults to false.
  bool get completion => _completion ?? false;

  /// The priority of the [Todo].
  /// Allowed values are A, B, C, ... or null (no empty string).
  /// Empty string value is used to reset the priority.
  String? get priority {
    if (_priority != null) {
      if (_priority!.isNotEmpty) {
        return _priority;
      }
    }

    return null;
  }

  /// The completion date of the [Todo].
  /// Defaults to null.
  DateTime? get completionDate => _completionDate;

  /// The creation date of the [Todo].
  /// Defaults to null.
  DateTime? get creationDate => _creationDate;

  /// The description of the [Todo].
  /// Returns the description or an empty string (if null).
  String get description => _description ?? '';

  /// The list of contexts of the [Todo].
  /// Defaults to an empty [Set].
  Set<String> get projects => _projects ?? const {};

  /// The list of contexts of the [Todo].
  /// Defaults to an empty [Set].
  Set<String> get contexts => _contexts ?? const {};

  /// The list of key value pairs of the [Todo].
  /// Defaults to an empty [Map].
  Map<String, String> get keyValues => _keyValues ?? const {};

  /// Flag that indicates whether the [Todo]
  /// was selected in the list.
  /// Defaults to false.
  bool get selected => _selected ?? false;

  DateTime? get dueDate {
    if (keyValues.containsKey('due')) {
      return str2date(keyValues['due'] ?? '');
    }

    return null;
  }

  String get formattedCompletion => completion ? 'x' : '';

  String get formattedPriority {
    if (priority != null) {
      return '($priority)';
    }

    return '';
  }

  String get formattedCompletionDate => date2Str(completionDate) ?? '';

  String get formattedCreationDate => date2Str(creationDate) ?? '';

  Set<String> get formattedProjects => {for (var p in projects) "+$p"};

  Set<String> get formattedContexts => {for (var c in contexts) "@$c"};

  Set<String> get formattedKeyValues => {
        // Exclude id from key-values.
        for (var k in keyValues.keys)
          if (k != 'id') "$k:${keyValues[k]}"
      };

  // Core todo constructor with validation logic.
  Todo._({
    bool? completion,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
    Set<String>? projects,
    Set<String>? contexts,
    Map<String, String>? keyValues,
    bool? selected,
  })  : _completion = completion,
        _priority = priority,
        _completionDate = completionDate,
        _creationDate = creationDate,
        _description = description,
        _projects = projects,
        _contexts = contexts,
        _keyValues = keyValues,
        _selected = selected {
    // Validate completion date.
    if (completion == true) {
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
    if (projects != null) {
      for (var p in projects) {
        if (!patternWord.hasMatch(p)) {
          throw TodoInvalidProjectTag(tag: p);
        }
      }
    }
    // Validate context tags.
    if (contexts != null) {
      for (var c in contexts) {
        if (!patternWord.hasMatch(c)) {
          throw TodoInvalidContextTag(tag: c);
        }
      }
    }
    // Validate key value tags.
    if (keyValues == null) {
      throw const TodoMissingId();
    } else {
      for (MapEntry<String, String> kv in keyValues.entries) {
        if (!patternWord.hasMatch(kv.key) || !patternWord.hasMatch(kv.value)) {
          throw TodoInvalidKeyValueTag(tag: '${kv.key}:${kv.value}');
        }
      }
      if (!keyValues.containsKey('id')) {
        throw const TodoMissingId();
      }
    }
  }

  /// Factory for model creation with safety mechanisms.
  factory Todo({
    String? id,
    bool? completion,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
    Set<String>? projects,
    Set<String>? contexts,
    Map<String, String>? keyValues,
    bool? selected,
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

    if (projects != null) {
      projects = {
        for (var p in projects) p.toLowerCase(),
      };
    }
    if (contexts != null) {
      contexts = {
        for (var c in contexts) c.toLowerCase(),
      };
    }
    if (keyValues == null) {
      // To make each todo unique store an id as key-value pair is necessary.
      keyValues = {};
      keyValues['id'] = id ?? const Uuid().v4().toString();
    } else {
      keyValues = {
        for (MapEntry<String, String> kv in keyValues.entries)
          kv.key.toLowerCase(): kv.value.toLowerCase()
      };
      // To make each todo unique store an id as key-value pair is necessary.
      if (!keyValues.containsKey('id')) {
        keyValues['id'] = id ?? const Uuid().v4().toString();
      }
    }

    return Todo._(
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
  factory Todo.fromString({
    required String value,
  }) {
    final todoStr = _trim(value); // Trim first.
    bool completion;
    String? priority;
    DateTime? completionDate;
    DateTime? creationDate;
    List<String>? fullDescriptionList;

    // Get completion
    completion = _str2completion(_todoStringElementAt(todoStr, 0));
    if (completion) {
      completionDate = str2date(_todoStringElementAt(todoStr, 1));
      priority = _str2priority(_todoStringElementAt(todoStr, 2));
      // x <completionDate> [<priority>] [<creationDate>] <fullDescription>
      if (priority == null) {
        creationDate = str2date(_todoStringElementAt(todoStr, 2));
      } else {
        creationDate = str2date(_todoStringElementAt(todoStr, 3));
      }
    } else {
      priority = _str2priority(_todoStringElementAt(todoStr, 0));
      // [<priority>] [<creationDate>] <fullDescription>
      if (priority == null) {
        // The provided date is the creation date (todo incompleted).
        creationDate = str2date(_todoStringElementAt(todoStr, 0));
      } else {
        // The provided date is the creation date (todo incompleted).
        creationDate = str2date(_todoStringElementAt(todoStr, 1));
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
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      creationDate: creationDate,
      description: _str2description(fullDescriptionList),
      projects: _str2projects(fullDescriptionList),
      contexts: _str2contexts(fullDescriptionList),
      keyValues: _str2keyValues(fullDescriptionList),
    );
  }

  /// A regular copyWith function.
  Todo copyWith({
    bool? completion,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
    Set<String>? projects,
    Set<String>? contexts,
    Map<String, String>? keyValues,
    bool? selected,
  }) {
    return Todo(
      id: id,
      completion: completion ?? this.completion,
      priority: priority ?? this.priority,
      completionDate: completionDate ?? this.completionDate,
      creationDate: creationDate ?? this.creationDate,
      description: description ?? this.description,
      projects: projects ?? this.projects,
      contexts: contexts ?? this.contexts,
      keyValues: keyValues ?? this.keyValues,
      selected: selected ?? this.selected,
    );
  }

  /// Creates a todo object that only sets the values
  /// that have been explicitly edited.
  /// The other values remain to null.
  Todo copyDiff({
    bool? completion,
    String? priority,
    DateTime? completionDate,
    DateTime? creationDate,
    String? description,
    Set<String>? projects,
    Set<String>? contexts,
    Map<String, String>? keyValues,
    bool? selected,
  }) {
    return Todo(
      id: id,
      completion: completion,
      priority: priority,
      completionDate: completionDate,
      // Once the creationDate is set, keep it.
      creationDate: this.creationDate ?? creationDate,
      description: description,
      projects: projects,
      contexts: contexts,
      keyValues: keyValues,
      selected: selected,
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
      projects: _projects ?? todo.projects,
      contexts: _contexts ?? todo.contexts,
      keyValues: _keyValues == null
          ? todo.keyValues
          : (_keyValues!.length == 1 && _keyValues!.containsKey('id'))
              ? todo.keyValues
              : _keyValues,
      selected: _selected ?? todo.selected,
    );
  }

  @override
  List<Object?> get props => [
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
    final Set<String> keyValuesStringSet = {
      for (var k in keyValues.keys) "$k:${keyValues[k]}"
    };
    final List<String?> items = [
      formattedCompletion,
      formattedCompletionDate,
      formattedPriority,
      formattedCreationDate,
      description,
      formattedProjects.isNotEmpty ? formattedProjects.join(' ') : null,
      formattedContexts.isNotEmpty ? formattedContexts.join(' ') : null,
      keyValuesStringSet.isNotEmpty ? keyValuesStringSet.join(' ') : null,
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

  String toDebugString() => '${toString()} (DEBUG: selected: $selected)';

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

  static bool _str2completion(String value) {
    // A completed task starts with an lowercase x character.
    return value == 'x';
  }

  static String? _str2priority(String value) {
    RegExpMatch? match = patternPriority.firstMatch(value);
    if (match != null) {
      return match.namedGroup("priority");
    } else {
      // Priority is optional.
      return null;
    }
  }

  /// Trim projects, contexts and key-values from description.
  static String _str2description(List<String> descriptionList) {
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

  static Set<String>? _str2projects(List<String> fullDescriptionList) {
    Set<String> projects = {};
    for (var project in fullDescriptionList) {
      if (patternProject.hasMatch(project)) {
        projects.add(project.substring(1)); // strip the leading '+'
      }
    }

    return projects.isNotEmpty ? projects : null;
  }

  static Set<String>? _str2contexts(List<String> fullDescriptionList) {
    Set<String> contexts = {};
    for (var context in fullDescriptionList) {
      if (patternContext.hasMatch(context)) {
        contexts.add(context.substring(1)); // strip the leading '@'
      }
    }

    return contexts.isNotEmpty ? contexts : null;
  }

  static Map<String, String>? _str2keyValues(List<String> fullDescriptionList) {
    Map<String, String> keyValues = {};

    for (var keyValue in fullDescriptionList) {
      if (patternKeyValue.hasMatch(keyValue)) {
        final List<String> splittedKeyValue = keyValue.split(":");
        if (splittedKeyValue.length > 2) continue;
        keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
      }
    }

    return keyValues.isNotEmpty ? keyValues : null;
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
}
