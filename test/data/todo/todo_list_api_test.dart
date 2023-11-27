import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';

void main() {
  late File file;
  setUp(() async {
    // Filewatcher does not work with MemoryFileSystem.
    file = File('/tmp/todo.test');
    await file.create();
    await file.writeAsString("", flush: true); // Empty file.
  });

  group("LocalTodoListApi", () {
    group("init()", () {
      test("initial file is empty", () async {
        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);

        await expectLater(
          repository.getTodoList(),
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);

        await expectLater(
          repository.getTodoList(),
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        repository.saveTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo.copyWith(id: 0)], // After saving the todo should has an id.
            ],
          ),
        );

        repository.writeToSource();
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        repository.saveTodo(todo2);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo2],
            ],
          ),
        );

        repository.writeToSource();
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);

        expect(
          () async => repository.saveTodo(todo2), // Save non-existing todo.
          throwsA(isA<TodoNotFound>()),
        );

        repository.writeToSource();
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        repository.deleteTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [],
            ],
          ),
        );

        repository.writeToSource();
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);
        repository.deleteTodo(todo2); // Delete non-existing todo.

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo],
            ],
          ),
        );

        repository.writeToSource();
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);

        await expectLater(
          repository.getTodoList(),
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
        repository.saveMultipleTodos([todoUpdate, todo2Update]);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todoUpdate, todo2Update],
            ],
          ),
        );

        repository.writeToSource();
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

        final LocalTodoListApi api = LocalTodoListApi(file);
        final TodoListRepository repository =
            TodoListRepository(todoListApi: api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo, todo2],
            ],
          ),
        );

        repository.deleteMultipleTodos([todo, todo2]);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [],
            ],
          ),
        );

        repository.writeToSource();
        expect(await file.readAsLines(), []);
      });
    });
  });
}
