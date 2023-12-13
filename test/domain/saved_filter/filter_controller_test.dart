import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/saved_filter/filter_model.dart';
import 'package:ntodotxt/domain/saved_filter/filter_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart'
    show TodoListGroupBy, TodoListOrder;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Init ffi loader if needed.
  sqfliteFfiInit();

  late FilterController controller;
  late FilterRepository repository;

  setUp(() async {
    controller = FilterController(inMemoryDatabasePath);
    repository = FilterRepository(controller);
    await (await controller.database).delete('saved_filters'); // Clear
  });

  group('list()', () {
    test('empty', () async {
      expect(await repository.list(), isEmpty);
    });
    test('filled', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      await (await controller.database).insert('saved_filters', model.toMap());
      expect(await repository.list(), [model]);
    });
  });

  group('insert()', () {
    test('empty', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      expect(await repository.insert(model) > 0, isTrue);
    });
    test('filled', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      await (await controller.database).insert('saved_filters', model.toMap());
      expect(await repository.insert(model) > 0, isTrue);
    });
    test('ignore id', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      expect(await repository.insert(model) > 0, isTrue);
    });
  });

  group('update()', () {
    test('empty', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      expect(await repository.update(model), 0);
    });
    test('filled', () async {
      Filter model1 = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      Filter model2 = model1.copyWith(name: 'updated name');
      await (await controller.database).insert('saved_filters', model1.toMap());
      expect(await repository.update(model2) > 0, isTrue);
    });
    test('missing id', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      expect(await repository.update(model), 0);
    });
  });

  group('delete()', () {
    test('empty', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      expect(await repository.delete(model), 0);
    });
    test('filled', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      await (await controller.database).insert('saved_filters', model.toMap());
      expect(await repository.delete(model) > 0, isTrue);
    });
    test('missing id', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: TodoListOrder.ascending,
        groupBy: TodoListGroupBy.priority,
      );
      expect(await repository.delete(model), 0);
    });
  });
}
