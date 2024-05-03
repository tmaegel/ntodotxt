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
        final TodoListRepository repository = TodoListRepository(api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [],
          ]),
        );
      });
      test('initial file with initial todo', () async {
        const String todoStr = '2023-11-23 Code something';
        await file.writeAsString(todoStr, flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [Todo.fromString(value: todoStr)],
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
        await file.writeAsString(todoListStr.join('\n'), flush: true);

        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [for (var s in todoListStr) Todo.fromString(value: s)],
            ],
          ),
        );
      });
    });

    group('saveTodo()', () {
      test('create new todo', () async {
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );

        repository.saveTodo(todo);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), [todo.toString()]);
      });
      test('update existing todo', () async {
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something other',
        );

        repository.saveTodo(todo);
        repository.saveTodo(todo2); // Update existing one.

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo2],
          ]),
        );

        await repository.writeToSource();
        expect(
          await file.readAsLines(),
          [todo2.toString()],
        );
      });
      test('update/save non-existing todo', () async {
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: '2',
          value: '2023-11-23 Code something other',
        );

        repository.saveTodo(todo);
        repository.saveTodo(todo2); // Update non-existing one.

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [todo, todo2],
          ]),
        );

        await repository.writeToSource();
        expect(await file.readAsLines(), [todo.toString(), todo2.toString()]);
      });
    });

    group('deleteTodo()', () {
      test('delete existing todo', () async {
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );

        repository.saveTodo(todo);
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
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: '2',
          value: '2023-11-23 Code something other',
        );

        repository.saveTodo(todo);
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
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: '2',
          value: '2023-11-23 Code something other',
        );

        repository.saveTodo(todo);
        repository.saveTodo(todo2);

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
        final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
        final TodoListRepository repository = TodoListRepository(api);
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: '2',
          value: '2023-11-23 Code something other',
        );

        repository.saveTodo(todo);
        repository.saveTodo(todo2);

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
