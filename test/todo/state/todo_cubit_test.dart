import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/todo/model/todo_model.dart';
import 'package:ntodotxt/todo/state/todo_cubit.dart';
import 'package:ntodotxt/todo/state/todo_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Todo todo;

  setUp(() async {});

  group('initial', () {
    test('initial state', () {
      todo = Todo(description: 'Write some tests');
      final TodoCubit todoBloc = TodoCubit(todo: todo);
      expect(todoBloc.state, TodoSuccess(todo: todo));
    });
  });

  group('completion', () {
    test('set', () async {
      todo = Todo(
        completion: false,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.toggleCompletion(completion: true);

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            completion: true,
            description: todo.description,
          ),
        ),
      );
    });
    test('unset', () async {
      todo = Todo(
        completion: true,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.toggleCompletion(completion: false);

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            description: todo.description,
          ),
        ),
      );
    });
    test('toggle', () async {
      todo = Todo(
        completion: false,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.toggleCompletion();

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            completion: true,
            description: todo.description,
          ),
        ),
      );
    });
  });

  group('description', () {
    test('set', () async {
      todo = Todo(description: 'Write some tests');
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.updateDescription('Write more tests');

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            description: 'Write more tests',
          ),
        ),
      );
    });
  });

  group('priority', () {
    test('set', () async {
      todo = Todo(
        priority: Priority.none,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.setPriority(Priority.A);

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            priority: Priority.A,
            description: todo.description,
          ),
        ),
      );
    });
    test('update', () async {
      todo = Todo(
        priority: Priority.A,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.setPriority(Priority.B);

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            priority: Priority.B,
            description: todo.description,
          ),
        ),
      );
    });
    test('unset', () async {
      todo = Todo(
        priority: Priority.A,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.unsetPriority();

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            priority: Priority.none,
            description: todo.description,
          ),
        ),
      );
    });
    test('unset (already unset)', () async {
      todo = Todo(
        priority: Priority.none,
        description: 'Write some tests',
      );
      final TodoCubit bloc = TodoCubit(todo: todo);
      bloc.unsetPriority();

      expect(
        bloc.state,
        TodoSuccess(
          todo: Todo(
            priority: Priority.none,
            description: todo.description,
          ),
        ),
      );
    });
  });

  group('projects', () {
    group('add', () {
      test('initial', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addProject('project1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1',
            ),
          ),
        );
      });
      test('additional', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addProject('project2');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1 +project2',
            ),
          ),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addProject('project 2');

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid project tag: project 2',
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('duplication', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addProject('project1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1',
            ),
          ),
        );
      });
      test('no duplication / case insensitive', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addProject('Project1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1 +Project1',
            ),
          ),
        );
      });
    });
    group('update', () {
      test('multiple entries', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateProjects({'project1', 'project2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1 +project2',
            ),
          ),
        );
      });
      test('multiple entries (add & remove)', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateProjects({'project2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project2',
            ),
          ),
        );
      });
      test('multiple entries / invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateProjects({'project1', 'project 2'});

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid project tag: project 2',
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('multiple entries / duplication', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateProjects({'project1', 'project2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1 +project2',
            ),
          ),
        );
      });
      test('multiple entries / no duplication / case insensitive', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateProjects({'project1', 'Project1', 'Project2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests +project1 +Project1 +Project2',
            ),
          ),
        );
      });
    });
    group('remove', () {
      test('initial', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeProject('project1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests +project1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeProject('project 1');

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid project tag: project 1',
            todo: Todo(
              description: 'Write some tests +project1',
            ),
          ),
        );
      });
      test('not exists', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeProject('project1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
    });
  });

  group('contexts', () {
    group('add', () {
      test('initial', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addContext('context1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1',
            ),
          ),
        );
      });
      test('additional', () async {
        todo = Todo(description: 'Write some tests @context1 @context2');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addContext('context2');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1 @context2',
            ),
          ),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addContext('context 2');

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid context tag: context 2',
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('duplication', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addContext('context1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1',
            ),
          ),
        );
      });
      test('no duplication / case insensitive', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addContext('Context1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1 @Context1',
            ),
          ),
        );
      });
    });
    group('update', () {
      test('multiple entries', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateContexts({'context1', 'context2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1 @context2',
            ),
          ),
        );
      });
      test('multiple entries (add & remove)', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateContexts({'context2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context2',
            ),
          ),
        );
      });
      test('multiple entries / invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateContexts({'context1', 'context 2'});

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid context tag: context 2',
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('multiple entries / duplication', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateContexts({'context1', 'context2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1 @context2',
            ),
          ),
        );
      });
      test('multiple entries / no duplication / case insensitive', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateContexts({'context1', 'Context1', 'Context2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests @context1 @Context1 @Context2',
            ),
          ),
        );
      });
    });
    group('remove', () {
      test('initial', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeContext('context1');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests @context1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeContext('context 1');

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid context tag: context 1',
            todo: Todo(
              description: 'Write some tests @context1',
            ),
          ),
        );
      });
      test('not exists', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeContext('context2');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
    });
  });

  group('key values', () {
    group('add', () {
      test('initial', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addKeyValue('key:val');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests key:val',
            ),
          ),
        );
      });
      test('additional', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addKeyValue('key:val');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:bar key:val',
            ),
          ),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addKeyValue('key_val');

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid key value tag: key_val',
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('duplication', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addKeyValue('foo:bar');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:bar',
            ),
          ),
        );
      });
      test('no duplication / case insensitive', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addKeyValue('Foo:bar');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:bar Foo:bar',
            ),
          ),
        );
      });
      test('duplication / update value', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.addKeyValue('foo:new');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:new',
            ),
          ),
        );
      });
    });
    group('update', () {
      test('multiple entries', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateKeyValues({'key1:val1', 'key2:val2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests key1:val1 key2:val2',
            ),
          ),
        );
      });
      test('multiple entries (add & remove)', () async {
        todo = Todo(description: 'Write some tests key1:val1');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateKeyValues({'key2:val2'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests key2:val2',
            ),
          ),
        );
      });
      test('multiple entries / invalid format', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateKeyValues({'key1:val1', 'key2_val2'});

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid key value tag: key2_val2',
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('multiple entries / duplication', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateKeyValues({'key1:val1', 'foo:bar'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:bar key1:val1',
            ),
          ),
        );
      });
      test('multiple entries / no duplication / case insensitive', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateKeyValues({'foo:bar', 'Key1:val1', 'Foo:bar'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:bar Key1:val1 Foo:bar',
            ),
          ),
        );
      });
      test('multiple entries / update value', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.updateKeyValues({'key1:val1', 'foo:new'});

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests foo:new key1:val1',
            ),
          ),
        );
      });
    });
    group('remove', () {
      test('add', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeKeyValue('foo:bar');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
      test('invalid format', () async {
        todo = Todo(description: 'Write some tests foo:bar');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeKeyValue('key_val');

        expect(
          bloc.state,
          TodoError(
            message: 'Invalid key value tag: key_val',
            todo: Todo(
              description: 'Write some tests foo:bar',
            ),
          ),
        );
      });
      test('not exits', () async {
        todo = Todo(description: 'Write some tests');
        final TodoCubit bloc = TodoCubit(todo: todo);
        bloc.removeKeyValue('key:val');

        expect(
          bloc.state,
          TodoSuccess(
            todo: Todo(
              description: 'Write some tests',
            ),
          ),
        );
      });
    });
  });
}
