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
    await file.writeAsString('', flush: true); // Empty file.
  });

  group('LocalTodoListApi', () {
    group('init()', () {
      test('initial file is empty', () async {
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [],
          ]),
        );
      });
      test('initial file with initial todo', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        await file.writeAsString(todoStr, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo],
          ]),
        );
      });
      test('initial file with multiple initial todos', () async {
        List<String> todoListStr = [
          'x 2023-12-03 2023-12-02 TodoA id:1',
          '1970-01-01 TodoB due:1970-01-01 id:2',
          '2023-12-02 TodoC due:2023-12-04 id:3',
          '2023-12-02 TodoD due:2023-12-05 id:4',
          '2023-11-11 TodoE id:5',
        ];
        List<Todo> todoList = [
          for (var s in todoListStr) Todo.fromString(value: s)
        ];

        await file.writeAsString(todoListStr.join('\n'), flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [
                todoList[0],
                todoList[1],
                todoList[2],
                todoList[3],
                todoList[4],
              ],
            ],
          ),
        );
      });
    });

    group('saveTodo()', () {
      test('create new todo without id', () async {
        const String todoStr = '2023-11-23 Code something';
        final Todo todo = Todo.fromString(value: todoStr);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), ['$todoStr id:${todo.id}']);
      });

      test('create new todo with id', () async {
        const String todoStr =
            '2023-11-23 Code something id:d181bdf4-3c0b-483c-a350-62db3c19ff36';
        final Todo todo = Todo.fromString(value: todoStr);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), [todoStr]);
      });
      test('update existing todo', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        // Update existing todo.
        final Todo todo2 = todo.copyWith(
          description: 'Code something other',
        );
        await file.writeAsString(todoStr, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo2);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo2],
          ]),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          ['2023-11-23 Code something other id:1'],
        );
      });
      test('update/save non-existing todo', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        const String todoStr2 = '2023-11-23 Code something other id:2';
        final Todo todo2 = Todo.fromString(value: todoStr2);
        await file.writeAsString(todoStr, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todo2);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo, todo2],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), [todoStr, todoStr2]);
      });
      test('partial update', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        const String todoStr2 = '2023-11-23 Code something other id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        final Todo todo2 = Todo.fromString(value: todoStr2);
        // Get diff for changes.
        final Todo todoDiff = todo.copyDiff(priority: Priority.A);
        // Simulate changes
        await file.writeAsString(todoStr2, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.saveTodo(todoDiff);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo2.copyWith(priority: Priority.A)],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), ['(A) $todoStr2']);
      });
    });

    group('deleteTodo()', () {
      test('delete existing todo', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        await file.writeAsString(todoStr, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.deleteTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), []);
      });
      test('delete non-existing todo', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        const String todoStr2 = '2023-11-23 Code something other id:2';
        final Todo todo2 = Todo.fromString(value: todoStr2);
        await file.writeAsString(todoStr, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);
        repository.deleteTodo(todo2); // Delete non-existing todo.

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), [todo.toString()]);
      });
    });

    group('saveMultipleTodos()', () {
      test('update todos', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        const String todoStr2 = '2023-11-23 Code something other id:2';
        final Todo todo2 = Todo.fromString(value: todoStr2);

        await file.writeAsString(
          [todoStr, todoStr2].join(Platform.lineTerminator),
          flush: true,
        );

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo, todo2],
          ]),
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

    group('deleteMultipleTodos()', () {
      test('delete todos', () async {
        const String todoStr = '2023-11-23 Code something id:1';
        final Todo todo = Todo.fromString(value: todoStr);
        const String todoStr2 = '2023-11-23 Code something other id:2';
        final Todo todo2 = Todo.fromString(value: todoStr2);

        await file.writeAsString(
          [todo, todo2].join(Platform.lineTerminator),
          flush: true,
        );

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api: api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo, todo2],
          ]),
        );

        repository.deleteMultipleTodos([todo, todo2]);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), []);
      });
    });
  });
}
