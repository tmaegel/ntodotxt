import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File file;
  late TodoListRepository todoListRepository;
  final Todo todo = Todo(
    id: 0,
    priority: 'A',
    creationDate: DateTime(2022, 11, 1),
    description: 'Write some tests',
    projects: const {'project1'},
    contexts: const {'context1'},
    keyValues: const {'foo': 'bar'},
  );
  final DateTime now = DateTime.now();

  setUp(() async {
    // Filewatcher does not work with MemoryFileSystem.
    file = File('/tmp/todo.test');
    await file.create();
    await file.writeAsString(todo.toString(), flush: true); // Initial todo.

    final LocalTodoListApi todoListApi = LocalTodoListApi(file);
    todoListRepository = TodoListRepository(todoListApi: todoListApi);
  });

  group('Initial', () {
    test('initial state', () {
      final TodoBloc todoBloc = TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo,
      );
      expect(todoBloc.state, TodoInitial(todo: todo));
    });
  });

  group('TodoCompletionToggled', () {
    blocTest(
      'emits a completed todo with completion date when TodoCompletionToggled(true) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(completion: false),
      ),
      act: (bloc) => bloc.add(const TodoCompletionToggled(true)),
      expect: () => [
        TodoChange(todo: todo.copyWith(completion: true, completionDate: now)),
      ],
    );
    blocTest(
      'emits a incompleted todo with unsetted completion date when TodoCompletionToggled(false) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(completion: true, completionDate: now),
      ),
      act: (bloc) => bloc.add(const TodoCompletionToggled(false)),
      expect: () => [
        TodoChange(todo: todo.copyWith(completion: false)),
      ],
    );
  });

  group('TodoDescriptionChanged', () {
    blocTest(
      'emits a todo with updated description when TodoDescriptionChanged(<description>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoDescriptionChanged('Write more tests')),
      expect: () => [
        TodoChange(todo: todo.copyWith(description: 'Write more tests')),
      ],
    );
  });

  group('TodoPriorityAdded', () {
    blocTest(
      'emits a todo updated priority when TodoPriorityAdded(<priority>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoPriorityAdded('B')),
      expect: () => [
        TodoChange(todo: todo.copyWith(priority: 'B')),
      ],
    );
  });

  group('TodoPriorityRemoved', () {
    blocTest(
      'emits a todo removed priority when TodoPriorityRemoved() is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoPriorityRemoved()),
      expect: () => [
        TodoChange(todo: todo.copyWith(priority: null, unsetPriority: true)),
      ],
    );
  });

  group('TodoProjectsAdded', () {
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectsAdded(['project2'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1', 'project2'})),
      ],
    );

    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectsAdded(['project 2'])),
      expect: () => [
        TodoError(
          message: 'Invalid project tag: project 2',
          todo: todo.copyWith(projects: {'project1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectsAdded(['project1'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1'})),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (duplication/case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectsAdded(['Project1'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1'})),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (multiple entries)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoProjectsAdded(['project2', 'project3'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(projects: {'project1', 'project2', 'project3'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (multiple entries/invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoProjectsAdded(['project1', 'project 2'])),
      expect: () => [
        TodoError(
          message: 'Invalid project tag: project 2',
          todo: todo.copyWith(projects: {'project1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (multiple entries/duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoProjectsAdded(['project1', 'project2'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1', 'project2'})),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectsAdded(<projects>) is called (multiple entries/duplication/case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoProjectsAdded(['Project1', 'Project2'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1', 'project2'})),
      ],
    );
  });

  group('TodoProjectRemoved', () {
    blocTest(
      'emits a todo with updated projects when TodoProjectRemoved(<project>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectRemoved('project1')),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {})),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectRemoved(<project>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectRemoved('project 1')),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1'})),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectRemoved(<project>) is called (not exists)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectRemoved('project2')),
      expect: () => [
        TodoChange(todo: todo.copyWith(projects: {'project1'})),
      ],
    );
  });

  group('TodoContextsAdded', () {
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<constexts>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextsAdded(['context2'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1', 'context2'})),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<contexts>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextsAdded(['context 2'])),
      expect: () => [
        TodoError(
          message: 'Invalid context tag: context 2',
          todo: todo.copyWith(contexts: {'context1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<contexts>) is called (duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextsAdded(['context1'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1'})),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<contexts>) is called (duplication/case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextsAdded(['Context1'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1'})),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<constexts>) is called (multiple entries)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoContextsAdded(['context2', 'context3'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(contexts: {'context1', 'context2', 'context3'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<constexts>) is called (multiple entries/invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoContextsAdded(['context1', 'context 2'])),
      expect: () => [
        TodoError(
          message: 'Invalid context tag: context 2',
          todo: todo.copyWith(contexts: {'context1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<constexts>) is called (multiple entries/duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoContextsAdded(['context1', 'context2'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1', 'context2'})),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextsAdded(<constexts>) is called (multiple entries/duplication/case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoContextsAdded(['Context1', 'Context2'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1', 'context2'})),
      ],
    );
  });

  group('TodoContextRemoved', () {
    blocTest(
      'emits a todo with updated contexts when TodoContextRemoved(<context>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextRemoved('context1')),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {})),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextRemoved(<context>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextRemoved('context 1')),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1'})),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextRemoved(<context>) is called (not exists)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextRemoved('context2')),
      expect: () => [
        TodoChange(todo: todo.copyWith(contexts: {'context1'})),
      ],
    );
  });

  group('TodoKeyValuesAdded', () {
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValuesAdded(['key:val'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(keyValues: {'foo': 'bar', 'key': 'val'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValuesAdded(['key_val'])),
      expect: () => [
        TodoError(
          message: 'Invalid key value tag: key_val',
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValuesAdded(['foo:bar'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(keyValues: {'foo': 'bar'})),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (duplication/case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValuesAdded(['Foo:bar'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(keyValues: {'foo': 'bar'})),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<keyValues>) is called (duplication/update value)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValuesAdded(['foo:new'])),
      expect: () => [
        TodoChange(todo: todo.copyWith(keyValues: {'foo': 'new'})),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoKeyValuesAdded(['key1:val1', 'key2:val2'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(
              keyValues: {'foo': 'bar', 'key1': 'val1', 'key2': 'val2'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoKeyValuesAdded(['key1:val1', 'key2_val2'])),
      expect: () => [
        TodoError(
          message: 'Invalid key value tag: key2_val2',
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoKeyValuesAdded(['key1:val1', 'foo:bar'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(keyValues: {'foo': 'bar', 'key1': 'val1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/duplication/case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoKeyValuesAdded(['Key1:val1', 'Foo:bar'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(keyValues: {'foo': 'bar', 'key1': 'val1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValuesAdded(<keyValues>) is called (multiple entries/update value)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) =>
          bloc.add(const TodoKeyValuesAdded(['key1:val1', 'foo:new'])),
      expect: () => [
        TodoChange(
          todo: todo.copyWith(keyValues: {'foo': 'new', 'key1': 'val1'}),
        ),
      ],
    );
  });

  group('TodoKeyValueRemoved', () {
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueRemoved(<key:val>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueRemoved('foo:bar')),
      expect: () => [
        TodoChange(todo: todo.copyWith(keyValues: {})),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueRemoved(<key:val>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueRemoved('key_val')),
      expect: () => [
        TodoError(
          message: 'Invalid key value tag: key_val',
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueRemoved(<key:val>) is called (not exits)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueRemoved('key:val')),
      expect: () => [
        TodoChange(todo: todo.copyWith(keyValues: {'foo': 'bar'})),
      ],
    );
  });
}
