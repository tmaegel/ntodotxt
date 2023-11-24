import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

void main() {
  late LocalTodoListApi api;
  late MemoryFileSystem fs;
  late File file;
  setUp(() async {
    api = LocalTodoListApi();
    fs = MemoryFileSystem();
    file = fs.file('todo.test');
    await file.create();
    await file.writeAsString("", flush: true); // Empty file.
  });

  group("LocalTodoListApi", () {
    group("init()", () {
      test("initial file is empty", () async {
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [],
            ],
          ),
        );
      });
      test("initial file with initial todos", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        await file.writeAsString(todo.toString(), flush: true); // Add todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todo],
            ],
          ),
        );
      });
    });

    group("saveTodo()", () {
      test("create new todo", () async {
        // Need todo with unset id here.
        final Todo todo = Todo(
          description: 'Code something',
          creationDate: DateTime(2023, 11, 23),
        );

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);
        await repository.saveTodo(todo);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todo.copyWith(id: 0)], // After saving the todo should has an id.
            ],
          ),
        );
        expect(
          await file.readAsLines(),
          [todo.toString()],
        );
      });
      test("update existing todo", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = todo.copyWith(
          description: 'Code something other',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);
        await repository.saveTodo(todo2);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todo2],
            ],
          ),
        );

        expect(
          await file.readAsLines(),
          [todo2.toString()],
        );
      });
      test("update non-existing todo", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = todo.copyWith(
          id: 1, // non-existing todo (id differ).
          description: 'Code something other',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);

        await expectLater(
          () async =>
              await repository.saveTodo(todo2), // Save non-existing todo.
          throwsA(isA<TodoNotFound>()),
        );

        expect(
          await file.readAsLines(),
          [todo.toString()],
        );
      });
    });

    group("deleteTodo()", () {
      test("delete existing todo", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);
        await repository.deleteTodo(todo);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [],
            ],
          ),
        );

        expect(await file.readAsLines(), []);
      });
      test("delete non-existing todo", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = todo.copyWith(
          id: 1, // non-existing todo (id differ).
          description: 'Code something other',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);
        await repository.deleteTodo(todo2); // Delete non-existing todo.

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todo],
            ],
          ),
        );

        expect(
          await file.readAsLines(),
          [todo.toString()],
        );
      });
    });

    group("saveMultipleTodos()", () {
      test("update todos", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: 1,
          value: '2023-11-23 Code something other',
        );

        await file.writeAsString(
          [todo, todo2].join(Platform.lineTerminator),
          flush: true,
        ); // Initial todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todo, todo2],
            ],
          ),
        );

        final Todo todoUpdate = todo.copyWith(
          completion: true,
          completionDate: DateTime.now(),
        );
        final Todo todo2Update = todo2.copyWith(
          completion: true,
          completionDate: DateTime.now(),
        );
        await repository.saveMultipleTodos([todoUpdate, todo2Update]);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todoUpdate, todo2Update],
            ],
          ),
        );
        expect(
          await file.readAsLines(),
          [
            todoUpdate.toString(),
            todo2Update.toString(),
          ],
        );
      });
    });

    group("deleteMultipleTodos()", () {
      test("delete todos", () async {
        final Todo todo = Todo.fromString(
          id: 0,
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: 1,
          value: '2023-11-23 Code something other',
        );

        await file.writeAsString(
          [todo, todo2].join(Platform.lineTerminator),
          flush: true,
        ); // Initial todo.

        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        await repository.init(file: file);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [todo, todo2],
            ],
          ),
        );

        await repository.deleteMultipleTodos([todo, todo2]);

        await expectLater(
          api.getTodoList(),
          emitsInOrder(
            [
              [],
            ],
          ),
        );
        expect(await file.readAsLines(), []);
      });
    });
  });
}
