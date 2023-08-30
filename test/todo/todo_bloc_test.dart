import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

void main() {
  late TodoListRepository todoListRepository;
  late Todo todo;
  late DateTime now;

  setUp(() {
    const String todoStr =
        '(A) 2022-11-01 Write some tests +project1 @context1 foo:bar';
    final List<String> rawTodoList = [todoStr];
    final LocalStorageTodoListApi todoListApi =
        LocalStorageTodoListApi.fromList(rawTodoList);
    todoListRepository = TodoListRepository(todoListApi: todoListApi);
    todo = Todo.fromString(id: 0, todoStr: todoStr);
    now = DateTime.now();
  });

  group('Initial', () {
    test("initial state", () {
      final TodoBloc todoBloc = TodoBloc(
        todo: todo,
        todoListRepository: todoListRepository,
      );
      expect(todoBloc.state.status, TodoStatus.initial);
      expect(todoBloc.state.todo, todo);
    });
  });

  group('TodoCompletionToggled', () {
    blocTest(
      'emits a completed todo with completion date when TodoCompletionToggled(true) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(completion: false),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoCompletionToggled(true)),
      expect: () => [
        TodoState(
          todo: todo.copyWith(completion: true, completionDate: now),
        ),
      ],
    );
    blocTest(
      'emits a incompleted todo with unsetted completion date when TodoCompletionToggled(false) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(completion: true, completionDate: now),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoCompletionToggled(false)),
      expect: () => [
        TodoState(
          todo: todo.copyWith(completion: false),
        ),
      ],
    );
  });

  group('TodoDescriptionChanged', () {
    blocTest(
      'emits a todo with updated description when TodoDescriptionChanged(<description>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoDescriptionChanged('Write more tests')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(description: 'Write more tests'),
        ),
      ],
    );
  });

  group('TodoPriorityAdded', () {
    blocTest(
      'emits a todo updated priority when TodoPriorityAdded(<priority>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoPriorityAdded('B')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(priority: 'B'),
        ),
      ],
    );
  });

  group('TodoPriorityRemoved', () {
    blocTest(
      'emits a todo removed priority when TodoPriorityRemoved() is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoPriorityRemoved()),
      expect: () => [
        TodoState(
          todo: todo.copyWith(priority: null, unsetPriority: true),
        ),
      ],
    );
  });

  group('TodoProjectAdded', () {
    blocTest(
      'emits a todo with updated projects when TodoProjectAdded(<project>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoProjectAdded('project2')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(projects: ['project1', 'project2']),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectAdded(<project>) is called (duplication)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoProjectAdded('project1')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(projects: ['project1']),
        ),
      ],
    );
  });

  group('TodoProjectRemoved', () {
    blocTest(
      'emits a todo with updated projects when TodoProjectRemoved(<project>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoProjectRemoved('project1')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(projects: []),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated projects when TodoProjectRemoved(<project>) is called (not exists)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoProjectRemoved('project2')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(projects: ['project1']),
        ),
      ],
    );
  });

  group('TodoContextAdded', () {
    blocTest(
      'emits a todo with updated contexts when TodoContextAdded(<constext>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoContextAdded('context2')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(contexts: ['context1', 'context2']),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextAdded(<context>) is called (duplication)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoContextAdded('context1')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(contexts: ['context1']),
        ),
      ],
    );
  });

  group('TodoContextRemoved', () {
    blocTest(
      'emits a todo with updated contexts when TodoContextRemoved(<constext>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoContextRemoved('context1')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(contexts: []),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated contexts when TodoContextRemoved(<context>) is called (not exists)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoContextRemoved('context2')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(contexts: ['context1']),
        ),
      ],
    );
  });

  group('TodoKeyValueAdded', () {
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('key:val')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(keyValues: {'foo': 'bar', 'key': 'val'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (invalid format)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('key_val')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (duplication)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('foo:bar')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueAdded(<key:val>) is called (duplication, update value)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoKeyValueAdded('foo:new')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(keyValues: {'foo': 'new'}),
        ),
      ],
    );
  });

  group('TodoKeyValueRemoved', () {
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueRemoved(<key:val>) is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoKeyValueRemoved('foo:bar')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(keyValues: {}),
        ),
      ],
    );
    blocTest(
      'emits a todo with updated key-values when TodoKeyValueRemoved(<key:val>) is called (not exits)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(const TodoKeyValueRemoved('key:val')),
      expect: () => [
        TodoState(
          todo: todo.copyWith(keyValues: {'foo': 'bar'}),
        ),
      ],
    );
  });

  group('TodoSubmitted', () {
    blocTest(
      'emits the submitted todo when TodoSubmitted() is called (update)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(TodoSubmitted(todo.copyWith(id: 0))),
      expect: () => [
        TodoState(
          todo: todo.copyWith(id: 0),
        ),
      ],
    );
    blocTest(
      'emits the submitted todo when TodoSubmitted() is called (create)',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(TodoSubmitted(todo.copyWith(unsetId: true))),
      expect: () => [
        TodoState(
          todo: todo.copyWith(id: 1), // Created todo has new id
        ),
      ],
    );
  });

  group('TodoDeleted', () {
    blocTest(
      'emits nothing when TodoDeleted() is called',
      build: () => TodoBloc(
        todo: todo.copyWith(),
        todoListRepository: todoListRepository,
      ),
      act: (bloc) => bloc.add(TodoDeleted(todo.copyWith())),
      expect: () => [],
    );
  });
}
