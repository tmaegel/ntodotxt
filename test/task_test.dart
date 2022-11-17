import 'package:flutter_test/flutter_test.dart';

import 'package:todotxt/storage.dart';

void main() {
  group("get: status", () {
    test("Task is completed", () {
      final task = Task("x 2022-11-16 2022-11-01 Call Mom");
      expect(task.status, true);
    });
    test("Task is incompleted (missing mark)", () {
      final task = Task("2022-11-16 2022-11-01 Call Mom");
      expect(task.status, false);
    });
    test("Task is incompleted (missing whitespace)", () {
      final task = Task("xylophone lesson");
      expect(task.status, false);
    });
    test("Task is incompleted (wrong mark)", () {
      final task = Task("X 2022-11-16 2022-11-01 Call Mom");
      expect(task.status, false);
    });
    test("Task is incompleted (wrong position)", () {
      final task = Task("(A) x 2022-11-16 2022-11-01 Call Mom");
      expect(task.status, false);
    });
  });

  // group("set: status", () {
  //   test("Status of task is set as completed", () {
  //     const String taskRaw = "Call Mom";
  //     final task = Task(taskRaw);
  //     task.status = true;
  //     expect(task.status, true);
  //     expect(task.raw, "x Call Mom");
  //   });
  //   test("Status of task is set as incompleted", () {
  //     const String taskRaw = "x Call Mom";
  //     final task = Task(taskRaw);
  //     task.status = false;
  //     expect(task.status, false);
  //     expect(task.raw, "Call Mom");
  //   });
  //   test("Status of task is set as completed when already completed", () {
  //     const String taskRaw = "x Call Mom";
  //     final task = Task(taskRaw);
  //     task.status = true;
  //     expect(task.status, true);
  //     expect(task.raw, taskRaw);
  //   });
  //   test("Status of task is set as incompleted when already incompleted", () {
  //     const String taskRaw = "Call Mom";
  //     final task = Task(taskRaw);
  //     task.status = false;
  //     expect(task.status, false);
  //     expect(task.raw, taskRaw);
  //   });
  //   test("Status of task with priority is set as completed", () {
  //     const String taskRaw = "(A) Call Mom";
  //     final task = Task(taskRaw);
  //     task.status = true;
  //     expect(task.status, true);
  //     expect(task.raw, "x Call Mom pri:A");
  //   });
  //   test("Status of task with priority is set as incompleted", () {
  //     const String taskRaw = "x Call Mom pri:A";
  //     final task = Task(taskRaw);
  //     task.status = false;
  //     expect(task.status, false);
  //     expect(task.raw, "(A) Call Mom");
  //   });
  // });

  group("get: priority", () {
    test("Task with priority", () {
      final task = Task("(A) Call Mom");
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

  group("set: priority", () {
    test("Priority of task is set", () {
      final task = Task("Call Mom");
      task.priority = "A";
      expect(task.priority, "A");
      expect(task.raw, "(A) Call Mom");
    });
    test("Priority of task is change", () {
      final task = Task("(A) Call Mom");
      task.priority = "B";
      expect(task.priority, "B");
      expect(task.raw, "(B) Call Mom");
    });
  });

  group("get: completion date", () {
    test("Completion date is set", () {
      final task = Task("x 2022-11-16 (A) 2022-11-01 Call Mom");
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (without priority)", () {
      final task = Task("x 2022-11-16 2022-11-01 Call Mom");
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (without one date in description)", () {
      final task = Task("x 2022-11-16 2022-11-01 2022-08-10 Call Mom");
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (without one date in description)", () {
      final task =
          Task("x 2022-11-16 2022-11-01 2022-08-10 2022-08-09 Call Mom");
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is unset if status is missing (incompleted task)",
        () {
      final task = Task("(A) 2022-11-01 Call Mom");
      expect(task.completionDate, null);
    });
    test(
        "Completion date throw exception if status is missing (status is mandatory)",
        () {
      final task = Task("2022-11-16 (A) 2022-11-01 Call Mom");
      expect(() => task.completionDate, throwsA(isA<FormatException>()));
    });
    test(
        "Completion date thow exception if creation date is missing (creation date is mandatory)",
        () {
      final task = Task("x 2022-11-16 (A) Call Mom");
      expect(() => task.completionDate, throwsA(isA<FormatException>()));
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
    test("Creation date is set (with status, priority & completion date)", () {
      final task = Task("x 2022-11-16 (A) 2022-11-01 Call Mom");
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with one date in description)", () {
      final task = Task("(A) 2022-11-01 2022-08-10 Call Mom");
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with two dates in description)", () {
      final task = Task("(A) 2022-11-01 2022-08-10 2022-08-09 Call Mom");
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
      final task = Task("x 2022-11-16 (A) Call Mom");
      expect(() => task.creationDate, throwsA(isA<FormatException>()));
    });
    test(
        "Creation date throw exception if status is missing (status is mandatory)",
        () {
      final task = Task("2022-11-16 (A) 2022-11-01 Call Mom");
      expect(() => task.creationDate, throwsA(isA<FormatException>()));
    });
  });

  group("get: project", () {
    test("No project is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.projectTags, []);
    });
    test("Single project is set", () {
      final task = Task("2022-11-01 Call Mom +home");
      expect(task.projectTags, ["home"]);
    });
    test("Multiple projects are set", () {
      final task = Task("2022-11-01 Call Mom +home +phone");
      expect(task.projectTags, ["home", "phone"]);
    });
    test("Multiple projects are set (not in row)", () {
      final task = Task("2022-11-01 Call +home Mom +phone");
      expect(task.projectTags, ["home", "phone"]);
    });
    test("Project with special name is set", () {
      final task = Task("2022-11-01 Call Mom +home-phone+_123");
      expect(task.projectTags, ["home-phone+_123"]);
    });
  });

  group("get: context", () {
    test("No context is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.contextTags, []);
    });
    test("Single context is set", () {
      final task = Task("2022-11-01 Call Mom @home");
      expect(task.contextTags, ["home"]);
    });
    test("Multiple contexts are set", () {
      final task = Task("2022-11-01 Call Mom @home @phone");
      expect(task.contextTags, ["home", "phone"]);
    });
    test("Multiple contexts are set (not in row)", () {
      final task = Task("2022-11-01 Call @home Mom @phone");
      expect(task.contextTags, ["home", "phone"]);
    });
    test("Context with special name is set", () {
      final task = Task("2022-11-01 Call Mom @home-phone@_123");
      expect(task.contextTags, ["home-phone@_123"]);
    });
  });

  group("get: key values", () {
    test("No key value is set", () {
      final task = Task("2022-11-01 Call Mom");
      expect(task.keyValueTags, {});
    });
    test("Single key value is set", () {
      const String taskRaw = "2022-11-01 Call Mom key:value";
      final task = Task(taskRaw);
      expect(task.keyValueTags, {"key": "value"});
    });
    test("Multiple key values are set", () {
      const String taskRaw = "2022-11-01 Call Mom key1:value1 key2:value2";
      final task = Task(taskRaw);
      expect(task.keyValueTags, {"key1": "value1", "key2": "value2"});
    });
    test("Multiple key values are set (not in row)", () {
      const String taskRaw = "2022-11-01 Call key1:value1 Mom key2:value2";
      final task = Task(taskRaw);
      expect(task.keyValueTags, {"key1": "value1", "key2": "value2"});
    });
    test("Key value with special name is set", () {
      const String taskRaw = "2022-11-01 Call Mom key-@_123:value_@123";
      final task = Task(taskRaw);
      expect(task.keyValueTags, {"key-@_123": "value_@123"});
    });
    test("Invalud key value is set", () {
      const String taskRaw = "2022-11-01 Call Mom key1:value1:invalid";
      final task = Task(taskRaw);
      expect(task.keyValueTags, {});
    });
  });
}
