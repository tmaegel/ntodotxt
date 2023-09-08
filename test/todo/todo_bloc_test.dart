import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

void main() {
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

  setUp(() {
    final LocalStorageTodoListApi todoListApi = LocalStorageTodoListApi([todo]);
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
        TodoInitial(
          todo: todo.copyWith(completion: true, completionDate: now),
        ),
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
        TodoInitial(
          todo: todo.copyWith(completion: false),
        ),
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
        TodoInitial(
          todo: todo.copyWith(description: 'Write more tests'),
        ),
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
        TodoInitial(
          todo: todo.copyWith(priority: 'B'),
        ),
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
        TodoInitial(
          todo: todo.copyWith(priority: null, unsetPriority: true),
        ),
      ],
    );
  });

  group('TodoProjectAdded', () {
    blocTest(
      'emits a todo with updated projects when TodoProjectAdded(<project>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectAdded('project2')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(projects: {'project1', 'project2'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectAdded(<project>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectAdded('project 2')),
      expect: () => [
        TodoError(
          error: 'Invalid project tag: project 2',
          todo: todo.copyWith(projects: {'project1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectAdded(<project>) is called (duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectAdded('project1')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(projects: {'project1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectAdded(<project>) is called (duplication, case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoProjectAdded('Project1')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(projects: {'project1'}),
        ),
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
        TodoInitial(
          todo: todo.copyWith(projects: {}),
        ),
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
        TodoInitial(
          todo: todo.copyWith(projects: {'project1'}),
        ),
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
        TodoInitial(
          todo: todo.copyWith(projects: {'project1'}),
        ),
      ],
    );
  });

  group('TodoContextAdded', () {
    blocTest(
      'emits a todo with updated contexts when TodoContextAdded(<constext>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextAdded('context2')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(contexts: {'context1', 'context2'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextAdded(<context>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextAdded('context 2')),
      expect: () => [
        TodoError(
          error: 'Invalid context tag: context 2',
          todo: todo.copyWith(contexts: {'context1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextAdded(<context>) is called (duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextAdded('context1')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(contexts: {'context1'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextAdded(<context>) is called (duplication, case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoContextAdded('Context1')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(contexts: {'context1'}),
        ),
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
        TodoInitial(
          todo: todo.copyWith(contexts: {}),
        ),
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
        TodoInitial(
          todo: todo.copyWith(contexts: {'context1'}),
        ),
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
        TodoInitial(
          todo: todo.copyWith(contexts: {'context1'}),
        ),
      ],
    );
  });

  group('TodoKeyValueAdded', () {
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('key:val')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(keyValues: {'foo': 'bar', 'key': 'val'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('key_val')),
      expect: () => [
        TodoError(
          error: 'Invalid key value tag: key_val',
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (duplication)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('foo:bar')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (duplication, case sensitive)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('Foo:bar')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (duplication, update value)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('foo:new')),
      expect: () => [
        TodoInitial(
          todo: todo.copyWith(keyValues: {'foo': 'new'}),
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
        TodoInitial(
          todo: todo.copyWith(keyValues: {}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueRemoved(<key:val>) is called (invalid format)',
      build: () => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo.copyWith(),
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('key_val')),
      expect: () => [
        TodoError(
          error: 'Invalid key value tag: key_val',
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
        TodoInitial(
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
  });
}
