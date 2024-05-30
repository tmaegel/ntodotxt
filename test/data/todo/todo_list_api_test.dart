import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

File mockTodoListFile(List<String> rawTodoList) {
  final MemoryFileSystem fs = MemoryFileSystem();
  final File file = fs.file('todo.txt');
  file.createSync();
  file.writeAsStringSync(
    rawTodoList.join(Platform.lineTerminator),
    flush: true,
  );

  return file;
}

TodoListRepository mockLocalTodoListRepository(File todoFile) {
  final LocalTodoListApi api = LocalTodoListApi(localTodoFile: todoFile);
  final TodoListRepository repository = TodoListRepository(api);

  return repository;
}

void main() {
  late File todoFile;
  late TodoListRepository repository;

  setUp(() {
    todoFile = mockTodoListFile([]);
    repository = mockLocalTodoListRepository(todoFile);
  });

  group('LocalTodoListApi', () {
    group('init()', () {
      test('initial file with initial todo', () async {
        const List<String> todoListStr = [
          '2023-11-23 Code something',
        ];

        todoFile = mockTodoListFile(todoListStr);
        repository = mockLocalTodoListRepository(todoFile);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder(
            [
              [for (var s in todoListStr) Todo.fromString(value: s)],
            ],
          ),
        );
      });
      test('initial file with multiple initial todos', () async {
        List<String> todoListStr = [
          'x 2023-12-03 2023-12-02 TodoA',
          '1970-01-01 TodoB due:1970-01-01',
          '2023-12-02 TodoC due:2023-12-04',
          '2023-12-02 TodoD due:2023-12-05',
          '2023-11-11 TodoE',
        ];

        todoFile = mockTodoListFile(todoListStr);
        repository = mockLocalTodoListRepository(todoFile);

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

    group('read and write', () {
      test('readFromSource()', () async {
        const List<String> todoListStr = [
          '2023-11-23 Code something',
        ];

        expect(await todoFile.readAsLines(), []);

        todoFile.writeAsStringSync(
          todoListStr.join(Platform.lineTerminator),
          flush: true,
        );

        await repository.readFromSource();
        expect(await todoFile.readAsLines(), todoListStr);
      });
      test('writeToSource()', () async {
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        repository.saveTodo(todo);

        await repository.writeToSource();
        expect(await todoFile.readAsLines(), [todo.toString()]);
      });
    });

    group('existsTodo()', () {
      test('existing todo', () async {
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
        expect(await todoFile.readAsLines(), [todo.toString()]);

        expect(repository.existsTodo(todo), true);
      });
      test('non-existing todo', () async {
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );

        expect(await todoFile.readAsLines(), []);

        expect(repository.existsTodo(todo), false);
      });
    });

    group('saveTodo()', () {
      test('create new todo', () async {
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
        expect(await todoFile.readAsLines(), [todo.toString()]);
      });
      test('update existing todo', () async {
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
          await todoFile.readAsLines(),
          [todo2.toString()],
        );
      });
      test('update/save non-existing todo', () async {
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
        expect(
            await todoFile.readAsLines(), [todo.toString(), todo2.toString()]);
      });
    });

    group('deleteTodo()', () {
      test('delete existing todo', () async {
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
        expect(await todoFile.readAsLines(), []);
      });
      test('delete non-existing todo', () async {
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
        expect(await todoFile.readAsLines(), [todo.toString()]);
      });
    });

    group('saveMultipleTodos()', () {
      test('create and update todos', () async {
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

        await repository.writeToSource();
        expect(
          await todoFile.readAsLines(),
          [
            todo.toString(),
            todo2.toString(),
          ],
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
          await todoFile.readAsLines(),
          [
            todoUpdate.toString(),
            todo2Update.toString(),
          ],
        );
      });
    });

    group('deleteMultipleTodos()', () {
      test('delete todos', () async {
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

        await repository.writeToSource();
        expect(
          await todoFile.readAsLines(),
          [
            todo.toString(),
            todo2.toString(),
          ],
        );

        repository.deleteMultipleTodos([todo, todo2]);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [],
          ]),
        );

        await repository.writeToSource();
        expect(await todoFile.readAsLines(), []);
      });
      test('delete non-existing todos', () async {
        final Todo todo = Todo.fromString(
          id: '1',
          value: '2023-11-23 Code something',
        );
        final Todo todo2 = Todo.fromString(
          id: '2',
          value: '2023-11-23 Code something other',
        );

        repository.deleteMultipleTodos([todo, todo2]);

        await expectLater(
          repository.getTodoList(),
          emitsInOrder([
            [],
          ]),
        );

        await repository.writeToSource();
        expect(await todoFile.readAsLines(), []);
      });
    });
  });
}
