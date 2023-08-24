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
      test("simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x 2022-08-22 Write some tests",
        );
        expect(todo.completion, true);
      });
      test("full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.completion, true);
      });
    });
    group("incompleted", () {
      test("missing mark", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "Write some tests",
        );
        expect(todo.completion, false);
      });
      test("missing whitespace", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "xWrite some tests",
        );
        expect(todo.completion, false);
      });
      test("wrong mark", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "X Write some tests",
        );
        expect(todo.completion, false);
      });
      test("wrong position", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A) x Write some tests",
        );
        expect(todo.completion, false);
      });
    });
    group("exception", () {
      test("missing completion date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "x Write some tests",
          ),
          throwsA(
            isA<MissingTodoCompletionDate>(),
          ),
        );
      });
    });
  });

  group("todo priority", () {
    group("with priority", () {
      test("incompleted simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A) Write some tests",
        );
        expect(todo.priority, "A");
      });
      test("incompleted full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "(A) 2022-11-16 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, "A");
      });
      test("completed simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x (A) 2022-11-16 Write some tests",
        );
        expect(todo.priority, "A");
      });
      test("completed full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, "A");
      });
    });
    group("without priority", () {
      test("incompleted simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "Write some tests",
        );
        expect(todo.priority, null);
      });
      test("incompleted full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "2022-11-16 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, null);
      });
      test("completed simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x 2022-11-16 Write some tests",
        );
        expect(todo.priority, null);
      });
      test("completed full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.priority, null);
      });
      test("missing parenthesis", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "A Write some tests",
        );
        expect(todo.priority, null);
      });
      test("missing whitespace", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A)Write some tests",
        );
        expect(todo.priority, null);
      });
      test("wrong priority sign", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(a) Write some tests",
        );
        expect(todo.priority, null);
      });
      test("wrong position", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "Write some tests (A)",
        );
        expect(todo.priority, null);
      });
    });
  });

  group("todo creation date", () {
    group("with creation date", () {
      test("incompleted simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("incompleted and with priority simple example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr: "(A) 2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("incompleted full example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("completed simple example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr: "x 2022-11-16 2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("completed and with priority simple example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr: "x (A) 2022-11-16 2022-11-01 Write some tests",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
      test("completed full example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr:
              "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, DateTime.parse("2022-11-01"));
      });
    });
    group("without creation date", () {
      test("incompleted simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("incompleted and with priority simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A) Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("incompleted full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A) Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, null);
      });
      test("completed simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x 2022-11-16 Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("completed and with priority simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x (A) 2022-11-16 Write some tests",
        );
        expect(todo.creationDate, null);
      });
      test("completed full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "x (A) 2022-11-16 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.creationDate, null);
      });
    });
  });

  group("todo completion date", () {
    group("with completion date", () {
      test("completed simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x 2022-11-16 Write some tests",
        );
        expect(todo.completionDate, DateTime.parse("2022-11-16"));
      });
      test("completed and with priority simple example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr: "x (A) 2022-11-16 Write some tests",
        );
        expect(todo.completionDate, DateTime.parse("2022-11-16"));
      });
      test("completed full example", () {
        final todo = Todo.fromString(
          id: 0,
          todoStr:
              "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.completionDate, DateTime.parse("2022-11-16"));
      });
    });
    group("without completion date", () {
      test("incompleted simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "Write some tests",
        );
        expect(todo.completionDate, null);
      });
      test("incompleted and with priority simple example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A) Write some tests",
        );
        expect(todo.completionDate, null);
      });
      test("incompleted full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.completionDate, null);
      });
    });
    group("exception", () {
      test("incompleted with forbidden completiond date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "2022-11-16 2022-11-01 Write some tests",
          ),
          throwsA(
            isA<ForbiddenTodoCompletionDate>(),
          ),
        );
      });
      test("incompleted with priority and forbidden completiond date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "(A) 2022-11-16 2022-11-01 Write some tests",
          ),
          throwsA(
            isA<ForbiddenTodoCompletionDate>(),
          ),
        );
      });
      test("completed and missing completion date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "x Write some tests",
          ),
          throwsA(
            isA<MissingTodoCompletionDate>(),
          ),
        );
      });
      test("completed with priority and missing completion date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "x (A) Write some tests",
          ),
          throwsA(
            isA<MissingTodoCompletionDate>(),
          ),
        );
      });
    });
  });

  group("todo projects", () {
    test("no project tags", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests",
      );
      expect(todo.projects, []);
    });
    test("single project tag", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests +ntodotxt",
      );
      expect(todo.projects, ["ntodotxt"]);
    });
    test("multiple project tags", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests +ntodotxt +code",
      );
      expect(todo.projects, ["ntodotxt", "code"]);
    });
    test("multiple project tags (not in sequence)", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some +tests for +ntodotxt",
      );
      expect(todo.projects, ["tests", "ntodotxt"]);
    });
    test("project tag with a special name", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests +n-todo.txt+_123",
      );
      expect(todo.projects, ["n-todo.txt+_123"]);
    });
    test("incompleted full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr: "2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
    test("incompleted with priority full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
    test("completed full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
    test("completed with priority full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.projects, ["project"]);
    });
  });

  group("todo contexts", () {
    test("no context tag", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests",
      );
      expect(todo.contexts, []);
    });
    test("single context tag", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some @tests",
      );
      expect(todo.contexts, ["tests"]);
    });
    test("multiple context tags", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some @tests @dx",
      );
      expect(todo.contexts, ["tests", "dx"]);
    });
    test("multiple context tags (not in sequence)", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some @tests for @ntodotxt",
      );
      expect(todo.contexts, ["tests", "ntodotxt"]);
    });
    test("context tag with a special name", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests for @n-todo.txt+_123",
      );
      expect(todo.contexts, ["n-todo.txt+_123"]);
    });
    test("incompleted full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr: "2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
    test("incompleted with priority full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
    test("completed full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
    test("completed with priority full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.contexts, ["context"]);
    });
  });

  group("todo key values", () {
    test("no key value tag", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests",
      );
      expect(todo.keyValues, {});
    });
    test("single key value tag", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests key:value",
      );
      expect(todo.keyValues, {"key": "value"});
    });
    test("multiple key value tags", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests key1:value1 key2:value2",
      );
      expect(todo.keyValues, {"key1": "value1", "key2": "value2"});
    });
    test("multiple key value tags (not in sequence)", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some key1:value1 tests key2:value2",
      );
      expect(todo.keyValues, {"key1": "value1", "key2": "value2"});
    });
    test("key value tag with a special name", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests key-@_123:value_@123",
      );
      expect(todo.keyValues, {"key-@_123": "value_@123"});
    });
    test("invalid key value tag", () {
      final todo = Todo.fromString(
        id: id,
        todoStr: "Write some tests key1:value1:invalid",
      );
      expect(todo.keyValues, {});
    });
    test("incompleted full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr: "2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
    test("incompleted with priority full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
    test("completed full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
    test("completed with priority full example", () {
      final todo = Todo.fromString(
        id: 0,
        todoStr:
            "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
      );
      expect(todo.keyValues, {"due": "2022-12-31"});
    });
  });

  group("todo description", () {
    group("with description", () {
      test("incompleted with description", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("incompleted with description and priority", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "(A) Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("incompleted full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "(A) 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.description,
            "Write some tests +project @context due:2022-12-31");
      });
      test("completed with description", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x 2022-11-16 Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("completed with description and priority", () {
        final todo = Todo.fromString(
          id: id,
          todoStr: "x (A) 2022-11-16 Write some tests",
        );
        expect(todo.description, "Write some tests");
      });
      test("completed full example", () {
        final todo = Todo.fromString(
          id: id,
          todoStr:
              "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31",
        );
        expect(todo.description,
            "Write some tests +project @context due:2022-12-31");
      });
    });

    group("exception", () {
      test("completed", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "x 2022-11-16",
          ),
          throwsA(
            isA<InvalidTodoString>(),
          ),
        );
      });
      test("completed with priority", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "x (A) 2022-11-16",
          ),
          throwsA(
            isA<InvalidTodoString>(),
          ),
        );
      });
      test("completed with priority and creation date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "x (A) 2022-11-16 2022-11-01",
          ),
          throwsA(
            isA<InvalidTodoString>(),
          ),
        );
      });
      test("incompleted", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "",
          ),
          throwsA(
            isA<InvalidTodoString>(),
          ),
        );
      });
      test("incompleted wiht priority", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "(A)",
          ),
          throwsA(
            isA<InvalidTodoString>(),
          ),
        );
      });
      test("incompleted wiht priority and creation date", () {
        expect(
          () => Todo.fromString(
            id: id,
            todoStr: "(A) 2022-11-01",
          ),
          throwsA(
            isA<InvalidTodoString>(),
          ),
        );
      });
    });
  });

  group("todo toString", () {
    test("full example", () {
      const String todoStr =
          "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31";
      final todo = Todo.fromString(
        id: id,
        todoStr: todoStr,
      );
      expect(todo.toString(), todoStr);
    });
    test("full example with multiple whitespace", () {
      final todo = Todo.fromString(
        id: id,
        todoStr:
            "x  (A)  2022-11-16  2022-11-01  Write some tests +project @context due:2022-12-31",
      );
      expect(todo.toString(),
          "x (A) 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31");
    });
  });
}
