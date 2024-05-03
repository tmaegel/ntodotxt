import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

void main() {
  setUp(() {});

  group('todo Todo()', () {
    group('completion & completionDate', () {
      test('initial incompleted', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.completion, false);
        expect(todo.completionDate, null);
      });
      test('initial completed', () {
        final DateTime now = DateTime.now();
        final Todo todo = Todo(
          completion: true,
          description: 'Write some tests',
        );
        expect(todo.completion, true);
        expect(todo.completionDate, DateTime(now.year, now.month, now.day));
      });
      test('initial completed & completionDate', () {
        final Todo todo = Todo(
          completion: true,
          completionDate: DateTime(1970, 1, 1),
          description: 'Write some tests',
        );
        expect(todo.completion, true);
        expect(todo.completionDate, DateTime(1970, 1, 1));
      });
    });

    group('priority', () {
      test('no initial priority', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.priority, Priority.none);
      });
      test('with initial priority', () {
        final Todo todo = Todo(
          priority: Priority.A,
          description: 'Write some tests',
        );
        expect(todo.priority, Priority.A);
      });
    });

    group('creationDate', () {
      test('no initial creationDate', () {
        final DateTime now = DateTime.now();
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.creationDate, DateTime(now.year, now.month, now.day));
      });
      test('with initial creationDate', () {
        final DateTime now = DateTime.now();
        final Todo todo = Todo(
          creationDate: now,
          description: 'Write some tests',
        );
        expect(todo.creationDate, DateTime(now.year, now.month, now.day));
      });
    });

    group('description', () {
      test('no initial description', () {
        final Todo todo = Todo();
        expect(todo.description, '');
      });
      test('with initial description', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.description, 'Write some tests');
      });
    });

    group('projects', () {
      test('no initial projects', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.projects, []);
      });
      test('with initial projects', () {
        final Todo todo = Todo(
          description: 'Write some tests +project1',
        );
        expect(todo.projects, {'project1'});
      });
    });

    group('contexts', () {
      test('no initial contexts', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.contexts, []);
      });
      test('with initial contexts', () {
        final Todo todo = Todo(
          description: 'Write some tests @context1',
        );
        expect(todo.contexts, {'context1'});
      });
    });

    group('keyValues', () {
      test('no initial keyValues', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        expect(todo.keyValues, []);
      });
      test('with initial keyValues', () {
        final Todo todo = Todo(
          description: 'Write some tests key:value',
        );
        expect(todo.keyValues, {'key:value'});
      });
    });
  });

  group('todo copyWith()', () {
    group('completion & completionDate', () {
      test('set completion', () {
        final DateTime now = DateTime.now();
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(completion: true);
        expect(todo2.completion, true);
        expect(todo2.completionDate, DateTime(now.year, now.month, now.day));
      });
      test('set completion & completionDate', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(
            completion: true, completionDate: DateTime(1970, 1, 1));
        expect(todo2.completion, true);
        expect(todo2.completionDate, DateTime(1970, 1, 1));
      });
      test('unset completion', () {
        final Todo todo = Todo(
          completion: true,
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(completion: false);
        expect(todo2.completion, false);
        expect(todo2.completionDate, null);
      });
    });

    group('priority', () {
      test('set priority', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(priority: Priority.A);
        expect(todo2.priority, Priority.A);
      });
      test('unset priority', () {
        final Todo todo = Todo(
          priority: Priority.A,
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(priority: Priority.none);
        expect(todo2.priority, Priority.none);
      });
    });

    group('creationDate', () {});

    group('description', () {
      test('set description', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(description: 'Write more tests');
        expect(todo2.description, 'Write more tests');
      });
      test('unset description', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(description: '');
        expect(todo2.description, '');
      });
    });

    group('projects', () {
      test('set projects', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(description: 'Write some tests +project2');
        expect(todo2.projects, {'project2'});
      });
      test('unset projects', () {
        final Todo todo = Todo(
          description: 'Write some tests +project2',
        );
        final todo2 = todo.copyWith(description: 'Write some tests');
        expect(todo2.projects, []);
      });
    });

    group('contexts', () {
      test('set contexts', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(description: 'Write some tests @context2');
        expect(todo2.contexts, {'context2'});
      });
      test('unset contexts', () {
        final Todo todo = Todo(
          description: 'Write some tests @context2',
        );
        final todo2 = todo.copyWith(description: 'Write some tests');
        expect(todo2.contexts, []);
      });
    });

    group('keyValues', () {
      test('set keyValues', () {
        final Todo todo = Todo(
          description: 'Write some tests',
        );
        final todo2 = todo.copyWith(description: 'Write some tests key:value');
        expect(todo2.keyValues, {'key:value'});
      });
      test('unset keyValues', () {
        final Todo todo = Todo(
          description: 'Write some tests key:value',
        );
        final todo2 = todo.copyWith(description: 'Write some tests');
        expect(todo2.keyValues, []);
      });
    });
  });

  group('todo copyDiff()', () {
    test('copy explizit set attributes but keep creationDate if set', () {
      final DateTime now = DateTime.now();
      final Todo todo = Todo(
        priority: Priority.A,
        description: 'Write some tests',
      );
      final Todo todo2 = todo.copyDiff(completion: true);
      expect(todo2.completion, true);
      expect(todo2.completionDate, DateTime(now.year, now.month, now.day));
      expect(todo2.creationDate, DateTime(now.year, now.month, now.day));
      expect(todo2.priority, Priority.none);
      expect(todo2.description, '');
    });
  });

  group('todo copyMerge()', () {
    test('do not overwrite attrs if not set in the diff', () {
      final DateTime now = DateTime.now();
      Todo todo = Todo(
        completion: false,
        priority: Priority.A,
        creationDate: now,
        description: 'Write some tests +project1 @context1 key:value',
      );
      final Todo diff = todo.copyDiff(completion: true);
      todo = todo.copyWith(
        priority: Priority.B,
        description: 'Write more tests +project1 @context1 key:value',
      );
      final Todo todo2 = diff.copyMerge(todo);
      expect(todo2.priority, Priority.B);
      expect(
          todo2.description, 'Write more tests +project1 @context1 key:value');
      expect(todo2.projects, {'project1'});
      expect(todo2.contexts, {'context1'});
      expect(todo2.keyValues, {'key:value'});
      expect(todo2.completion, true);
      expect(todo2.completionDate, DateTime(now.year, now.month, now.day));
    });
  });

  group('todo fromString()', () {
    group('todo completion', () {
      group('completed', () {
        test('short todo (RangeError)', () {
          final Todo todo = Todo.fromString(value: 'x 2022-11-16 Todo');
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(2022, 11, 16));
        });
        test('simple todo', () {
          final Todo todo =
              Todo.fromString(value: 'x 2022-08-22 Write some tests');
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(2022, 08, 22));
        });

        test('full todo', () {
          final Todo todo = Todo.fromString(
              value:
                  'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31');
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(2022, 11, 16));
        });
      });
      group('incompleted', () {
        test('short todo (RangeError)', () {
          final Todo todo = Todo.fromString(value: 'Todo');
          expect(todo.completion, false);
        });
        test('simple todo', () {
          final Todo todo = Todo.fromString(value: 'Write some tests');
          expect(todo.completion, false);
        });
        test('missing whitespace', () {
          final Todo todo = Todo.fromString(value: 'xWrite some tests');
          expect(todo.completion, false);
        });
        test('wrong mark', () {
          final Todo todo = Todo.fromString(value: 'X Write some tests');
          expect(todo.completion, false);
        });
        test('wrong position', () {
          final Todo todo = Todo.fromString(value: '(A) x Write some tests');
          expect(todo.completion, false);
        });
      });
      group('edge cases', () {
        test('missing completion date', () {
          final DateTime now = DateTime.now();
          final Todo todo = Todo.fromString(value: 'x Write some tests');
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(now.year, now.month, now.day));
        });
      });
    });

    group('todo priority', () {
      group('with priority', () {
        test('incompleted short todo (RangeError)', () {
          final todo = Todo.fromString(value: '(A) Todo');
          expect(todo.priority, Priority.A);
        });
        test('incompleted simple todo (RangeError)', () {
          final todo = Todo.fromString(value: '(A) Write some tests');
          expect(todo.priority, Priority.A);
        });
        test('incompleted full todo', () {
          final todo = Todo.fromString(
            value:
                '(A) 2022-11-16 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.priority, Priority.A);
        });
        test('incompleted todo with very low priority', () {
          final todo = Todo.fromString(value: '(Z) Todo');
          expect(todo.priority, Priority.Z);
        });
        test('completed short todo (RangeError)', () {
          final todo = Todo.fromString(value: 'x 2022-11-16 (A) Todo');
          expect(todo.priority, Priority.A);
        });
        test('completed simple todo', () {
          final todo =
              Todo.fromString(value: 'x 2022-11-16 (A) Write some tests');
          expect(todo.priority, Priority.A);
        });
        test('completed full todo', () {
          final todo = Todo.fromString(
            value:
                'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.priority, Priority.A);
        });
        test('completed todo with very low priority', () {
          final todo = Todo.fromString(value: 'x 2022-11-16 (Z) Todo');
          expect(todo.priority, Priority.Z);
        });
      });
      group('without priority', () {
        test('incompleted short todo (RangeError)', () {
          final todo = Todo.fromString(value: 'Todo');
          expect(todo.priority, Priority.none);
        });
        test('incompleted simple todo', () {
          final todo = Todo.fromString(value: 'Write some tests');
          expect(todo.priority, Priority.none);
        });
        test('incompleted full todo', () {
          final todo = Todo.fromString(
              value:
                  '2022-11-16 Write some tests +project @context due:2022-12-31');
          expect(todo.priority, Priority.none);
        });
        test('completed short todo (RangeError)', () {
          final todo = Todo.fromString(value: 'x 2022-11-16 Todo');
          expect(todo.priority, Priority.none);
        });
        test('completed simple todo', () {
          final todo = Todo.fromString(value: 'x 2022-11-16 Write some tests');
          expect(todo.priority, Priority.none);
        });
        test('completed full todo', () {
          final todo = Todo.fromString(
            value:
                'x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.priority, Priority.none);
        });
        test('missing parenthesis', () {
          final todo = Todo.fromString(value: 'A Write some tests');
          expect(todo.priority, Priority.none);
        });
        test('missing whitespace', () {
          final todo = Todo.fromString(value: '(A)Write some tests');
          expect(todo.priority, Priority.none);
        });
        test('wrong priority sign', () {
          final todo = Todo.fromString(value: '(a) Write some tests');
          expect(todo.priority, Priority.none);
        });
        test('wrong position', () {
          final todo = Todo.fromString(value: 'Write some tests (A)');
          expect(todo.priority, Priority.none);
        });
      });
    });

    group('todo creation date', () {
      group('with creation date', () {
        test('incompleted simple todo', () {
          final todo = Todo.fromString(value: '2022-11-01 Write some tests');
          expect(todo.creationDate, DateTime.parse('2022-11-01'));
        });
        test('incompleted and with priority simple todo', () {
          final todo =
              Todo.fromString(value: '(A) 2022-11-01 Write some tests');
          expect(todo.creationDate, DateTime.parse('2022-11-01'));
        });
        test('incompleted full todo', () {
          final todo = Todo.fromString(
            value:
                '(A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.creationDate, DateTime.parse('2022-11-01'));
        });
        test('completed simple todo', () {
          final todo = Todo.fromString(
              value: 'x 2022-11-16 2022-11-01 Write some tests');
          expect(todo.creationDate, DateTime.parse('2022-11-01'));
        });
        test('completed and with priority simple todo', () {
          final todo = Todo.fromString(
              value: 'x 2022-11-16 (A) 2022-11-01 Write some tests');
          expect(todo.creationDate, DateTime.parse('2022-11-01'));
        });
        test('completed full todo', () {
          final todo = Todo.fromString(
            value:
                'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.creationDate, DateTime.parse('2022-11-01'));
        });
      });
    });

    group('todo completion date', () {
      group('with completion date', () {
        test('completed simple todo', () {
          final todo = Todo.fromString(value: 'x 2022-11-16 Write some tests');
          expect(todo.completionDate, DateTime.parse('2022-11-16'));
        });
        test('completed and with priority simple todo', () {
          final todo =
              Todo.fromString(value: 'x 2022-11-16 (A) Write some tests');
          expect(todo.completionDate, DateTime.parse('2022-11-16'));
        });
        test('completed full todo', () {
          final todo = Todo.fromString(
            value:
                'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.completionDate, DateTime.parse('2022-11-16'));
        });
      });
      group('without completion date', () {
        test('incompleted simple todo', () {
          final todo = Todo.fromString(value: 'Write some tests');
          expect(todo.completionDate, null);
        });
        test('incompleted and with priority simple todo', () {
          final todo = Todo.fromString(value: '(A) Write some tests');
          expect(todo.completionDate, null);
        });
        test('incompleted full todo', () {
          final todo = Todo.fromString(
            value:
                '(A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.completionDate, null);
        });
      });
      group('edge cases', () {
        test(
            'incompleted with forbidden completiond date (is recognized as part of description)',
            () {
          final todo = Todo.fromString(
            value: '2022-11-16 2022-11-01 Write some tests',
          );
          expect(todo.completionDate, null);
          expect(todo.creationDate, DateTime.parse('2022-11-16'));
          expect(todo.description, '2022-11-01 Write some tests');
        });
        test(
            'incompleted with priority and forbidden completion date (is recognized as part of description)',
            () {
          final todo = Todo.fromString(
            value: '(A) 2022-11-16 2022-11-01 Write some tests',
          );
          expect(todo.priority, Priority.A);
          expect(todo.completionDate, null);
          expect(todo.creationDate, DateTime.parse('2022-11-16'));
          expect(todo.description, '2022-11-01 Write some tests');
        });
        test('completed and missing completion date', () {
          final DateTime now = DateTime.now();
          final Todo todo = Todo.fromString(value: 'x Write some tests');
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(now.year, now.month, now.day));
        });
        test('completed with priority and missing completion date', () {
          final DateTime now = DateTime.now();
          final Todo todo = Todo.fromString(value: 'x (A) Write some tests');
          expect(todo.completion, true);
          expect(todo.completionDate, DateTime(now.year, now.month, now.day));
        });
      });
    });

    group('todo projects', () {
      test('no project tags', () {
        final todo = Todo.fromString(value: 'Write some tests');
        expect(todo.projects, []);
      });
      test('single project tag', () {
        final todo = Todo.fromString(value: 'Write some tests +ntodotxt');
        expect(todo.projects, ['ntodotxt']);
      });
      test('multiple project tags', () {
        final todo = Todo.fromString(value: 'Write some tests +ntodotxt +code');
        expect(todo.projects, ['code', 'ntodotxt']);
      });
      test('multiple project tags (not in sequence)', () {
        final todo = Todo.fromString(value: 'Write some +tests for +ntodotxt');
        expect(todo.projects, ['ntodotxt', 'tests']);
      });
      test('project tag with a special name', () {
        final todo =
            Todo.fromString(value: 'Write some tests +n-todo.txt+_123');
        expect(todo.projects, ['n-todo.txt+_123']);
      });
      test('project tag with a name in capital letters', () {
        final todo = Todo.fromString(value: 'Write some tests +NTodoTXT');
        expect(todo.projects, ['ntodotxt']);
      });
      test('project tag with project duplication', () {
        final todo =
            Todo.fromString(value: 'Write some tests +ntodotxt +ntodotxt');
        expect(todo.projects, ['ntodotxt']);
      });
      test('incompleted full todo', () {
        final todo = Todo.fromString(
          value: '2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.projects, ['project']);
      });
      test('incompleted with priority full todo', () {
        final todo = Todo.fromString(
          value:
              '(A) 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.projects, ['project']);
      });
      test('completed full todo', () {
        final todo = Todo.fromString(
          value:
              'x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.projects, ['project']);
      });
      test('completed with priority full todo', () {
        final todo = Todo.fromString(
          value:
              'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.projects, ['project']);
      });
    });

    group('todo contexts', () {
      test('no context tag', () {
        final todo = Todo.fromString(value: 'Write some tests');
        expect(todo.contexts, []);
      });
      test('single context tag', () {
        final todo = Todo.fromString(value: 'Write some @tests');
        expect(todo.contexts, ['tests']);
      });
      test('multiple context tags', () {
        final todo = Todo.fromString(value: 'Write some @tests @dx');
        expect(todo.contexts, ['dx', 'tests']);
      });
      test('multiple context tags (not in sequence)', () {
        final todo = Todo.fromString(value: 'Write some @tests for @ntodotxt');
        expect(todo.contexts, ['ntodotxt', 'tests']);
      });
      test('context tag with a special name', () {
        final todo =
            Todo.fromString(value: 'Write some tests for @n-todo.txt+_123');
        expect(todo.contexts, ['n-todo.txt+_123']);
      });
      test('context tag with a name in capital letters', () {
        final todo = Todo.fromString(value: 'Write some tests @NTodoTXT');
        expect(todo.contexts, ['ntodotxt']);
      });
      test('context tag with context duplication', () {
        final todo =
            Todo.fromString(value: 'Write some tests @ntodotxt @ntodotxt');
        expect(todo.contexts, ['ntodotxt']);
      });
      test('incompleted full todo', () {
        final todo = Todo.fromString(
          value: '2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.contexts, ['context']);
      });
      test('incompleted with priority full todo', () {
        final todo = Todo.fromString(
          value:
              '(A) 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.contexts, ['context']);
      });
      test('completed full todo', () {
        final todo = Todo.fromString(
          value:
              'x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.contexts, ['context']);
      });
      test('completed with priority full todo', () {
        final todo = Todo.fromString(
          value:
              'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.contexts, ['context']);
      });
    });

    group('todo key values', () {
      test('no key value tag', () {
        final todo = Todo.fromString(value: 'Write some tests');
        expect(todo.keyValues, []);
      });
      test('single key value tag', () {
        final todo = Todo.fromString(value: 'Write some tests key:value');
        expect(todo.keyValues, {'key:value'});
      });
      test('multiple key value tags', () {
        final todo =
            Todo.fromString(value: 'Write some tests key1:value1 key2:value2');
        expect(todo.keyValues, {'key1:value1', 'key2:value2'});
      });
      test('multiple key value tags (not in sequence)', () {
        final todo =
            Todo.fromString(value: 'Write some key1:value1 tests key2:value2');
        expect(todo.keyValues, {'key1:value1', 'key2:value2'});
      });
      test('key value tag with a special name', () {
        final todo =
            Todo.fromString(value: 'Write some tests key-@_123:value_@123');
        expect(todo.keyValues, {'key-@_123:value_@123'});
      });
      test('key value tag with a name in capital letters', () {
        final todo = Todo.fromString(value: 'Write some tests Key:Value');
        expect(todo.keyValues, {'key:value'});
      });
      test('key value tag with key value duplication', () {
        final todo =
            Todo.fromString(value: 'Write some tests key:value key:value');
        expect(todo.keyValues, {'key:value'});
      });
      test('invalid key value tag', () {
        final todo =
            Todo.fromString(value: 'Write some tests key1:value1:invalid');
        expect(todo.keyValues, []);
      });
      test('incompleted full todo', () {
        final todo = Todo.fromString(
          value: '2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.keyValues, {'due:2022-12-31'});
      });
      test('incompleted with priority full todo', () {
        final todo = Todo.fromString(
          value:
              '(A) 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.keyValues, {'due:2022-12-31'});
      });
      test('completed full todo', () {
        final todo = Todo.fromString(
          value:
              'x 2022-11-16 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.keyValues, {'due:2022-12-31'});
      });
      test('completed with priority full todo', () {
        final todo = Todo.fromString(
          value:
              'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
        );
        expect(todo.keyValues, {'due:2022-12-31'});
      });
    });

    group('todo description', () {
      group('with description', () {
        test('incompleted with description', () {
          final todo = Todo.fromString(value: 'Write some tests');
          expect(todo.description, 'Write some tests');
        });
        test('incompleted with description and priority', () {
          final todo = Todo.fromString(value: '(A) Write some tests');
          expect(todo.description, 'Write some tests');
        });
        test('incompleted full todo', () {
          final todo = Todo.fromString(
            value:
                '(A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.description,
              'Write some tests +project @context due:2022-12-31');
        });
        test('completed with description', () {
          final todo = Todo.fromString(value: 'x 2022-11-16 Write some tests');
          expect(todo.description, 'Write some tests');
        });
        test('completed with description and priority', () {
          final todo = Todo.fromString(
            value: 'x 2022-11-16 (A) Write some tests',
          );
          expect(todo.description, 'Write some tests');
        });
        test('completed full todo', () {
          final todo = Todo.fromString(
            value:
                'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31',
          );
          expect(todo.description,
              'Write some tests +project @context due:2022-12-31');
        });
      });

      group('empty description', () {
        test('completed with projects', () {
          final Todo todo =
              Todo.fromString(value: 'x 2022-11-16 +project1 +project2');
          expect(todo.description, '+project1 +project2');
        });
        test('completed with contexts', () {
          final Todo todo =
              Todo.fromString(value: 'x 2022-11-16 @context1 @context2');
          expect(todo.description, '@context1 @context2');
        });
        test('completed with key-values', () {
          final Todo todo =
              Todo.fromString(value: 'x 2022-11-16 key1:val1 key2:val2');
          expect(todo.description, 'key1:val1 key2:val2');
        });
        test('completed with all kind of tags', () {
          final Todo todo =
              Todo.fromString(value: 'x 2022-11-16 +project @context key:val');
          expect(todo.description, '+project @context key:val');
        });
        test('completed', () {
          final Todo todo = Todo.fromString(value: 'x 2022-11-16');
          expect(todo.description, '');
        });
        test('completed with priority', () {
          final Todo todo = Todo.fromString(value: 'x 2022-11-16 (A)');
          expect(todo.description, '');
        });
        test('completed with priority and creation date', () {
          final Todo todo =
              Todo.fromString(value: 'x 2022-11-16 (A) 2022-11-01');
          expect(todo.description, '');
        });
        test('incompleted with projects', () {
          final Todo todo = Todo.fromString(value: '+project1 +project2');
          expect(todo.description, '+project1 +project2');
        });
        test('incompleted with contexts', () {
          final Todo todo = Todo.fromString(value: '@context1 @context2');
          expect(todo.description, '@context1 @context2');
        });
        test('incompleted with key-values', () {
          final Todo todo = Todo.fromString(value: 'key1:val1 key2:val2');
          expect(todo.description, 'key1:val1 key2:val2');
        });
        test('incompleted with all kind of tags', () {
          final Todo todo = Todo.fromString(value: '+project @context key:val');
          expect(todo.description, '+project @context key:val');
        });
        test('incompleted', () {
          final Todo todo = Todo.fromString(value: '');
          expect(todo.description, '');
        });
        test('incompleted with priority', () {
          final Todo todo = Todo.fromString(value: '(A)');
          expect(todo.description, '');
        });
        test('incompleted with priority and creation date', () {
          final Todo todo = Todo.fromString(value: '(A) 2022-11-01');
          expect(todo.description, '');
        });
      });
    });
  });

  group('todo dueDate', () {
    test('unset', () {
      final todo = Todo.fromString(
        value: '2022-11-01 Write some tests',
      );
      expect(todo.dueDate, null);
    });
    test('set', () {
      final todo = Todo.fromString(
        value: '2022-11-01 Write some tests due:2023-12-31',
      );
      expect(todo.dueDate, DateTime(2023, 12, 31));
    });
    test('set but invalid', () {
      final todo = Todo.fromString(
        value: '2022-11-01 Write some tests due:yyyy-mm-dd',
      );
      expect(todo.dueDate, null);
    });
  });

  group('todo toString()', () {
    test('full todo', () {
      const String value =
          'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31';
      final todo = Todo.fromString(
        value: value,
      );
      expect(todo.toString(), value);
    });
    test('full todo with multiple whitespace', () {
      final todo = Todo.fromString(
        value:
            'x  2022-11-16  (A)  2022-11-01  Write some tests +project @context due:2022-12-31',
      );
      expect(todo.toString(),
          'x 2022-11-16 (A) 2022-11-01 Write some tests +project @context due:2022-12-31');
    });
  });
}
