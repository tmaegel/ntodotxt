import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

void main() {
  setUp(() {});

  group("todo Todo()", () {
    group("completion & completionDate", () {
      test("initial incompleted", () {
        final todo = Todo(description: 'Write some tests');
        expect(todo.completion, false);
        expect(todo.completionDate, null);
      });
      test("initial completed", () {
        final DateTime now = DateTime.now();
        final todo = Todo(completion: true, description: 'Write some tests');
        expect(todo.completion, true);
        expect(todo.completionDate, DateTime(now.year, now.month, now.day));
      });
      test("initial completed & completionDate", () {
        final todo = Todo(
            completion: true,
            completionDate: DateTime(1970, 1, 1),
            description: 'Write some tests');
        expect(todo.completion, true);
        expect(todo.completionDate, DateTime(1970, 1, 1));
      });
    });

    group("priority", () {
      test("no initial priority", () {
        final todo = Todo(description: 'Write some tests');
        expect(todo.priority, null);
      });
      test("with initial priority", () {
        final todo = Todo(priority: 'A', description: 'Write some tests');
        expect(todo.priority, 'A');
      });
    });

    group("creationDate", () {
      test("no initial creationDate", () {
        final DateTime now = DateTime.now();
        final todo = Todo(description: 'Write some tests');
        expect(todo.creationDate, DateTime(now.year, now.month, now.day));
      });
      test("with initial creationDate", () {
        final DateTime now = DateTime.now();
        final todo = Todo(creationDate: now, description: 'Write some tests');
        expect(todo.creationDate, DateTime(now.year, now.month, now.day));
      });
    });

    group("description", () {
      test("no initial description", () {
        final todo = Todo();
        expect(todo.description, '');
      });
      test("with initial description", () {
        final todo = Todo(description: 'Write some tests');
        expect(todo.description, 'Write some tests');
      });
    });

    group("projects", () {
      test("no initial projects", () {
        final Todo todo = Todo(description: 'Write some tests');
        expect(todo.projects, []);
      });
      test("with initial projects", () {
        final Todo todo =
            Todo(description: 'Write some tests', projects: const {'project1'});
        expect(todo.projects, {'project1'});
      });
    });

    group("contexts", () {
      test("no initial contexts", () {
        final Todo todo = Todo(description: 'Write some tests');
        expect(todo.contexts, []);
      });
      test("with initial contexts", () {
        final Todo todo =
            Todo(description: 'Write some tests', contexts: const {'context1'});
        expect(todo.contexts, {'context1'});
      });
    });

    group("keyValues", () {
      test("no initial keyValues", () {
        final Todo todo = Todo(description: 'Write some tests');
        expect(todo.keyValues, {'id': todo.id});
      });
      test("with initial keyValues", () {
        final Todo todo = Todo(
            description: 'Write some tests', keyValues: const {'key': 'value'});
        expect(todo.keyValues, {'key': 'value', 'id': todo.id});
      });
    });

    group("selected", () {
      test("initial unselected", () {
        final Todo todo = Todo(description: 'Write some tests');
        expect(todo.selected, false);
      });
      test("initial selected", () {
        final Todo todo = Todo(selected: true, description: 'Write some tests');
        expect(todo.selected, true);
      });
    });
  });

  group("todo copyWith()", () {
    group("completion & completionDate", () {
      test("set completion", () {
        final DateTime now = DateTime.now();
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(completion: true);
        expect(todo2.completion, true);
        expect(todo2.completionDate, DateTime(now.year, now.month, now.day));
      });
      test("set completion & completionDate", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(
            completion: true, completionDate: DateTime(1970, 1, 1));
        expect(todo2.completion, true);
        expect(todo2.completionDate, DateTime(1970, 1, 1));
      });
      test("unset completion", () {
        final Todo todo =
            Todo(completion: true, description: 'Write some tests');
        final todo2 = todo.copyWith(completion: false);
        expect(todo2.completion, false);
        expect(todo2.completionDate, null);
      });
    });

    group("priority", () {
      test("set priority", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(priority: 'A');
        expect(todo2.priority, 'A');
      });
      test("unset priority", () {
        final Todo todo = Todo(priority: 'A', description: 'Write some tests');
        final todo2 = todo.copyWith(priority: '');
        expect(todo2.priority, null);
      });
    });

    group("creationDate", () {});

    group("description", () {
      test("set description", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(description: 'Write more tests');
        expect(todo2.description, 'Write more tests');
      });
      test("unset description", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(description: '');
        expect(todo2.description, '');
      });
    });

    group("projects", () {
      test("set projects", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(projects: const {'project2'});
        expect(todo2.projects, {'project2'});
      });
      test("unset projects", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(projects: const {});
        expect(todo2.projects, []);
      });
    });

    group("contexts", () {
      test("set contexts", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(contexts: const {'context2'});
        expect(todo2.contexts, {'context2'});
      });
      test("unset contexts", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(contexts: const {});
        expect(todo2.contexts, []);
      });
    });

    group("keyValues", () {
      test("set keyValues", () {
        final Todo todo = Todo(description: 'Write some tests');
        final todo2 = todo.copyWith(keyValues: const {'key': 'value'});
        expect(todo2.keyValues, {'key': 'value', 'id': todo.id});
      });
      test("unset keyValues", () {
        final Todo todo =
            Todo(description: 'Write some tests', keyValues: const {});
        final todo2 = todo.copyWith(contexts: const {});
        expect(todo2.keyValues, {'id': todo.id});
      });
    });

    group("selected", () {
      test("set selected", () {
        final Todo todo = Todo(description: 'Write some tests');
        final Todo todo2 = todo.copyWith(selected: true);
        expect(todo2.selected, true);
      });
      test("unset selected", () {
        final Todo todo = Todo(selected: true, description: 'Write some tests');
        final Todo todo2 = todo.copyWith(selected: false);
        expect(todo2.selected, false);
      });
    });
  });

  group("todo copyDiff()", () {
    test("copy explizit set attributes but keep creationDate if set", () {
      final DateTime now = DateTime.now();
      final Todo todo = Todo(priority: 'A', description: 'Write some tests');
      final Todo todo2 = todo.copyDiff(completion: true);
      expect(todo2.completion, true);
      expect(todo2.completionDate, DateTime(now.year, now.month, now.day));
      expect(todo2.creationDate, DateTime(now.year, now.month, now.day));
      expect(todo2.priority, null);
      expect(todo2.description, '');
    });
  });

  group("todo copyMerge()", () {
    test("do not overwrite attrs if not set in the diff", () {
      final DateTime now = DateTime.now();
      Todo todo = Todo(
        completion: false,
        priority: 'A',
        creationDate: now,
        description: 'Write some tests',
        projects: const {'project1'},
        contexts: const {'contexts1'},
        keyValues: const {'key1': 'value1'},
        selected: false,
      );
      final Todo diff = todo.copyDiff(completion: true);
      todo = todo.copyWith(
        priority: 'B',
        description: 'Write more tests',
        projects: const {'project2'},
        contexts: const {'context2'},
        keyValues: const {'key2': 'value2'},
        selected: true,
      );
      final Todo todo2 = diff.copyMerge(todo);
      expect(todo2.priority, 'B');
      expect(todo2.description, 'Write more tests');
      expect(todo2.projects, {'project2'});
      expect(todo2.contexts, {'context2'});
      expect(todo2.keyValues, {'key2': 'value2', 'id': todo.id});
      expect(todo2.selected, true);
      expect(todo2.completion, true);
      expect(todo2.completionDate, DateTime(now.year, now.month, now.day));
    });
  });

  group("todo fromString()", () {
    group("todo completion", () {
      group("completed", () {
        test("short todo (RangeError)", () {
          final Todo todo = Todo.fromString(value: "x 2022-11-16 Todo");
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(2022, 11, 16));
        });
        test("simple todo", () {
          final Todo todo =
              Todo.fromString(value: "x 2022-08-22 Write some tests");
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(2022, 08, 22));
        });

        test("full todo", () {
          final Todo todo = Todo.fromString(
              value:
                  "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31");
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(2022, 11, 16));
        });
      });
      group("incompleted", () {
        test("short todo (RangeError)", () {
          final Todo todo = Todo.fromString(value: "Todo");
          expect(todo.completion, false);
        });
        test("simple todo", () {
          final Todo todo = Todo.fromString(value: "Write some tests");
          expect(todo.completion, false);
        });
        test("missing whitespace", () {
          final Todo todo = Todo.fromString(value: "xWrite some tests");
          expect(todo.completion, false);
        });
        test("wrong mark", () {
          final Todo todo = Todo.fromString(value: "X Write some tests");
          expect(todo.completion, false);
        });
        test("wrong position", () {
          final Todo todo = Todo.fromString(value: "(A) x Write some tests");
          expect(todo.completion, false);
        });
      });
      group("edge cases", () {
        test("missing completion date", () {
          final DateTime now = DateTime.now();
          final Todo todo = Todo.fromString(value: "x Write some tests");
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(now.year, now.month, now.day));
        });
      });
    });

    group("todo priority", () {
      group("with priority", () {
        test("incompleted short todo (RangeError)", () {
          final todo = Todo.fromString(value: "(A) Todo");
          expect(todo.priority, "A");
        });
        test("incompleted simple todo (RangeError)", () {
          final todo = Todo.fromString(value: "(A) Write some tests");
          expect(todo.priority, "A");
        });
        test("incompleted full todo", () {
          final todo = Todo.fromString(
            value:
                "(A) 2022-11-16 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.priority, "A");
        });
        test("completed short todo (RangeError)", () {
          final todo = Todo.fromString(value: "x 2022-11-16 (A) Todo");
          expect(todo.priority, "A");
        });
        test("completed simple todo", () {
          final todo =
              Todo.fromString(value: "x 2022-11-16 (A) Write some tests");
          expect(todo.priority, "A");
        });
        test("completed full todo", () {
          final todo = Todo.fromString(
            value:
                "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.priority, "A");
        });
      });
      group("without priority", () {
        test("incompleted short todo (RangeError)", () {
          final todo = Todo.fromString(value: "Todo");
          expect(todo.priority, null);
        });
        test("incompleted simple todo", () {
          final todo = Todo.fromString(value: "Write some tests");
          expect(todo.priority, null);
        });
        test("incompleted full todo", () {
          final todo = Todo.fromString(
              value:
                  "2022-11-16 Write some tests +project @context due:2022-12-31");
          expect(todo.priority, null);
        });
        test("completed short todo (RangeError)", () {
          final todo = Todo.fromString(value: "x 2022-11-16 Todo");
          expect(todo.priority, null);
        });
        test("completed simple todo", () {
          final todo = Todo.fromString(value: "x 2022-11-16 Write some tests");
          expect(todo.priority, null);
        });
        test("completed full todo", () {
          final todo = Todo.fromString(
            value:
                "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.priority, null);
        });
        test("missing parenthesis", () {
          final todo = Todo.fromString(value: "A Write some tests");
          expect(todo.priority, null);
        });
        test("missing whitespace", () {
          final todo = Todo.fromString(value: "(A)Write some tests");
          expect(todo.priority, null);
        });
        test("wrong priority sign", () {
          final todo = Todo.fromString(value: "(a) Write some tests");
          expect(todo.priority, null);
        });
        test("wrong position", () {
          final todo = Todo.fromString(value: "Write some tests (A)");
          expect(todo.priority, null);
        });
      });
    });

    group("todo creation date", () {
      group("with creation date", () {
        test("incompleted simple todo", () {
          final todo = Todo.fromString(value: "2022-11-01 Write some tests");
          expect(todo.creationDate, DateTime.parse("2022-11-01"));
        });
        test("incompleted and with priority simple todo", () {
          final todo =
              Todo.fromString(value: "(A) 2022-11-01 Write some tests");
          expect(todo.creationDate, DateTime.parse("2022-11-01"));
        });
        test("incompleted full todo", () {
          final todo = Todo.fromString(
            value:
                "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.creationDate, DateTime.parse("2022-11-01"));
        });
        test("completed simple todo", () {
          final todo = Todo.fromString(
              value: "x 2022-11-16 2022-11-01 Write some tests");
          expect(todo.creationDate, DateTime.parse("2022-11-01"));
        });
        test("completed and with priority simple todo", () {
          final todo = Todo.fromString(
              value: "x 2022-11-16 (A) 2022-11-01 Write some tests");
          expect(todo.creationDate, DateTime.parse("2022-11-01"));
        });
        test("completed full todo", () {
          final todo = Todo.fromString(
            value:
                "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.creationDate, DateTime.parse("2022-11-01"));
        });
      });
    });

    group("todo completion date", () {
      group("with completion date", () {
        test("completed simple todo", () {
          final todo = Todo.fromString(value: "x 2022-11-16 Write some tests");
          expect(todo.completionDate, DateTime.parse("2022-11-16"));
        });
        test("completed and with priority simple todo", () {
          final todo =
              Todo.fromString(value: "x 2022-11-16 (A) Write some tests");
          expect(todo.completionDate, DateTime.parse("2022-11-16"));
        });
        test("completed full todo", () {
          final todo = Todo.fromString(
            value:
                "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.completionDate, DateTime.parse("2022-11-16"));
        });
      });
      group("without completion date", () {
        test("incompleted simple todo", () {
          final todo = Todo.fromString(value: "Write some tests");
          expect(todo.completionDate, null);
        });
        test("incompleted and with priority simple todo", () {
          final todo = Todo.fromString(value: "(A) Write some tests");
          expect(todo.completionDate, null);
        });
        test("incompleted full todo", () {
          final todo = Todo.fromString(
            value:
                "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.completionDate, null);
        });
      });
      group("edge cases", () {
        test(
            "incompleted with forbidden completiond date (is recognized as part of description)",
            () {
          final todo = Todo.fromString(
            value: "2022-11-16 2022-11-01 Write some tests",
          );
          expect(todo.completionDate, null);
          expect(todo.creationDate, DateTime.parse("2022-11-16"));
          expect(todo.description, "2022-11-01 Write some tests");
        });
        test(
            "incompleted with priority and forbidden completion date (is recognized as part of description)",
            () {
          final todo = Todo.fromString(
            value: "(A) 2022-11-16 2022-11-01 Write some tests",
          );
          expect(todo.priority, "A");
          expect(todo.completionDate, null);
          expect(todo.creationDate, DateTime.parse("2022-11-16"));
          expect(todo.description, "2022-11-01 Write some tests");
        });
        test("completed and missing completion date", () {
          final DateTime now = DateTime.now();
          final Todo todo = Todo.fromString(value: "x Write some tests");
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(now.year, now.month, now.day));
        });
        test("completed with priority and missing completion date", () {
          final DateTime now = DateTime.now();
          final Todo todo = Todo.fromString(value: "x (A) Write some tests");
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(now.year, now.month, now.day));
        });
      });
    });

    group("todo projects", () {
      test("no project tags", () {
        final todo = Todo.fromString(value: "Write some tests");
        expect(todo.projects, []);
      });
      test("single project tag", () {
        final todo = Todo.fromString(value: "Write some tests +ntodotxt");
        expect(todo.projects, ["ntodotxt"]);
      });
      test("multiple project tags", () {
        final todo = Todo.fromString(value: "Write some tests +ntodotxt +code");
        expect(todo.projects, ["ntodotxt", "code"]);
      });
      test("multiple project tags (not in sequence)", () {
        final todo = Todo.fromString(value: "Write some +tests for +ntodotxt");
        expect(todo.projects, ["tests", "ntodotxt"]);
      });
      test("project tag with a special name", () {
        final todo =
            Todo.fromString(value: "Write some tests +n-todo.txt+_123");
        expect(todo.projects, ["n-todo.txt+_123"]);
      });
      test("project tag with a name in capital letters", () {
        final todo = Todo.fromString(value: "Write some tests +NTodoTXT");
        expect(todo.projects, ["ntodotxt"]);
      });
      test("project tag with project duplication", () {
        final todo =
            Todo.fromString(value: "Write some tests +ntodotxt +ntodotxt");
        expect(todo.projects, ["ntodotxt"]);
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          value: "2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.projects, ["project"]);
      });
      test("incompleted with priority full todo", () {
        final todo = Todo.fromString(
          value:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.projects, ["project"]);
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          value:
              "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.projects, ["project"]);
      });
      test("completed with priority full todo", () {
        final todo = Todo.fromString(
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.projects, ["project"]);
      });
    });

    group("todo contexts", () {
      test("no context tag", () {
        final todo = Todo.fromString(value: "Write some tests");
        expect(todo.contexts, []);
      });
      test("single context tag", () {
        final todo = Todo.fromString(value: "Write some @tests");
        expect(todo.contexts, ["tests"]);
      });
      test("multiple context tags", () {
        final todo = Todo.fromString(value: "Write some @tests @dx");
        expect(todo.contexts, ["tests", "dx"]);
      });
      test("multiple context tags (not in sequence)", () {
        final todo = Todo.fromString(value: "Write some @tests for @ntodotxt");
        expect(todo.contexts, ["tests", "ntodotxt"]);
      });
      test("context tag with a special name", () {
        final todo =
            Todo.fromString(value: "Write some tests for @n-todo.txt+_123");
        expect(todo.contexts, ["n-todo.txt+_123"]);
      });
      test("context tag with a name in capital letters", () {
        final todo = Todo.fromString(value: "Write some tests @NTodoTXT");
        expect(todo.contexts, ["ntodotxt"]);
      });
      test("context tag with context duplication", () {
        final todo =
            Todo.fromString(value: "Write some tests @ntodotxt @ntodotxt");
        expect(todo.contexts, ["ntodotxt"]);
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          value: "2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.contexts, ["context"]);
      });
      test("incompleted with priority full todo", () {
        final todo = Todo.fromString(
          value:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.contexts, ["context"]);
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          value:
              "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.contexts, ["context"]);
      });
      test("completed with priority full todo", () {
        final todo = Todo.fromString(
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.contexts, ["context"]);
      });
    });

    group("todo key values", () {
      test("no key value tag", () {
        final todo = Todo.fromString(value: "Write some tests");
        expect(todo.keyValues, {"id": todo.id});
      });
      test("single key value tag", () {
        final todo = Todo.fromString(value: "Write some tests key:value");
        expect(todo.keyValues, {"key": "value", "id": todo.id});
      });
      test("multiple key value tags", () {
        final todo =
            Todo.fromString(value: "Write some tests key1:value1 key2:value2");
        expect(todo.keyValues,
            {"key1": "value1", "key2": "value2", "id": todo.id});
      });
      test("multiple key value tags (not in sequence)", () {
        final todo =
            Todo.fromString(value: "Write some key1:value1 tests key2:value2");
        expect(todo.keyValues,
            {"key1": "value1", "key2": "value2", "id": todo.id});
      });
      test("key value tag with a special name", () {
        final todo =
            Todo.fromString(value: "Write some tests key-@_123:value_@123");
        expect(todo.keyValues, {"key-@_123": "value_@123", "id": todo.id});
      });
      test("key value tag with a name in capital letters", () {
        final todo = Todo.fromString(value: "Write some tests Key:Value");
        expect(todo.keyValues, {"key": "value", "id": todo.id});
      });
      test("key value tag with key value duplication", () {
        final todo =
            Todo.fromString(value: "Write some tests key:value key:value");
        expect(todo.keyValues, {"key": "value", "id": todo.id});
      });
      test("invalid key value tag", () {
        final todo =
            Todo.fromString(value: "Write some tests key1:value1:invalid");
        expect(todo.keyValues, {"id": todo.id});
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          value: "2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.keyValues, {"due": "2022-12-31", "id": todo.id});
      });
      test("incompleted with priority full todo", () {
        final todo = Todo.fromString(
          value:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.keyValues, {"due": "2022-12-31", "id": todo.id});
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          value:
              "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.keyValues, {"due": "2022-12-31", "id": todo.id});
      });
      test("completed with priority full todo", () {
        final todo = Todo.fromString(
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.keyValues, {"due": "2022-12-31", "id": todo.id});
      });
    });

    group("todo description", () {
      group("with description", () {
        test("incompleted with description", () {
          final todo = Todo.fromString(value: "Write some tests");
          expect(todo.description, "Write some tests");
        });
        test("incompleted with description and priority", () {
          final todo = Todo.fromString(value: "(A) Write some tests");
          expect(todo.description, "Write some tests");
        });
        test("incompleted full todo", () {
          final todo = Todo.fromString(
            value:
                "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.description, "Write some tests");
        });
        test("completed with description", () {
          final todo = Todo.fromString(value: "x 2022-11-16 Write some tests");
          expect(todo.description, "Write some tests");
        });
        test("completed with description and priority", () {
          final todo = Todo.fromString(
            value: "x 2022-11-16 (A) Write some tests",
          );
          expect(todo.description, "Write some tests");
        });
        test("completed full todo", () {
          final todo = Todo.fromString(
            value:
                "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
          );
          expect(todo.description, "Write some tests");
        });
      });

      group("edge cases", () {
        test("completed with projects", () {
          expect(
            () => Todo.fromString(value: "x 2022-11-16 +project1 +project2"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("completed with contexts", () {
          expect(
            () => Todo.fromString(value: "x 2022-11-16 @context1 @context2"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("completed with key-values", () {
          expect(
            () => Todo.fromString(value: "x 2022-11-16 key1:val1 key2:val2"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("completed with all kind of tags", () {
          expect(
            () => Todo.fromString(
                value: "x 2022-11-16 +project @context key:val"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("completed", () {
          expect(
            () => Todo.fromString(value: "x 2022-11-16"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("completed with priority", () {
          expect(
            () => Todo.fromString(value: "x 2022-11-16 (A)"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("completed with priority and creation date", () {
          expect(
            () => Todo.fromString(value: "x 2022-11-16 (A) 2022-11-01"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted with projects", () {
          expect(
            () => Todo.fromString(value: "+project1 +project2"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted with contexts", () {
          expect(
            () => Todo.fromString(value: "@context1 @context2"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted with key-values", () {
          expect(
            () => Todo.fromString(value: "key1:val1 key2:val2"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted with all kind of tags", () {
          expect(
            () => Todo.fromString(value: "+project @context key:val"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted", () {
          expect(
            () => Todo.fromString(value: ""),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted with priority", () {
          expect(
            () => Todo.fromString(value: "(A)"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
        test("incompleted with priority and creation date", () {
          expect(
            () => Todo.fromString(value: "(A) 2022-11-01"),
            throwsA(
              isA<TodoStringMalformed>(),
            ),
          );
        });
      });
    });
  });

  group("todo dueDate", () {
    test("unset", () {
      final todo = Todo.fromString(
        value: "2022-11-01 Write some tests",
      );
      expect(todo.dueDate, null);
    });
    test("set", () {
      final todo = Todo.fromString(
        value: "2022-11-01 Write some tests due:2023-12-31",
      );
      expect(todo.dueDate, DateTime(2023, 12, 31));
    });
    test("set but invalid", () {
      final todo = Todo.fromString(
        value: "2022-11-01 Write some tests due:yyyy-mm-dd",
      );
      expect(todo.dueDate, null);
    });
  });

  group("todo toString()", () {
    test("full todo", () {
      const String value =
          "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31";
      final todo = Todo.fromString(
        value: value,
      );
      expect(todo.toString(), '$value id:${todo.id}');
    });
    test("full todo with multiple whitespace", () {
      final todo = Todo.fromString(
        value:
            "x  2022-11-16  (A)  2022-11-01  Write some tests +project @context due:2022-12-31",
      );
      expect(todo.toString(),
          "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31 id:${todo.id}");
    });
  });
}
