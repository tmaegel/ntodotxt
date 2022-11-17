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

  bool get status {
    return RegExp(r'^x .*$').hasMatch(task);
  }

  set status(bool status) {
    final matches =
        RegExp(r'^(?<status>x )?(\((?<priority>[A-Z])\) )?(?<rest>.*)$')
            .firstMatch(task);
    final String priority = matches?.namedGroup("priority") ?? "";
    final String rest = matches?.namedGroup("rest") ?? "";
    if (status) {
      // Mark task as completed.
      // Remove priority here and save as key-value!
      task = "x $rest";
      if (priority.isNotEmpty) {
        task = "$task pri:$priority";
      }
    } else {
      // Mark task as incomplete.
      // @todo: Restore priority here!
      task = rest;
    }
  }

  set priority(String priority) {
    final matches =
        RegExp(r'^(?<status>x )?(?<priority>\([A-Z]\) )?(?<rest>.*)$')
            .firstMatch(task);
    final statusMatch = matches?.namedGroup("status") ?? "";
    final restMatch = matches?.namedGroup("rest") ?? "";
    task = '$statusMatch($priority) $restMatch';
  }

  String get priority {
    final matches = RegExp(r'^\((?<priority>[A-Z])\) .*$').firstMatch(task);
    return matches?.namedGroup("priority") ?? ""; // Priority is optional.
  }

  // void get description() {}
  // void set description(String description) {}

  void addProjectTag() {}
  void removeProjectTag() {}
  void setProjectTags() {}

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

  void addContextTag() {}
  void removeContextTag() {}
  void setContextTags() {}

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

  void addKeyValueTag() {}
  void removeKeyValueTag() {}
  void getKeyValueTags() {}
  void setKeyValueTags() {}
}

class NotesStorage {
  // Find the path to the documents directory.
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  // Create a reference to the file’s full location.
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}
