import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

// General:
// A context is preceded by a single space and an at-sign (@).
// A project is preceded by a single space and a plus-sign (+).
// A project or context contains any non-whitespace character.
// A task may have zero, one, or more than one projects and contexts included in it.

// Incomplete Tasks: Format rules
// 1) If priority exists, it ALWAYS appears first.
// 2) A task's creation date may optionally appear directly after priority and a space.
// 3) Contexts and Projects may appear anywhere in the line after priority/prepended date.

// Complete Tasks: Format rules
// 1) A completed task starts with an lowercase x character followed directly by a space character.
// 2) The date of completion appears directly after the x, separated by a space.

// Additional File Format Definitions
// Developers should use the format key:value to define additional metadata (e.g. due:2010-01-02 as a due date).
// Both key and value must consist of non-whitespace characters, which are not colons.
// Only one colon separates the key and value.

class Task {
  String task;
  Task(this.task);

  String get raw {
    return task;
  }

  void trimWhitespaces() {
    // Trim leading and trailing whitespaces before.
    task = task.trim().replaceAllMapped(RegExp(r'\b\s{2,}\b'), (match) {
      return " ";
    });
  }

  bool get status {
    return RegExp(r'^x .*$').hasMatch(task);
  }

  set status(bool newStatus) {
    final matches =
        RegExp(r'^(?<status>x )?(\((?<priority>[A-Z])\) )?(?<rest>.*)$')
            .firstMatch(task);
    final String priority = matches?.namedGroup("priority") ?? "";
    final String rest = matches?.namedGroup("rest") ?? "";
    if (newStatus) {
      // Mark task as completed.
      task = "x $rest";
      // Remove priority here and save as key-value!
      if (priority.isNotEmpty) {
        addKeyValueTag("pri", priority);
      }
    } else {
      // Mark task as incomplete.
      task = rest;
      // And restore priority if exist!
      final keyValueTags = this.keyValueTags;
      removeKeyValueTag("pri");
      if (keyValueTags.containsKey('pri')) {
        this.priority = keyValueTags["pri"] ?? "";
      }
    }
  }

  String get priority {
    final matches = RegExp(r'^(\((?<priority>[A-Z])\) )?.*$').firstMatch(task);
    return matches?.namedGroup("priority") ?? ""; // Priority is optional.
  }

  set priority(String priority) {
    final matches =
        RegExp(r'^(?<status>x )?(?<priority>\([A-Z]\) )?(?<rest>.*)$')
            .firstMatch(task);
    final statusMatch = matches?.namedGroup("status") ?? "";
    final restMatch = matches?.namedGroup("rest") ?? "";
    task = '$statusMatch($priority) $restMatch';
  }

  // void get description() {}
  // void set description(String description) {}

  List<String> get projectTags {
    List<String> projects = [];
    // Any non-whitespace character is allowed.
    final matches = RegExp(r'( (?<project>\+\S+))').allMatches(task);
    for (var project in matches) {
      final tag = project.namedGroup("project");
      if (tag != null) {
        projects.add(tag.replaceFirst("+", ""));
      }
    }

    return projects;
  }

  void addProjectTag() {}
  void removeProjectTag() {}
  void setProjectTags() {}

  List<String> get contextTags {
    List<String> contexts = [];
    // Any non-whitespace character is allowed.
    final matches = RegExp(r'( (?<context>\@\S+))').allMatches(task);
    for (var context in matches) {
      final tag = context.namedGroup("context");
      if (tag != null) {
        contexts.add(tag.replaceFirst("@", ""));
      }
    }

    return contexts;
  }

  void addContextTag() {}
  void removeContextTag() {}
  void setContextTags() {}

  Map<String, String> get keyValueTags {
    Map<String, String> keyValues = {};
    // Any non-whitespace character is allowed.
    final matches = RegExp(r'( (?<keyvalue>\S+:\S+))').allMatches(task);
    for (var keyValue in matches) {
      final tag = keyValue.namedGroup("keyvalue");
      if (tag != null) {
        final splittedTag = tag.split(":");
        if (splittedTag.length > 2) continue;
        keyValues[splittedTag[0]] = splittedTag[1];
      }
    }

    return keyValues;
  }

  set keyValueTags(Map<String, String> newKeyValueTags) {
    // Remove all key value tags.
    for (final tag in keyValueTags.entries) {
      task = task.replaceAll("${tag.key}:${tag.value}", "");
    }
    // Set new key value tags.
    for (final tag in newKeyValueTags.entries) {
      task = "$task ${tag.key}:${tag.value}";
    }
    trimWhitespaces();
  }

  void addKeyValueTag(String key, String value) {
    // Add new key value tag if it does not already exist.
    if (!keyValueTags.containsKey(key)) {
      task = "$task $key:$value";
    }
  }

  void removeKeyValueTag(String key) {
    final keyValueTags = this.keyValueTags;
    keyValueTags.remove(key);
    this.keyValueTags = keyValueTags;
  }

  DateTime? get completionDate {
    // The date of completion appears directly after the x,
    // separated by a space.
    DateTime? completionDate;
    final matches = RegExp(
            r'^(x )?((?<completion>\d{4}-\d{2}-\d{2}) )?(\([A-Z]\) )?((?<creation>\d{4}-\d{2}-\d{2}) ).*$')
        .firstMatch(task);
    final completionStr = matches?.namedGroup("completion");
    final creationStr = matches?.namedGroup("creation");

    if (completionStr == null && creationStr == null) {
      return null;
    } else if (completionStr == null && creationStr != null) {
      // If status is set there should a completion date too.
      if (status) {
        throw const FormatException(
            "Completion date is mandatory if status is set.");
      }
      // If one date detected its the creation date. Return here.
      return null;
    } else if (completionStr != null && creationStr != null) {
      // Status is mandatory if the completion date is set.
      if (!status) {
        throw const FormatException(
            "Status is mandatory if completion date is set.");
      }
      // If two dates are detected the first is the completion date.
      completionDate = DateTime.parse(completionStr);
    }

    return completionDate;
  }

  DateTime? get creationDate {
    DateTime? creationDate;
    final matches = RegExp(
            r'^(x )?((?<completion>\d{4}-\d{2}-\d{2}) )?(\([A-Z]\) )?((?<creation>\d{4}-\d{2}-\d{2}) ).*$')
        .firstMatch(task);
    final completionStr = matches?.namedGroup("completion");
    final creationStr = matches?.namedGroup("creation");

    if (completionStr == null && creationStr == null) {
      return null;
    } else if (completionStr == null && creationStr != null) {
      // If status is set there should a completion date too.
      if (status) {
        throw const FormatException(
            "Completion date is mandatory if status is set.");
      }
      // If one date detected its the creation date.
      creationDate = DateTime.parse(creationStr);
    } else if (completionStr != null && creationStr != null) {
      // Status is mandatory if the completion date is set.
      if (!status) {
        throw const FormatException(
            "Status is mandatory if completion date is set.");
      }
      // If two dates are detected the second is the creation date.
      creationDate = DateTime.parse(creationStr);
    }

    return creationDate;
  }
}

class TasksFile {
  String todoFile = "todo.txt";

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

  Future<int> read() async {
    try {
      final file = await localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  // Write task file.
  void write(List<String> tasks) async {
    final file = await localFile;
    file.writeAsStringSync(tasks.join('\n'));
  }
}
