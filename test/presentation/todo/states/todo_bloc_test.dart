import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MemoryFileSystem fs;
  late File file;
  final Todo todo = Todo(
    priority: 'A',
    creationDate: DateTime(2022, 11, 1),
    description: 'Write some tests',
    projects: const {'project1'},
    contexts: const {'context1'},
    keyValues: const {'foo': 'bar'},
  );

  setUp(() async {
    file = File('/tmp/todo.test');
    fs = MemoryFileSystem();
    file = fs.file('todo.test');
    await file.create();
    await file.writeAsString(todo.toString(), flush: true); // Initial todo.

    final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
    TodoListRepository(api: api);
  });

  group('Initial', () {
    test('initial state', () {
      final TodoBloc todoBloc = TodoBloc(todo: todo);
      expect(todoBloc.state, TodoInitial(todo: todo));
    });
  });

  group('TodoCompletionToggled', () {
    test(
        'completed todo with completion date when TodoCompletionToggled(true) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith(completion: false));
      bloc.add(const TodoCompletionToggled(true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(completion: true)),
        ]),
      );
    });
    test(
        'incompleted todo with unsetted completion date when TodoCompletionToggled(false) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith(completion: true));
      bloc.add(const TodoCompletionToggled(false));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(completion: false)),
        ]),
      );
    });
  });

  group('TodoDescriptionChanged', () {
    test(
        'updated description when TodoDescriptionChanged(<description>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoDescriptionChanged('Write more tests'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(description: 'Write more tests')),
        ]),
      );
    });
  });

  group('TodoPriorityAdded', () {
    test('updated priority when TodoPriorityAdded(<priority>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoPriorityAdded('B'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(priority: 'B')),
        ]),
      );
    });
  });

  group('TodoPriorityRemoved', () {
    test('removed priority when TodoPriorityRemoved() is called', () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoPriorityRemoved());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(priority: '')),
        ]),
      );
    });
  });

  group('TodoProjectsAdded', () {
    test('updated projects when TodoProjectsAdded(<projects>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['project2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1', 'project2'})),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['project 2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid project tag: project 2',
            todo: todo.copyWith(projects: {'project1'}),
          ),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (duplication)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['project1']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1'})),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (duplication/case sensitive)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['Project1']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1'})),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (multiple entries)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['project2', 'project3']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(projects: {'project1', 'project2', 'project3'}),
          ),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (multiple entries/invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['project1', 'project 2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid project tag: project 2',
            todo: todo.copyWith(projects: {'project1'}),
          ),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (multiple entries/duplication)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['project1', 'project2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1', 'project2'})),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectsAdded(<projects>) is called (multiple entries/duplication/case sensitive)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectsAdded(['Project1', 'Project2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1', 'project2'})),
        ]),
      );
    });
  });

  group('TodoProjectRemoved', () {
    test('updated projects when TodoProjectRemoved(<project>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectRemoved('project1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {})),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectRemoved(<project>) is called (invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectRemoved('project 1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1'})),
        ]),
      );
    });
    test(
        'updated projects when TodoProjectRemoved(<project>) is called (not exists)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoProjectRemoved('project2'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(projects: {'project1'})),
        ]),
      );
    });
  });

  group('TodoContextsAdded', () {
    test('updated contexts when TodoContextsAdded(<contexts>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['context2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1', 'context2'})),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['context 2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid context tag: context 2',
            todo: todo.copyWith(contexts: {'context1'}),
          ),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (duplication)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['context1']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1'})),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (duplication/case sensitive)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['Context1']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1'})),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (multiple entries)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['context2', 'context3']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(contexts: {'context1', 'context2', 'context3'}),
          ),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (multiple entries/invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['context1', 'context 2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid context tag: context 2',
            todo: todo.copyWith(contexts: {'context1'}),
          ),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (multiple entries/duplication)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['context1', 'context2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1', 'context2'})),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextsAdded(<contexts>) is called (multiple entries/duplication/case sensitive)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextsAdded(['Context1', 'Context2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1', 'context2'})),
        ]),
      );
    });
  });

  group('TodoContextRemoved', () {
    test('updated contexts when TodoContextRemoved(<context>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextRemoved('context1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {})),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextRemoved(<context>) is called (invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextRemoved('context 1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1'})),
        ]),
      );
    });
    test(
        'updated contexts when TodoContextRemoved(<context>) is called (not exists)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoContextRemoved('context2'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(contexts: {'context1'})),
        ]),
      );
    });
  });

  group('TodoKeyValuesAdded', () {
    test('updated key-values when TodoKeyValuesAdded(<keyValues>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['key:val']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(
                keyValues: {'foo': 'bar', 'key': 'val', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['key_val']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid key value tag: key_val',
            todo: todo.copyWith(keyValues: {'foo': 'bar', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (duplication)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['foo:bar']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(keyValues: {'foo': 'bar', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (duplication/case sensitive)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['Foo:bar']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(keyValues: {'foo': 'bar', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValueAdded(<keyValues>) is called (duplication/update value)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['foo:new']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(keyValues: {'foo': 'new', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['key1:val1', 'key2:val2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(keyValues: {
              'foo': 'bar',
              'key1': 'val1',
              'key2': 'val2',
              'id': todo.id
            }),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['key1:val1', 'key2_val2']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid key value tag: key2_val2',
            todo: todo.copyWith(keyValues: {'foo': 'bar', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/duplication)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['key1:val1', 'foo:bar']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(
                keyValues: {'foo': 'bar', 'key1': 'val1', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/duplication/case sensitive)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['Key1:val1', 'Foo:bar']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(
                keyValues: {'foo': 'bar', 'key1': 'val1', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/update value)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValuesAdded(['key1:val1', 'foo:new']));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(
                keyValues: {'foo': 'new', 'key1': 'val1', 'id': todo.id}),
          ),
        ]),
      );
    });
  });

  group('TodoKeyValueRemoved', () {
    test('updated key-values when TodoKeyValueRemoved(<key:val>) is called',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValueRemoved('foo:bar'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(todo: todo.copyWith(keyValues: {'id': todo.id})),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValueRemoved(<key:val>) is called (invalid format)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValueRemoved('key_val'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoError(
            message: 'Invalid key value tag: key_val',
            todo: todo.copyWith(keyValues: {'foo': 'bar', 'id': todo.id}),
          ),
        ]),
      );
    });
    test(
        'updated key-values when TodoKeyValueRemoved(<key:val>) is called (not exits)',
        () async {
      final TodoBloc bloc = TodoBloc(todo: todo.copyWith());
      bloc.add(const TodoKeyValueRemoved('key:val'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoChange(
            todo: todo.copyWith(keyValues: {'foo': 'bar', 'id': todo.id}),
          ),
        ]),
      );
    });
  });
}
