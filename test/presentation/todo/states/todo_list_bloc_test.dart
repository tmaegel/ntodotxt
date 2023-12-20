import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalTodoListApi api;
  late TodoListRepository repository;
  late MemoryFileSystem fs;
  late File file;
  late Todo todo;

  setUp(() async {
    fs = MemoryFileSystem();
    file = fs.file('todo.test');
    await file.create();
  });

  group('Initial', () {
    setUp(() async {
      await file.writeAsString('', flush: true); // Empty file
      api = LocalTodoListApi(todoFile: file);
      repository = TodoListRepository(api);
    });

    test('initial state', () {
      final TodoListBloc todoListBloc = TodoListBloc(repository: repository);
      expect(todoListBloc.state is TodoListInitial, true);
      expect(todoListBloc.state.todoList, []);
    });
  });

  group('TodoListSubscriptionRequested', () {
    setUp(() async {
      todo = Todo(description: 'Write some tests');
      await file.writeAsString(todo.toString(), flush: true);
      api = LocalTodoListApi(todoFile: file);
      repository = TodoListRepository(api);
    });

    test('initial state', () async {
      final TodoListBloc bloc = TodoListBloc(repository: repository);
      bloc.add(const TodoListSubscriptionRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          TodoListSuccess(todoList: [todo]),
        ]),
      );
    });
  });

  group('TodoListTodoSubmitted', () {
    group('completion', () {
      setUp(() async {
        todo = Todo(
          completion: false,
          description: 'Write some tests',
        );
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(completion: true),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [todo.copyWith(completion: true)],
            ),
          ),
        );
      });
    });

    group('priority', () {
      setUp(() async {
        todo = Todo(
          priority: Priority.A,
          description: 'Write some tests',
        );
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(priority: Priority.B),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [todo.copyWith(priority: Priority.B)],
            ),
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(priority: Priority.none),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [todo.copyWith(priority: Priority.none)],
            ),
          ),
        );
      });
    });

    group('description', () {
      setUp(() async {
        todo = Todo(description: 'Write some tests');
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(description: 'Write more tests'),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [todo.copyWith(description: 'Write more tests')],
            ),
          ),
        );
      });
    });

    group('projects', () {
      setUp(() async {
        todo =
            Todo(projects: const {'project1'}, description: 'Write some tests');
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(projects: const {'project1', 'project2'}),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [
                todo.copyWith(
                  description: 'Write some tests',
                  projects: const {'project1', 'project2'},
                )
              ],
            ),
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(todo: todo.copyWith(projects: const {})));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [
                todo.copyWith(
                  description: 'Write some tests',
                  projects: const {},
                )
              ],
            ),
          ),
        );
      });
    });

    group('contexts', () {
      setUp(() async {
        todo =
            Todo(contexts: const {'context1'}, description: 'Write some tests');
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(contexts: const {'context1', 'context2'}),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [
                todo.copyWith(
                  description: 'Write some tests',
                  contexts: const {'context1', 'context2'},
                )
              ],
            ),
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(todo: todo.copyWith(contexts: const {})));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [
                todo.copyWith(
                  description: 'Write some tests',
                  contexts: const {},
                )
              ],
            ),
          ),
        );
      });
    });

    group('key values', () {
      setUp(() async {
        todo = Todo(
            keyValues: const {'foo': 'bar'}, description: 'Write some tests');
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(keyValues: const {'foo': 'bar', 'key': 'val'}),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [
                todo.copyWith(
                  description: 'Write some tests',
                  keyValues: const {'foo': 'bar', 'key': 'val'},
                )
              ],
            ),
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoSubmitted(
            todo: todo.copyWith(keyValues: const {}),
          ));

        await expectLater(
          bloc.stream,
          emitsThrough(
            TodoListSuccess(
              todoList: [
                todo.copyWith(
                  description: 'Write some tests',
                  keyValues: {},
                )
              ],
            ),
          ),
        );
      });
    });
  });

  group('TodoListTodoDeleted', () {});

  group('TodoListTodoCompletionToggled', () {
    group('toggle to completed', () {
      setUp(() async {
        todo = Todo(description: 'Write some tests');
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoCompletionToggled(todo: todo, completion: true));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // Initial & TodoListSubscriptionRequested
            TodoListSuccess(todoList: [todo]),
            // TodoListTodoCompletionToggled start
            TodoListLoading(todoList: [todo]),
            // saveTodo() within TodoListTodoCompletionToggled
            TodoListLoading(
              todoList: [todo.copyWith(completion: true)],
            ),
            // TodoListTodoCompletionToggled finished
            TodoListSuccess(
              todoList: [todo.copyWith(completion: true)],
            ),
          ]),
        );
      });
      test('set (not exists)', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        Todo todo2 =
            Todo(description: 'Write more tests'); // Generate new uuid (id)
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoCompletionToggled(todo: todo2, completion: true));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // Initial & TodoListSubscriptionRequested
            TodoListSuccess(todoList: [todo]),
            // TodoListTodoCompletionToggled start
            TodoListLoading(todoList: [todo]),
            // saveTodo() within TodoListTodoCompletionToggled
            TodoListLoading(
              todoList: [todo, todo2.copyWith(completion: true)],
            ),
            // TodoListTodoCompletionToggled finished
            TodoListSuccess(
              todoList: [todo, todo2.copyWith(completion: true)],
            ),
          ]),
        );
      });
    });

    group('toggle to incompleted', () {
      setUp(() async {
        todo = Todo(completion: true, description: 'Write some tests');
        await file.writeAsString(todo.toString(), flush: true);
        api = LocalTodoListApi(todoFile: file);
        repository = TodoListRepository(api);
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoCompletionToggled(todo: todo, completion: false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // Initial & TodoListSubscriptionRequested
            TodoListSuccess(todoList: [todo]),
            // TodoListTodoCompletionToggled start
            TodoListLoading(todoList: [todo]),
            // saveTodo() within TodoListTodoCompletionToggled
            TodoListLoading(
              todoList: [todo.copyWith(completion: false)],
            ),
            // TodoListTodoCompletionToggled finished
            TodoListSuccess(
              todoList: [todo.copyWith(completion: false)],
            ),
          ]),
        );
      });
      test('unset (not exists)', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        Todo todo2 =
            Todo(description: 'Write more tests'); // Generate new uuid (id)
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(TodoListTodoCompletionToggled(todo: todo2, completion: false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            // Initial & TodoListSubscriptionRequested
            TodoListSuccess(todoList: [todo]),
            // TodoListTodoCompletionToggled start
            TodoListLoading(todoList: [todo]),
            // saveTodo() within TodoListTodoCompletionToggled
            TodoListLoading(
              todoList: [todo, todo2.copyWith(completion: false)],
            ),
            // TodoListTodoCompletionToggled finished
            TodoListSuccess(
              todoList: [todo, todo2.copyWith(completion: false)],
            ),
          ]),
        );
      });
    });
  });
}
