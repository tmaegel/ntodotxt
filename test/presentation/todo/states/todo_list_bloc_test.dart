import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File file;
  late TodoListRepository repository;
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

    final LocalTodoListApi api = LocalTodoListApi(todoFile: file);
    repository = TodoListRepository(api: api);
  });

  group('Initial', () {
    test('initial state', () {
      final TodoListBloc todoListBloc = TodoListBloc(
        repository: repository,
      );
      expect(todoListBloc.state is TodoListInitial, true);
      expect(todoListBloc.state.filter, TodoListFilter.all);
      expect(todoListBloc.state.order, TodoListOrder.ascending);
      expect(todoListBloc.state.group, TodoListGroupBy.upcoming);
      expect(todoListBloc.state.todoList, []);
    });
  });

  group('TodoListSubscriptionRequested', () {
    blocTest(
      'emits the initial todo list when TodoListSubscriptionRequested() is called',
      build: () => TodoListBloc(
        repository: repository,
      ),
      act: (bloc) => bloc.add(const TodoListSubscriptionRequested()),
      expect: () => [
        TodoListSuccess(todoList: [todo]),
      ],
    );
  });

  group('TodoListTodoCompletionToggled', () {
    blocTest(
      'emits the todo list state with updated completion state when TodoListTodoCompletionToggled(<todo>, <completion>) is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(TodoListTodoCompletionToggled(todo: todo, completion: true)),
      expect: () => [
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(
          todoList: [todo.copyWith(completion: true, completionDate: now)],
        ),
      ],
    );
    blocTest(
      'emits the todo list state with updated completion state when TodoListTodoCompletionToggled(<todo>, <completion>) is called (not exists)',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(TodoListTodoCompletionToggled(
            todo: todo.copyWith(id: 99), completion: true)),
      expect: () => [
        TodoListSuccess(todoList: [todo]),
        TodoListError(
          message: 'Todo with id 99 could not be found',
          todoList: [todo],
        ),
      ],
    );
  });

  group('TodoListTodoSelectedToggled', () {
    blocTest(
      'emits the todo list state with updated selected state when TodoListTodoSelectedToggled(<todo>) is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(
          TodoListTodoSelectedToggled(todo: todo.copyWith(), selected: true),
        ),
      expect: () => [
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(todoList: [todo.copyWith(selected: true)]),
      ],
    );
  });

  group('TodoListSelectedAll', () {
    blocTest(
      'emits the todo list state with updated selected state when TodoListSelectedAll() is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(const TodoListSelectedAll()),
      expect: () => [
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(todoList: [todo.copyWith(selected: true)]),
      ],
    );
  });

  group('TodoListUnselectedAll', () {
    blocTest(
      'emits the todo list state with updated selected state when TodoListUnselectedAll() is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(const TodoListSelectedAll())
        ..add(const TodoListUnselectedAll()),
      expect: () => [
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(todoList: [todo.copyWith(selected: true)]),
        TodoListSuccess(todoList: [todo.copyWith(selected: false)]),
      ],
    );
  });

  group('TodoListOrderChanged', () {
    blocTest(
      'emits the todo list state with updated order property when TodoListOrderChanged(<order>) is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(const TodoListOrderChanged(order: TodoListOrder.descending)),
      expect: () => [
        TodoListSuccess(order: TodoListOrder.ascending, todoList: [todo]),
        TodoListSuccess(order: TodoListOrder.descending, todoList: [todo]),
      ],
    );
  });

  group('TodoListFilterChanged', () {
    blocTest(
      'emits the todo list state with updated filter property when TodoListFilterChanged(<filter>) is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(
          const TodoListFilterChanged(filter: TodoListFilter.completedOnly),
        ),
      expect: () => [
        TodoListSuccess(filter: TodoListFilter.all, todoList: [todo]),
        TodoListSuccess(filter: TodoListFilter.completedOnly, todoList: [todo]),
      ],
    );
  });

  group('TodoListGroupByChanged', () {
    blocTest(
      'emits the todo list state with updated group property when TodoListGroupByChanged(<group>) is called',
      build: () => TodoListBloc(repository: repository),
      act: (bloc) => bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(const TodoListGroupByChanged(group: TodoListGroupBy.context)),
      expect: () => [
        TodoListSuccess(group: TodoListGroupBy.upcoming, todoList: [todo]),
        TodoListSuccess(group: TodoListGroupBy.context, todoList: [todo]),
      ],
    );
  });
}
