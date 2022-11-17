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
      const String taskRaw = "Call Mom";
      final task = Task(taskRaw);
      task.priority = "A";
      expect(task.priority, "A");
      expect(task.raw, "(A) $taskRaw");
    });
    test("Priority of task is change", () {
      const String taskRaw = "(A) Call Mom";
      final task = Task(taskRaw);
      task.priority = "B";
      expect(task.priority, "B");
      expect(task.raw, "(B) Call Mom");
    });
  });

  group("get: completion date", () {
    test("Completion date is set", () {
      const String taskRaw = "x 2022-11-16 (A) 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (without priority)", () {
      const String taskRaw = "x 2022-11-16 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (without one date in description)", () {
      const String taskRaw = "x 2022-11-16 2022-11-01 2022-08-10 Call Mom";
      final task = Task(taskRaw);
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is set (without one date in description)", () {
      const String taskRaw =
          "x 2022-11-16 2022-11-01 2022-08-10 2022-08-09 Call Mom";
      final task = Task(taskRaw);
      expect(task.completionDate, DateTime.parse("2022-11-16"));
    });
    test("Completion date is unset if status is missing (incompleted task)",
        () {
      const String taskRaw = "(A) 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.completionDate, null);
    });
    test(
        "Completion date throw exception if status is missing (status is mandatory)",
        () {
      const String taskRaw = "2022-11-16 (A) 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(() => task.completionDate, throwsA(isA<FormatException>()));
    });
    test(
        "Completion date thow exception if creation date is missing (creation date is mandatory)",
        () {
      const String taskRaw = "x 2022-11-16 (A) Call Mom";
      final task = Task(taskRaw);
      expect(() => task.completionDate, throwsA(isA<FormatException>()));
    });
  });

  group("get: creation date", () {
    test("Creation date is set", () {
      const String taskRaw = "2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with priority)", () {
      const String taskRaw = "(A) 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with status, priority & completion date)", () {
      const String taskRaw = "x 2022-11-16 (A) 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with one date in description)", () {
      const String taskRaw = "(A) 2022-11-01 2022-08-10 Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is set (with two dates in description)", () {
      const String taskRaw = "(A) 2022-11-01 2022-08-10 2022-08-09 Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, DateTime.parse("2022-11-01"));
    });
    test("Creation date is unset", () {
      const String taskRaw = "Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, null);
    });
    test("Creation date is unset (with priority)", () {
      const String taskRaw = "(A) Call Mom";
      final task = Task(taskRaw);
      expect(task.creationDate, null);
    });
    test(
        "Creation date throw exception if creation date is missing (creation date is mandatory)",
        () {
      const String taskRaw = "x 2022-11-16 (A) Call Mom";
      final task = Task(taskRaw);
      expect(() => task.creationDate, throwsA(isA<FormatException>()));
    });
    test(
        "Creation date throw exception if status is missing (status is mandatory)",
        () {
      const String taskRaw = "2022-11-16 (A) 2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(() => task.creationDate, throwsA(isA<FormatException>()));
    });
  });

  group("get: project", () {
    test("No project is set", () {
      const String taskRaw = "2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.projectTags, []);
    });
    test("Single project is set", () {
      const String taskRaw = "2022-11-01 Call Mom +home";
      final task = Task(taskRaw);
      expect(task.projectTags, ["home"]);
    });
    test("Multiple projects is set", () {
      const String taskRaw = "2022-11-01 Call Mom +home +phone";
      final task = Task(taskRaw);
      expect(task.projectTags, ["home", "phone"]);
    });
    test("Multiple projects is set (not in row)", () {
      const String taskRaw = "2022-11-01 Call +home Mom +phone";
      final task = Task(taskRaw);
      expect(task.projectTags, ["home", "phone"]);
    });
    test("Project with special name is set", () {
      const String taskRaw = "2022-11-01 Call Mom +home-phone+_123";
      final task = Task(taskRaw);
      expect(task.projectTags, ["home-phone+_123"]);
    });
  });

  group("get: context", () {
    test("No context is set", () {
      const String taskRaw = "2022-11-01 Call Mom";
      final task = Task(taskRaw);
      expect(task.contextTags, []);
    });
    test("Single context is set", () {
      const String taskRaw = "2022-11-01 Call Mom @home";
      final task = Task(taskRaw);
      expect(task.contextTags, ["home"]);
    });
    test("Multiple contexts is set", () {
      const String taskRaw = "2022-11-01 Call Mom @home @phone";
      final task = Task(taskRaw);
      expect(task.contextTags, ["home", "phone"]);
    });
    test("Multiple contexts is set (not in row)", () {
      const String taskRaw = "2022-11-01 Call @home Mom @phone";
      final task = Task(taskRaw);
      expect(task.contextTags, ["home", "phone"]);
    });
    test("Context with special name is set", () {
      const String taskRaw = "2022-11-01 Call Mom @home-phone@_123";
      final task = Task(taskRaw);
      expect(task.contextTags, ["home-phone@_123"]);
    });
  });
}
