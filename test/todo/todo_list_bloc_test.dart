import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
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
      expect(todoListBloc.state.status, TodoListStatus.initial);
      expect(todoListBloc.state.filter, TodoListFilter.all);
      expect(todoListBloc.state.order, TodoListOrder.ascending);
      expect(todoListBloc.state.groupBy, TodoListGroupBy.priority);
      expect(todoListBloc.state.todoList, []);
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
        TodoListState(
          todoList: [todo],
        ),
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
        TodoListState(
          todoList: [todo],
        ),
        TodoListState(
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
      errors: () => [isA<TodoNotFound>()],
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
        TodoListState(
          todoList: [todo],
        ),
        TodoListState(
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
        TodoListState(
          todoList: [todo],
        ),
        TodoListState(
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
        TodoListState(
          todoList: [todo],
        ),
        TodoListState(
          todoList: [todo.copyWith(selected: true)],
        ),
        TodoListState(
          todoList: [todo.copyWith(selected: false)],
        ),
      ],
    );
  });

  group('TodoListTodoDeleted', () {
    blocTest(
      'emits the todo list state with updated completion state when TodoListTodoDeleted(<todo>) is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc.add(
        TodoListTodoDeleted(todo: todo),
      ),
      expect: () => [
        TodoListState(todoList: [todo]),
        const TodoListState(todoList: []),
      ],
    );
    blocTest(
      'emits the todo list state with updated completion state when TodoListTodoDeleted(<todo>) is called (not exists)',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) => bloc.add(
        TodoListTodoDeleted(todo: todo.copyWith(id: 99)),
      ),
      expect: () => [
        TodoListState(todoList: [todo]),
      ],
    );
  });

  group('TodoListTodoSubmitted', () {
    blocTest(
      'emits the submitted todo when TodoListTodoSubmitted(<todo>) is called (update)',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) =>
          bloc.add(TodoListTodoSubmitted(todo: todo.copyWith(priority: 'B'))),
      expect: () => [
        TodoListState(todoList: [todo]),
        TodoListState(
          todoList: [todo.copyWith(priority: 'B')],
        ),
      ],
    );
    blocTest(
      'emits the submitted todo when TodoListTodoSubmitted(<todo>) is called (create)',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      )..add(const TodoListSubscriptionRequested()),
      act: (bloc) =>
          bloc.add(TodoListTodoSubmitted(todo: todo.copyWith(unsetId: true))),
      expect: () => [
        TodoListState(todoList: [todo]),
        TodoListState(
          todoList: [
            todo,
            todo.copyWith(id: 1),
          ],
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
        const TodoListState(
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
        const TodoListState(
          filter: TodoListFilter.completedOnly,
        ),
      ],
    );
  });

  group('TodoListGroupByChanged', () {
    blocTest(
      'emits the todo list state with updated groupBy property when TodoListGroupByChanged(<groupBy>) is called',
      build: () => TodoListBloc(
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc
          .add(const TodoListGroupByChanged(groupBy: TodoListGroupBy.context)),
      expect: () => [
        const TodoListState(
          groupBy: TodoListGroupBy.context,
        ),
      ],
    );
  });
}
