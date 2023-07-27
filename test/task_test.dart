import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/task.dart';

void main() {
  group("get: completion", () {
    test("Task is completed", () {
      final task = Task("x 2022-11-16 2022-11-01 Call Mom");
      expect(task.completion, true);
    });
    test("Task is incompleted (missing mark)", () {
      final task = Task("2022-11-16 Call Mom");
      expect(task.completion, false);
    });
    test("Task is incompleted (missing whitespace)", () {
      final task = Task("xCall mom");
      expect(task.completion, false);
    });
    test("Task is incompleted (wrong mark)", () {
      final task = Task("X 2022-11-16 Call Mom");
      expect(task.completion, false);
    });
    test("Task is incompleted (wrong position)", () {
      final task = Task("(A) x 2022-11-16 Call Mom");
      expect(task.completion, false);
    });
  });

  group("get: priority", () {
    test("Task with priority", () {
      final task = Task("(A) Call Mom");
      expect(task.priority, "A");
    });
    test("Task with priority and completion", () {
      final task = Task("x (A) Call Mom");
      expect(task.priority, "A");
    });
    test("Task without priority (missing priority)", () {
      final task = Task("Call Mom");
      expect(task.priority, "");
    });
    test("Task without priority (missing parenthesis)", () {
      final task = Task("A Call Mom");
      expect(task.priority, "");
    });
    test("Task without priority (missing whitespace)", () {
      final task = Task("(A)Call Mom");
      expect(task.priority, "");
    });
    test("Task without priority (wrong priority sign)", () {
      final task = Task("(a) Call Mom");
      expect(task.priority, "");
    });
    test("Task without priority (wrong position)", () {
      final task = Task("Call Mom (A)");
      expect(task.priority, "");
    });
  });

  group("get: creation date", () {
    test("Creation date is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with priority)", () {
      final task = Task("(A) 2022-11-01 Call Mom");
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with status & completion date)", () {
      final task = Task("x 2022-11-16 2022-11-01 Call Mom");
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is unset", () {
      final task = Task("Call Mom");
      expect(task.creationDate, null);
    });
    test("Creation date is unset (with priority)", () {
      final task = Task("(A) Call Mom");
      expect(task.creationDate, null);
    });
    test(
        "Creation date throw exception if creation date is missing (creation date is mandatory)",
        () {
      expect(
          () => Task("x 2022-11-16 Call Mom"), throwsA(isA<FormatException>()));
    });
    test(
        "Creation date throw exception if status is missing (status is mandatory)",
        () {
      expect(() => Task("2022-11-16 (2022-11-01 Call Mom"),
          throwsA(isA<FormatException>()));
    });
  });

  group("get: completion date", () {
    test("Completion date is set", () {
      final task = Task("x 2022-11-16 2022-11-01 Call Mom");
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (with one date in description)", () {
      final task = Task("x 2022-11-16 2022-11-01 2022-08-10 Call Mom");
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is unset", () {
      final task = Task("Call Mom");
      expect(task.completionDate, null);
    });
    test("Completion date is unset if status is missing (incompleted task)",
        () {
      final task = Task("(A) 2022-11-01 Call Mom");
      expect(task.completionDate, null);
    });
    test(
        "Completion date throw exception if status is missing (status is mandatory)",
        () {
      expect(() => Task("2022-11-16 (A) 2022-11-01 Call Mom"),
          throwsA(isA<FormatException>()));
    });
    test(
        "Completion date thow exception if creation date is missing (creation date is mandatory)",
        () {
      expect(() => Task("x 2022-11-16 (A) Call Mom"),
          throwsA(isA<FormatException>()));
    });
  });

  group("get: project", () {
    test("No project is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.projects, []);
    });
    test("Single project is set", () {
      final task = Task("2022-11-01 Call Mom +home");
      expect(task.projects, ["home"]);
    });
    test("Multiple projects are set", () {
      final task = Task("2022-11-01 Call Mom +home +phone");
      expect(task.projects, ["home", "phone"]);
    });
    test("Multiple projects are set (not in sequence)", () {
      final task = Task("2022-11-01 Call +home Mom +phone");
      expect(task.projects, ["home", "phone"]);
    });
    test("Project with special name is set", () {
      final task = Task("2022-11-01 Call Mom +home-phone+_123");
      expect(task.projects, ["home-phone+_123"]);
    });
  });

  group("get: context", () {
    test("No context is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.contexts, []);
    });
    test("Single context is set", () {
      final task = Task("2022-11-01 Call Mom @home");
      expect(task.contexts, ["home"]);
    });
    test("Multiple contexts are set", () {
      final task = Task("2022-11-01 Call Mom @home @phone");
      expect(task.contexts, ["home", "phone"]);
    });
    test("Multiple contexts are set (not in sequence)", () {
      final task = Task("2022-11-01 Call @home Mom @phone");
      expect(task.contexts, ["home", "phone"]);
    });
    test("Context with special name is set", () {
      final task = Task("2022-11-01 Call Mom @home-phone@_123");
      expect(task.contexts, ["home-phone@_123"]);
    });
  });

  group("get: key value tags", () {
    test("No key value is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.keyValues, {});
    });
    test("Single key value is set", () {
      final task = Task("2022-11-01 Call Mom key:value");
      expect(task.keyValues, {"key": "value"});
    });
    test("Multiple key values are set", () {
      final task = Task("2022-11-01 Call Mom key1:value1 key2:value2");
      expect(task.keyValues, {"key1": "value1", "key2": "value2"});
    });
    test("Multiple key values are set (not in sequence)", () {
      final task = Task("2022-11-01 Call key1:value1 Mom key2:value2");
      expect(task.keyValues, {"key1": "value1", "key2": "value2"});
    });
    test("Key value with special name is set", () {
      final task = Task("2022-11-01 Call Mom key-@_123:value_@123");
      expect(task.keyValues, {"key-@_123": "value_@123"});
    });
    test("Invalid key value is set", () {
      final task = Task("2022-11-01 Call Mom key1:value1:invalid");
      expect(task.keyValues, {});
    });
  });

  group("get: description", () {
    test(
        "Description ist empty and throws an expection (Description is mandatory)",
        () {
      expect(() => Task("x 2022-11-16 2022-11-01"),
          throwsA(isA<FormatException>()));
    });
    test(
        "Description ist empty and throws an expection (Description is mandatory)",
        () {
      expect(() => Task("(A)"), throwsA(isA<FormatException>()));
    });
    test(
        "Description ist empty and throws an expection (Description is mandatory)",
        () {
      expect(() => Task("x (A)"), throwsA(isA<FormatException>()));
    });
    test(
        "Description ist empty and throws an expection (Description is mandatory)",
        () {
      expect(() => Task("x"), throwsA(isA<FormatException>()));
    });
    test("description only", () {
      final task = Task("Call Mom");
      expect(task.description, "Call Mom");
    });
    test("description with priority", () {
      final task = Task("(A) Call Mom");
      expect(task.description, "Call Mom");
    });
    test("description with priority and completion", () {
      final task = Task("x (A) Call Mom");
      expect(task.description, "Call Mom");
    });
    test("description with completion and dates", () {
      final task = Task("x 2022-11-16 2022-11-01 Call Mom");
      expect(task.description, "Call Mom");
    });
  });
}
