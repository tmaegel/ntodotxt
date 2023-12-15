import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initial', () {
    test('initial filter', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
          ),
        ),
      );
    });
  });

  group('update', () {
    test('name', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.updateName('update');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'update',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
          ),
        ),
      );
    });
    test('order', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.updateOrder(ListOrder.descending);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.descending,
            filter: ListFilter.all,
            group: ListGroup.none,
          ),
        ),
      );
    });
    test('filter', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.updateFilter(ListFilter.completedOnly);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.completedOnly,
            group: ListGroup.none,
          ),
        ),
      );
    });
    test('filter', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.updateGroup(ListGroup.priority);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.priority,
          ),
        ),
      );
    });
  });

  group('priority', () {
    test('add', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.addPriority(Priority.A);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            priorities: {Priority.A},
          ),
        ),
      );
    });
    test('add (already exists)', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter', priorities: {Priority.A}),
      );
      cubit.addPriority(Priority.A);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            priorities: {Priority.A},
          ),
        ),
      );
    });
    test('remove', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter', priorities: {Priority.A}),
      );
      cubit.removePriority(Priority.A);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            priorities: {},
          ),
        ),
      );
    });
    test('remove (not exists)', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.removePriority(Priority.A);

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            priorities: {},
          ),
        ),
      );
    });
  });

  group('project', () {
    test('add', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.addProject('project1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            projects: {'project1'},
          ),
        ),
      );
    });
    test('add (already exists)', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter', projects: {'project1'}),
      );
      cubit.addProject('project1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            projects: {'project1'},
          ),
        ),
      );
    });
    test('remove', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter', projects: {'project1'}),
      );
      cubit.removeProject('project1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            projects: {},
          ),
        ),
      );
    });
    test('remove (not exists)', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.removeProject('project1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            projects: {},
          ),
        ),
      );
    });
  });

  group('context', () {
    test('add', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.addContext('context1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            contexts: {'context1'},
          ),
        ),
      );
    });
    test('add (already exists)', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter', contexts: {'context1'}),
      );
      cubit.addContext('context1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            contexts: {'context1'},
          ),
        ),
      );
    });
    test('remove', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter', contexts: {'context1'}),
      );
      cubit.removeContext('context1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            contexts: {},
          ),
        ),
      );
    });
    test('remove (not exists)', () async {
      final FilterCubit cubit = FilterCubit(
        filter: const Filter(name: 'filter'),
      );
      cubit.removeContext('context1');

      expect(
        cubit.state,
        const FilterSuccess(
          filter: Filter(
            name: 'filter',
            order: ListOrder.ascending,
            filter: ListFilter.all,
            group: ListGroup.none,
            contexts: {},
          ),
        ),
      );
    });
  });
}
