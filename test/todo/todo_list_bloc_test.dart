import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

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
      final TodoListBloc todoListBloc = TodoListBloc(
        todoListRepository: todoListRepository,
      );
      expect(todoListBloc.state is TodoListInitial, true);
      expect(todoListBloc.state.filter, TodoListFilter.all);
      expect(todoListBloc.state.order, TodoListOrder.ascending);
      expect(todoListBloc.state.group, TodoListGroupBy.upcoming);
      expect(todoListBloc.state.todoList, []);
      expect(todoListBloc.state.toString(),
          'TodoListInitial { filter: TodoListFilter.all order: TodoListOrder.ascending group: TodoListGroupBy.upcoming }');
    });
  });

  group('TodoListSubscriptionRequested', () {
    blocTest(
      'emits the initial todo list when TodoListSubscriptionRequested() is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoListSubscriptionRequested()),
      expect: () => [
        const TodoListLoading(),
        TodoListSuccess(todoList: [todo]),
      ],
    );
  });

  group('TodoListTodoCompletionToggled', () {
    blocTest(
      'emits the todo list state with updated completion state when TodoListTodoCompletionToggled(<todo>, <completion>) is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc.add(
        TodoListTodoCompletionToggled(todo: todo, completion: true),
      ),
      expect: () => [
        const TodoListLoading(),
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(
          todoList: [todo.copyWith(completion: true, completionDate: now)],
        ),
      ],
    );
    blocTest(
      'emits the todo list state with updated completion state when TodoListTodoCompletionToggled(<todo>, <completion>) is called (not exists)',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc.add(
        TodoListTodoCompletionToggled(
            todo: todo.copyWith(id: 99), completion: true),
      ),
      expect: () => [
        const TodoListLoading(),
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
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc.add(TodoListTodoSelectedToggled(
        todo: todo.copyWith(),
        selected: true,
      )),
      expect: () => [
        const TodoListLoading(),
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(
          todoList: [todo.copyWith(selected: true)],
        ),
      ],
    );
  });

  group('TodoListSelectedAll', () {
    blocTest(
      'emits the todo list state with updated selected state when TodoListSelectedAll() is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc.add(const TodoListSelectedAll()),
      expect: () => [
        const TodoListLoading(),
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(
          todoList: [todo.copyWith(selected: true)],
        ),
      ],
    );
  });

  group('TodoListUnselectedAll', () {
    blocTest(
      'emits the todo list state with updated selected state when TodoListUnselectedAll() is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc
        ..add(const TodoListSelectedAll())
        ..add(const TodoListUnselectedAll()),
      expect: () => [
        const TodoListLoading(),
        TodoListSuccess(todoList: [todo]),
        TodoListSuccess(
          todoList: [todo.copyWith(selected: true)],
        ),
        TodoListSuccess(
          todoList: [todo.copyWith(selected: false)],
        ),
      ],
    );
  });

  group('TodoListOrderChanged', () {
    blocTest(
      'emits the todo list state with updated order property when TodoListOrderChanged(<order>) is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      ),
      act: (bloc) =>
          bloc.add(const TodoListOrderChanged(order: TodoListOrder.descending)),
      expect: () => [
        const TodoListSuccess(
          order: TodoListOrder.descending,
        ),
      ],
    );
  });

  group('TodoListFilterChanged', () {
    blocTest(
      'emits the todo list state with updated filter property when TodoListFilterChanged(<filter>) is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(
          const TodoListFilterChanged(filter: TodoListFilter.completedOnly)),
      expect: () => [
        const TodoListSuccess(
          filter: TodoListFilter.completedOnly,
        ),
      ],
    );
  });

  group('TodoListGroupByChanged', () {
    blocTest(
      'emits the todo list state with updated group property when TodoListGroupByChanged(<group>) is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc
          .add(const TodoListGroupByChanged(group: TodoListGroupBy.context)),
      expect: () => [
        const TodoListSuccess(
          group: TodoListGroupBy.context,
        ),
      ],
    );
  });
}
