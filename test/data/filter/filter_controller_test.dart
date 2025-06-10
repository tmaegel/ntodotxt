import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/database.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart'
    show FilterController;
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/filter/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Init ffi loader if needed.
  sqfliteFfiInit();

  late DatabaseController controller;
  late FilterRepository repository;

  setUp(() async {
    controller = DatabaseController(inMemoryDatabasePath);
    repository = FilterRepository(FilterController(controller));
    await (await controller.database).delete('filters'); // Clear
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
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      await (await controller.database).insert('filters', model.toMap());
      expect(await repository.list(), [model]);
    });
  });

  group('get()', () {
    test('empty', () async {
      expect(await repository.get(id: 1), null);
    });
    test('filled', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      await (await controller.database).insert('filters', model.toMap());
      expect(await repository.get(id: 1), model.copyWith(id: 1));
    });
  });

  group('insert()', () {
    test('empty', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      expect(await repository.insert(model) > 0, isTrue);
    });
    test('filled', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      await (await controller.database).insert('filters', model.toMap());
      expect(await repository.insert(model) > 0, isTrue);
    });
    test('ignore id', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
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
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
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
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      Filter model2 = model1.copyWith(name: 'updated name');
      await (await controller.database).insert('filters', model1.toMap());
      expect(await repository.update(model2) > 0, isTrue);
    });
    test('missing id', () async {
      Filter model = const Filter(
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
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
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      expect(await repository.delete(id: model.id!), 0);
    });
    test('filled', () async {
      Filter model = const Filter(
        id: 1,
        name: 'example filter',
        priorities: {Priority.A, Priority.B},
        projects: {'project1', 'project2'},
        contexts: {'context1', 'context2'},
        order: ListOrder.ascending,
        filter: ListFilter.all,
        group: ListGroup.priority,
      );
      await (await controller.database).insert('filters', model.toMap());
      expect(await repository.delete(id: model.id!) > 0, isTrue);
    });
  });
}
