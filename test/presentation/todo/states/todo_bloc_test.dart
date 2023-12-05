import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Todo todo;

  setUp(() async {});

  group('Initial', () {
    test('initial state', () {
      todo = Todo(description: 'Write some tests');
      final TodoBloc todoBloc = TodoBloc(todo: todo);
      expect(todoBloc.state, TodoInitial(todo: todo));
    });
  });

  group('completion', () {
    group('TodoCompletionToggled', () {
      test('set', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoCompletionToggled(true));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                completion: true,
                description: todo.description,
              ),
            ),
          ]),
        );
      });
      test('unset', () async {
        todo = Todo(completion: true, description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoCompletionToggled(false));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
              ),
            ),
          ]),
        );
      });
    });
  });

  group('description', () {
    group('TodoDescriptionChanged', () {
      test('set', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoDescriptionChanged('Write more tests'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: 'Write more tests',
              ),
            ),
          ]),
        );
      });
    });
  });

  group('priority', () {
    group('TodoPriorityAdded', () {
      test('set', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoPriorityAdded('A'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                priority: 'A',
                description: todo.description,
              ),
            )
          ]),
        );
      });
    });
    group('TodoPriorityRemoved', () {
      test('unset', () async {
        todo = Todo(priority: 'A', description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoPriorityRemoved());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
              ),
            )
          ]),
        );
      });
    });
  });

  group('projects', () {
    group('TodoProjectsAdded', () {
      test('add initial', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project1']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1'},
              ),
            )
          ]),
        );
      });
      test('add additional', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1', 'project2'},
              ),
            )
          ]),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project 2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid project tag: project 2',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {},
              ),
            )
          ]),
        );
      });
      test('duplication', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project1']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1'},
              ),
            )
          ]),
        );
      });
      test('duplication / case sensitive', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['Project1']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1'},
              ),
            )
          ]),
        );
      });
      test('multiple entries', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project1', 'project2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1', 'project2'},
              ),
            )
          ]),
        );
      });
      test('multiple entries / invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project1', 'project 2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid project tag: project 2',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {},
              ),
            )
          ]),
        );
      });
      test('multiple entries / duplication', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['project1', 'project2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1', 'project2'},
              ),
            )
          ]),
        );
      });
      test('multiple entries / duplication / case sensitive', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectsAdded(['Project1', 'Project2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1', 'project2'},
              ),
            )
          ]),
        );
      });
    });
    group('TodoProjectRemoved', () {
      test('remove', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectRemoved('project1'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {},
              ),
            )
          ]),
        );
      });
      test('invalid format', () async {
        todo = Todo(
          description: 'Write some tests',
          projects: const {'project1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectRemoved('project 1'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {'project1'},
              ),
            )
          ]),
        );
      });
      test('not exists', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoProjectRemoved('project1'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                projects: const {},
              ),
            )
          ]),
        );
      });
    });
  });

  group('contexts', () {
    group('TodoContextsAdded', () {
      test('add initial', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context1']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1'},
              ),
            )
          ]),
        );
      });
      test('add additional', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1', 'context2'},
              ),
            )
          ]),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context 2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid context tag: context 2',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {},
              ),
            )
          ]),
        );
      });
      test('duplication', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context1']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1'},
              ),
            )
          ]),
        );
      });
      test('duplication / case sensitive', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['Context1']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1'},
              ),
            )
          ]),
        );
      });
      test('multiple entries', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context1', 'context2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1', 'context2'},
              ),
            )
          ]),
        );
      });
      test('multiple entries / invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context1', 'context 2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid context tag: context 2',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {},
              ),
            )
          ]),
        );
      });
      test('multiple entries / duplication', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['context1', 'context2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1', 'context2'},
              ),
            )
          ]),
        );
      });
      test('multiple entries / duplication / case sensitive', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextsAdded(['Context1', 'Context2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1', 'context2'},
              ),
            )
          ]),
        );
      });
    });
    group('TodoContextRemoved', () {
      test('remove', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextRemoved('context1'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {},
              ),
            )
          ]),
        );
      });
      test('invalid format', () async {
        todo = Todo(
          description: 'Write some tests',
          contexts: const {'context1'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextRemoved('context 1'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {'context1'},
              ),
            )
          ]),
        );
      });
      test('not exists', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoContextRemoved('context2'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                contexts: const {},
              ),
            )
          ]),
        );
      });
    });
  });

  group('key values', () {
    group('TodoKeyValuesAdded', () {
      test('add initial', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key:val']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'key': 'val'},
              ),
            )
          ]),
        );
      });
      test('add additional', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key:val']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'bar', 'key': 'val'},
              ),
            )
          ]),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key_val']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid key value tag: key_val',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {},
              ),
            )
          ]),
        );
      });
      test('duplication', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['foo:bar']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'bar'},
              ),
            ),
          ]),
        );
      });
      test('duplication / case sensitive', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['Foo:bar']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'bar'},
              ),
            ),
          ]),
        );
      });
      test('duplication / update value', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['foo:new']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'new'},
              ),
            ),
          ]),
        );
      });
      test('multiple entries', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key1:val1', 'key2:val2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'key1': 'val1', 'key2': 'val2'},
              ),
            ),
          ]),
        );
      });
      test('multiple entries / invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key1:val1', 'key2_val2']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid key value tag: key2_val2',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {},
              ),
            ),
          ]),
        );
      });
      test('multiple entries / duplication', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key1:val1', 'foo:bar']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'bar', 'key1': 'val1'},
              ),
            ),
          ]),
        );
      });
      test('multiple entries / duplication / case sensitive', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['Key1:val1', 'Foo:bar']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'bar', 'key1': 'val1'},
              ),
            ),
          ]),
        );
      });
      test('multiple entries / update value', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValuesAdded(['key1:val1', 'foo:new']));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'new', 'key1': 'val1'},
              ),
            ),
          ]),
        );
      });
    });
    group('TodoKeyValueRemoved', () {
      test('remove', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValueRemoved('foo:bar'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {},
              ),
            ),
          ]),
        );
      });
      test('invalid format', () async {
        todo = Todo(
          description: 'Write some tests',
          keyValues: const {'foo': 'bar'},
        );
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValueRemoved('key_val'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoError(
              message: 'Invalid key value tag: key_val',
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {'foo': 'bar'},
              ),
            ),
          ]),
        );
      });
      test('not exits', () async {
        todo = Todo(description: 'Write some tests');
        final TodoBloc bloc = TodoBloc(todo: todo);
        bloc.add(const TodoKeyValueRemoved('key:val'));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            TodoChange(
              todo: Todo(
                id: todo.id,
                description: todo.description,
                keyValues: const {},
              ),
            ),
          ]),
        );
      });
    });
  });
}
