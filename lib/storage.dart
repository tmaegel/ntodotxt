import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Task {
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

  String patternCompletion = r'^x\s+';
  String patternPriority = r'\((?<priority>[A-Z])\)\s+';
  String patternDates = r'((?<date>\d{4}-\d{2}-\d{2}))\s+';
  String patternProjects =
      r'(\s+(?<project>\+\S+))'; // Any non-whitespace character is allowed.
  String patternContexts =
      r'(\s+(?<context>\@\S+))'; // Any non-whitespace character is allowed.
  String patternKeyValues =
      r'(\s+(?<keyvalue>\S+:\S+))'; // Any non-whitespace character is allowed.
  String patternDescription =
      r'^(x\s?)?(\([A-Z]\)\s?)?(\d{4}-\d{2}-\d{2}\s?){0,2}((?<description>.+))?$';

  String taskStr = "";
  bool completion = false;
  String priority = "";
  DateTime? completionDate;
  DateTime? creationDate;
  List<String> projects = [];
  List<String> contexts = [];
  Map<String, String> keyValues = {};
  String description = "";

  Task(this.taskStr) {
    completion = getCompletion();
    description = getDescription();
    final dates = getDates();
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
    priority = getPriority();
    projects = getProjects();
    contexts = getContexts();
    keyValues = getKeyValues();
  }

  void trimWhitespaces() {
    // Trim leading and trailing whitespaces before.
    taskStr = taskStr.trim().replaceAllMapped(RegExp(r'\b\s{2,}\b'), (match) {
      return " ";
    });
  }

  bool getCompletion() {
    return RegExp(patternCompletion).hasMatch(taskStr);
  }

  String getPriority() {
    final match = RegExp(patternPriority).firstMatch(taskStr);
    return match?.namedGroup("priority") ?? ""; // Priority is optional.
  }

  String getDescription() {
    final match = RegExp(patternDescription).firstMatch(taskStr);
    final description = match?.namedGroup("description") ?? "";
    if (description.isEmpty) {
      throw const FormatException("Description is mandatory.");
    }

    return description;
  }

  List<DateTime> getDates() {
    List<DateTime> dates = [];
    final matches = RegExp(patternDates).allMatches(taskStr);
    for (var match in matches) {
      final date = match.namedGroup("date");
      if (date != null) {
        dates.add(DateTime.parse(date));
      }
    }

    return dates;
  }

  List<String> getProjects() {
    List<String> projects = [];
    final matches = RegExp(patternProjects).allMatches(taskStr);
    for (var match in matches) {
      final project = match.namedGroup("project");
      if (project != null) {
        projects.add(project.replaceFirst("+", ""));
      }
    }

    return projects;
  }

  List<String> getContexts() {
    List<String> contexts = [];
    final matches = RegExp(patternContexts).allMatches(taskStr);
    for (var match in matches) {
      final context = match.namedGroup("context");
      if (context != null) {
        contexts.add(context.replaceFirst("@", ""));
      }
    }

    return contexts;
  }

  Map<String, String> getKeyValues() {
    Map<String, String> keyValues = {};
    final matches = RegExp(patternKeyValues).allMatches(taskStr);
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
}

class Tasks {
  String todoFile;
  Tasks(this.todoFile);

  // Find the path to the documents directory.
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  // Create a reference to the file’s full location.
  Future<File> get localFile async {
    final path = await localPath;

    return File('$path/$todoFile');
  }

  // Read task file.
  Future<List<Task>> read() async {
    final List<Task> tasks = [];
    final file = await localFile;
    final lines = file.readAsLinesSync();
    for (var line in lines) {
      tasks.add(Task(line));
    }

    return tasks;
  }

  // Write task file.
  void write(List<String> tasks) async {
    final file = await localFile;
    file.writeAsStringSync(tasks.join('\n'));
  }
}
