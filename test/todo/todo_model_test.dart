import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

void main() {
  late int id;
  setUp(() {
    id = 0;
  });

  group("todo completion", () {
    group("completed", () {
      test("short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 Todo",
        );
        expect(todo.completion, true);
      });
      test("simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-08-22 Write some tests",
        );
        expect(todo.completion, true);
      });

      test("full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.completion, true);
      });
    });
    group("incompleted", () {
      test("short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "Todo",
        );
        expect(todo.completion, false);
      });
      test("simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "Write some tests",
        );
        expect(todo.completion, false);
      });
      test("missing whitespace", () {
        final todo = Todo.fromString(
          id: id,
          value: "xWrite some tests",
        );
        expect(todo.completion, false);
      });
      test("wrong mark", () {
        final todo = Todo.fromString(
          id: id,
          value: "X Write some tests",
        );
        expect(todo.completion, false);
      });
      test("wrong position", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) x Write some tests",
        );
        expect(todo.completion, false);
      });
    });
    group("exception", () {
      test("missing completion date", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "x Write some tests",
          ),
          throwsA(
            isA<TodoMissingCompletionDate>(),
          ),
        );
      });
    });
  });

  group("todo priority", () {
    group("with priority", () {
      test("incompleted short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Todo",
        );
        expect(todo.priority, "A");
      });
      test("incompleted simple todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Write some tests",
        );
        expect(todo.priority, "A");
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "(A) 2022-11-16 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, "A");
      });
      test("completed short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 (A) Todo",
        );
        expect(todo.priority, "A");
      });
      test("completed simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 (A) Write some tests",
        );
        expect(todo.priority, "A");
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, "A");
      });
    });
    group("without priority", () {
      test("incompleted short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "Todo",
        );
        expect(todo.priority, null);
      });
      test("incompleted simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "Write some tests",
        );
        expect(todo.priority, null);
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "2022-11-16 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, null);
      });
      test("completed short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 Todo",
        );
        expect(todo.priority, null);
      });
      test("completed simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 Write some tests",
        );
        expect(todo.priority, null);
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, null);
      });
      test("missing parenthesis", () {
        final todo = Todo.fromString(
          id: id,
          value: "A Write some tests",
        );
        expect(todo.priority, null);
      });
      test("missing whitespace", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A)Write some tests",
        );
        expect(todo.priority, null);
      });
      test("wrong priority sign", () {
        final todo = Todo.fromString(
          id: id,
          value: "(a) Write some tests",
        );
        expect(todo.priority, null);
      });
      test("wrong position", () {
        final todo = Todo.fromString(
          id: id,
          value: "Write some tests (A)",
        );
        expect(todo.priority, null);
      });
    });
  });

  group("todo creation date", () {
    group("with creation date", () {
      test("incompleted simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("incompleted and with priority simple todo", () {
        final todo = Todo.fromString(
          id: 0,
          value: "(A) 2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          id: 0,
          value:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("completed simple todo", () {
        final todo = Todo.fromString(
          id: 0,
          value: "x 2022-11-16 2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("completed and with priority simple todo", () {
        final todo = Todo.fromString(
          id: 0,
          value: "x 2022-11-16 (A) 2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          id: 0,
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
    });
    group("without creation date", () {
      test("incompleted simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("incompleted and with priority simple short todo (RangeError)", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Todo",
        );
        expect(todo.creationDate, null);
      });
      test("incompleted and with priority simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, null);
      });
      test("completed simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("completed and with priority simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 (A) Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "x 2022-11-16 (A) Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, null);
      });
    });
  });

  group("todo completion date", () {
    group("with completion date", () {
      test("completed simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 Write some tests",
        );
        expect(todo.completionDate, DateTime.parse("2022-11-16"));
      });
      test("completed and with priority simple todo", () {
        final todo = Todo.fromString(
          id: 0,
          value: "x 2022-11-16 (A) Write some tests",
        );
        expect(todo.completionDate, DateTime.parse("2022-11-16"));
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          id: 0,
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.completionDate, DateTime.parse("2022-11-16"));
      });
    });
    group("without completion date", () {
      test("incompleted simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "Write some tests",
        );
        expect(todo.completionDate, null);
      });
      test("incompleted and with priority simple todo", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Write some tests",
        );
        expect(todo.completionDate, null);
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.completionDate, null);
      });
    });
    group("exception / edge cases", () {
      test(
          "incompleted with forbidden completiond date (is recognized as part of description)",
          () {
        final todo = Todo.fromString(
          id: id,
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
          id: id,
          value: "(A) 2022-11-16 2022-11-01 Write some tests",
        );
        expect(todo.priority, "A");
        expect(todo.completionDate, null);
        expect(todo.creationDate, DateTime.parse("2022-11-16"));
        expect(todo.description, "2022-11-01 Write some tests");
      });
      test("completed and missing completion date", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "x Write some tests",
          ),
          throwsA(
            isA<TodoMissingCompletionDate>(),
          ),
        );
      });
      test("completed with priority and missing completion date", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "x (A) Write some tests",
          ),
          throwsA(
            isA<TodoMissingCompletionDate>(),
          ),
        );
      });
    });
  });

  group("todo projects", () {
    test("no project tags", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests",
      );
      expect(todo.projects, []);
    });
    test("single project tag", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests +ntodotxt",
      );
      expect(todo.projects, ["ntodotxt"]);
    });
    test("multiple project tags", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests +ntodotxt +code",
      );
      expect(todo.projects, ["ntodotxt", "code"]);
    });
    test("multiple project tags (not in sequence)", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some +tests for +ntodotxt",
      );
      expect(todo.projects, ["tests", "ntodotxt"]);
    });
    test("project tag with a special name", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests +n-todo.txt+_123",
      );
      expect(todo.projects, ["n-todo.txt+_123"]);
    });
    test("project tag with a name in capital letters", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests +NTodoTXT",
      );
      expect(todo.projects, ["ntodotxt"]);
    });
    test("project tag with project duplication", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests +ntodotxt +ntodotxt",
      );
      expect(todo.projects, ["ntodotxt"]);
    });
    test("incompleted full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value: "2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
    test("incompleted with priority full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
    test("completed full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
    test("completed with priority full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
  });

  group("todo contexts", () {
    test("no context tag", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests",
      );
      expect(todo.contexts, []);
    });
    test("single context tag", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some @tests",
      );
      expect(todo.contexts, ["tests"]);
    });
    test("multiple context tags", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some @tests @dx",
      );
      expect(todo.contexts, ["tests", "dx"]);
    });
    test("multiple context tags (not in sequence)", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some @tests for @ntodotxt",
      );
      expect(todo.contexts, ["tests", "ntodotxt"]);
    });
    test("context tag with a special name", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests for @n-todo.txt+_123",
      );
      expect(todo.contexts, ["n-todo.txt+_123"]);
    });
    test("context tag with a name in capital letters", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests @NTodoTXT",
      );
      expect(todo.contexts, ["ntodotxt"]);
    });
    test("context tag with context duplication", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests @ntodotxt @ntodotxt",
      );
      expect(todo.contexts, ["ntodotxt"]);
    });
    test("incompleted full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value: "2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
    test("incompleted with priority full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
    test("completed full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
    test("completed with priority full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
  });

  group("todo key values", () {
    test("no key value tag", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests",
      );
      expect(todo.keyValues, {});
    });
    test("single key value tag", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests key:value",
      );
      expect(todo.keyValues, {"key": "value"});
    });
    test("multiple key value tags", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests key1:value1 key2:value2",
      );
      expect(todo.keyValues, {"key1": "value1", "key2": "value2"});
    });
    test("multiple key value tags (not in sequence)", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some key1:value1 tests key2:value2",
      );
      expect(todo.keyValues, {"key1": "value1", "key2": "value2"});
    });
    test("key value tag with a special name", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests key-@_123:value_@123",
      );
      expect(todo.keyValues, {"key-@_123": "value_@123"});
    });
    test("key value tag with a name in capital letters", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests Key:Value",
      );
      expect(todo.keyValues, {"key": "value"});
    });
    test("key value tag with key value duplication", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests key:value key:value",
      );
      expect(todo.keyValues, {"key": "value"});
    });
    test("invalid key value tag", () {
      final todo = Todo.fromString(
        id: id,
        value: "Write some tests key1:value1:invalid",
      );
      expect(todo.keyValues, {});
    });
    test("incompleted full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value: "2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
    test("incompleted with priority full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
    test("completed full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
    test("completed with priority full todo", () {
      final todo = Todo.fromString(
        id: 0,
        value:
            "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
  });

  group("todo description", () {
    group("with description", () {
      test("incompleted with description", () {
        final todo = Todo.fromString(
          id: id,
          value: "Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("incompleted with description and priority", () {
        final todo = Todo.fromString(
          id: id,
          value: "(A) Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("incompleted full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.description, "Write some tests");
      });
      test("completed with description", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("completed with description and priority", () {
        final todo = Todo.fromString(
          id: id,
          value: "x 2022-11-16 (A) Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("completed full todo", () {
        final todo = Todo.fromString(
          id: id,
          value:
              "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.description, "Write some tests");
      });
    });

    group("exception", () {
      test("completed", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "x 2022-11-16",
          ),
          throwsA(
            isA<TodoStringMalformed>(),
          ),
        );
      });
      test("completed with priority", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "x 2022-11-16 (A)",
          ),
          throwsA(
            isA<TodoStringMalformed>(),
          ),
        );
      });
      test("completed with priority and creation date", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "x 2022-11-16 (A) 2022-11-01",
          ),
          throwsA(
            isA<TodoStringMalformed>(),
          ),
        );
      });
      test("incompleted", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "",
          ),
          throwsA(
            isA<TodoStringMalformed>(),
          ),
        );
      });
      test("incompleted wiht priority", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "(A)",
          ),
          throwsA(
            isA<TodoStringMalformed>(),
          ),
        );
      });
      test("incompleted wiht priority and creation date", () {
        expect(
          () => Todo.fromString(
            id: id,
            value: "(A) 2022-11-01",
          ),
          throwsA(
            isA<TodoStringMalformed>(),
          ),
        );
      });
    });
  });

  group("todo toString", () {
    test("full todo", () {
      const String value =
          "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31";
      final todo = Todo.fromString(
        id: id,
        value: value,
      );
      expect(todo.toString(), value);
    });
    test("full todo with multiple whitespace", () {
      final todo = Todo.fromString(
        id: id,
        value:
            "x  2022-11-16  (A)  2022-11-01  Write some tests +project @context due:2022-12-31",
      );
      expect(todo.toString(),
          "x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31");
    });
  });
}
