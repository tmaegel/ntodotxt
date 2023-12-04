import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

void main() {
  late MemoryFileSystem fs;
  late File file;
  setUp(() async {
    fs = MemoryFileSystem();
    file = fs.file('todo.test');
    await file.create();
    await file.writeAsString("", flush: true); // Empty file.
  });

  group("LocalTodoListApi", () {
    group("init()", () {
      test("initial file is empty", () async {
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

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
          value: '2023-11-23 Code something',
        );
        await file.writeAsString(todo.toString(), flush: true); // Add todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

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
      test("create new todo without id", () async {
        final Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo.copyWith()],
            ],
          ),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          ['2023-11-23 Code something id:${todo.id}'],
        );
      });

      test("create new todo with id", () async {
        final Todo todo = Todo.fromString(
          value:
              '2023-11-23 Code something id:d181bdf4-3c0b-483c-a350-62db3c19ff36',
        );

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo.copyWith()],
            ],
          ),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          ['2023-11-23 Code something id:d181bdf4-3c0b-483c-a350-62db3c19ff36'],
        );
      });
      test("update existing todo", () async {
        final Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );
        // Update existing todo.
        final Todo todo2 = todo.copyWith(
          description: 'Code something other',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo2);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo2],
            ],
          ),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          [todo2.toString()],
        );
      });
      test("update/save non-existing todo", () async {
        final Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          value: 'Code something other',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo2);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [
                todo.copyWith(),
                todo2.copyWith(),
              ],
            ],
          ),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          [
            todo.toString(),
            todo2.toString(),
          ],
        );
      });
      test("partial update", () async {
        Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );
        // Update existing todo.
        final Todo todo2 = todo.copyDiff(priority: 'A');
        // Simulate changes
        todo = todo.copyWith(description: 'Code something other');
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo2);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo.copyWith(priority: 'A')],
            ],
          ),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          [todo.copyWith(priority: 'A').toString()],
        );
      });
    });

    group("deleteTodo()", () {
      test("delete existing todo", () async {
        final Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.deleteTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [],
            ],
          ),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), []);
      });
      test("delete non-existing todo", () async {
        final Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          value: '2023-11-23 Code something other',
        );
        await file.writeAsString(todo.toString(), flush: true); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.deleteTodo(todo2); // Delete non-existing todo.

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [todo],
            ],
          ),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          [todo.toString()],
        );
      });
    });

    group("saveMultipleTodos()", () {
      test("update todos", () async {
        final Todo todo = Todo.fromString(
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          value: '2023-11-23 Code something other',
        );

        await file.writeAsString(
          [todo, todo2].join(Platform.lineTerminator),
          flush: true,
        ); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

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

        await repository.writeToSource();
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
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          value: '2023-11-23 Code something other',
        );

        await file.writeAsString(
          [todo, todo2].join(Platform.lineTerminator),
          flush: true,
        ); // Initial todo.

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

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

        await repository.writeToSource();
        expect(await file.readAsLines(), []);
      });
    });
  });
}
