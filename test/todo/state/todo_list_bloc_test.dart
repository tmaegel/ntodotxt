import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/todo/api/todo_list_api.dart';
import 'package:ntodotxt/todo/model/todo_model.dart';
import 'package:ntodotxt/todo/repository/todo_list_repository.dart';
import 'package:ntodotxt/todo/state/todo_list_bloc.dart';
import 'package:ntodotxt/todo/state/todo_list_event.dart';
import 'package:ntodotxt/todo/state/todo_list_state.dart';

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
  final LocalTodoListApi api = LocalTodoListApi.fromFile(localFile: todoFile);
  final TodoListRepository repository = TodoListRepository(api);

  return repository;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late File todoFile;
  late TodoListRepository repository;
  late Todo todo;

  setUp(() {
    todoFile = mockTodoListFile([]);
    repository = mockLocalTodoListRepository(todoFile);
  });

  group('Initial', () {
    test('initial state', () {
      final TodoListBloc todoListBloc = TodoListBloc(repository: repository);
      expect(todoListBloc.state is TodoListLoading, true);
      expect(todoListBloc.state.todoList, []);
    });
  });

  group('TodoListSynchronizationRequested', () {
    test('initial state', () async {
      final TodoListBloc bloc = TodoListBloc(repository: repository);
      bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(const TodoListSynchronizationRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder(
          [
            emitsThrough(
              const TodoListSuccess(todoList: []),
            ),
          ],
        ),
      );
    });
  });

  group('TodoListTodoSubmitted', () {
    group('completion', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          completion: false,
          description: 'Write some tests',
        );
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(completion: true),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(completion: true)],
                ),
              ),
            ],
          ),
        );
      });
    });

    group('priority', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          priority: Priority.A,
          description: 'Write some tests',
        );
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(priority: Priority.B),
            ),
          );

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
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(priority: Priority.none),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(priority: Priority.none)],
                ),
              ),
            ],
          ),
        );
      });
    });

    group('description', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          description: 'Write some tests',
        );
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(description: 'Write more tests'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(description: 'Write more tests')],
                ),
              ),
            ],
          ),
        );
      });
    });

    group('projects', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          description: 'Write some tests +project1',
        );
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(
                  description: 'Write some tests +project1 +project2'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [
                    todo.copyWith(
                      description: 'Write some tests +project1 +project2',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(description: 'Write some tests'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [
                    todo.copyWith(
                      description: 'Write some tests',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
    });

    group('contexts', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          description: 'Write some tests @context1',
        );
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(
                  description: 'Write some tests @context1 @context2'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [
                    todo.copyWith(
                      description: 'Write some tests @context1 @context2',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(description: 'Write some tests'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [
                    todo.copyWith(
                      description: 'Write some tests',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
    });

    group('key values', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          description: 'Write some tests foo:bar',
        );
      });
      test('set', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(
                  description: 'Write some tests foo:bar key:val'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [
                    todo.copyWith(
                      description: 'Write some tests foo:bar key:val',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
      test('unset', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoSubmitted(
              todo: todo.copyWith(description: 'Write some tests'),
            ),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [
                    todo.copyWith(
                      description: 'Write some tests',
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      });
    });
  });

  group('TodoListTodoDeleted', () {
    setUp(() async {
      todo = Todo(
        id: '1',
        description: 'Write some tests',
      );
    });
    test('delete existing', () async {
      final TodoListBloc bloc = TodoListBloc(repository: repository);
      bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(
          TodoListTodoSubmitted(
            todo: todo,
          ),
        )
        ..add(
          TodoListTodoDeleted(todo: todo),
        );

      await expectLater(
        bloc.stream,
        emitsInOrder(
          [
            emitsThrough(
              const TodoListSuccess(todoList: []),
            ),
          ],
        ),
      );
    });
    test('delete non-existing', () async {
      final TodoListBloc bloc = TodoListBloc(repository: repository);
      bloc
        ..add(const TodoListSubscriptionRequested())
        ..add(
          TodoListTodoSubmitted(
            todo: todo,
          ),
        )
        ..add(
          TodoListTodoDeleted(
            todo: Todo(
              id: '2',
              description: 'Write some tests!!!',
            ),
          ),
        );

      await expectLater(
        bloc.stream,
        emitsInOrder(
          [
            emitsThrough(
              TodoListSuccess(
                todoList: [
                  todo,
                ],
              ),
            ),
          ],
        ),
      );
    });
  });

  group('TodoListTodoCompletionToggled', () {
    group('toggle to completed', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          description: 'Write some tests',
        );
      });
      test('toggle existing', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoCompletionToggled(todo: todo, completion: true),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(completion: true)],
                ),
              ),
            ],
          ),
        );
      });
      test('toggle non-existing', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoCompletionToggled(todo: todo, completion: true),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(completion: true)],
                ),
              ),
            ],
          ),
        );
      });
    });

    group('toggle to incompleted', () {
      setUp(() async {
        todo = Todo(
          id: '1',
          completion: true,
          description: 'Write some tests',
        );
      });
      test('toggle existing', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoSubmitted(
              todo: todo,
            ),
          )
          ..add(
            TodoListTodoCompletionToggled(todo: todo, completion: false),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(completion: false)],
                ),
              ),
            ],
          ),
        );
      });
      test('toggle non-existing', () async {
        final TodoListBloc bloc = TodoListBloc(repository: repository);
        bloc
          ..add(const TodoListSubscriptionRequested())
          ..add(
            TodoListTodoCompletionToggled(todo: todo, completion: false),
          );

        await expectLater(
          bloc.stream,
          emitsInOrder(
            [
              emitsThrough(
                TodoListSuccess(
                  todoList: [todo.copyWith(completion: false)],
                ),
              ),
            ],
          ),
        );
      });
    });
  });
}
