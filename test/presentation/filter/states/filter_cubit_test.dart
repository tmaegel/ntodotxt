import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/database.dart';
import 'package:ntodotxt/data/filter/filter_controller.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseController controller;
  late SettingRepository settingRepository;
  late FilterRepository filterRepository;

  setUp(() {
    controller = DatabaseController(inMemoryDatabasePath);
    settingRepository = SettingRepository(
      SettingController(controller),
    );
    filterRepository = FilterRepository(
      FilterController(controller),
    );
  });

  group('saved filter', () {
    group('initial', () {
      test('initial filter', () async {
        const Filter origin = Filter(name: 'default');
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              name: 'default',
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: origin,
          ),
        );
      });
    });

    group('create filter', () {
      test('non-existing', () async {
        const Filter origin = Filter(name: 'default');
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        await cubit.create(origin.copyWith(name: 'created'));

        await expectLater(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              id: 1,
              name: 'created',
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: const Filter(
              id: 1,
              name: 'created',
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
          ),
        );
      });
    });

    // @todo: Fix testcase
    // group('update filter', () {
    //   test('existing', () async {
    //     const Filter origin = Filter(name: 'default');
    //     final FilterCubit cubit = FilterCubit(
    //       settingRepository: settingRepository,
    //       filterRepository: filterRepository,
    //       filter: origin,
    //     );
    //     await cubit.create(origin);
    //     await cubit.update(origin.copyWith(id: 1, name: 'updated'));
    //
    //     await expectLater(
    //       cubit.state,
    //       FilterSaved(
    //         filter: const Filter(
    //           id: 1,
    //           name: 'updated',
    //           order: ListOrder.ascending,
    //           filter: ListFilter.all,
    //           group: ListGroup.none,
    //         ),
    //         origin: const Filter(
    //           id: 1,
    //           name: 'updated',
    //           order: ListOrder.ascending,
    //           filter: ListFilter.all,
    //           group: ListGroup.none,
    //         ),
    //       ),
    //     );
    //   });
    // });

    group('delete filter', () {
      test('existing', () async {
        const Filter origin = Filter(name: 'default');
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        await cubit.create(origin);
        await cubit.delete(origin.copyWith(id: 1, name: 'deleted'));

        await expectLater(
          cubit.state,
          FilterSaved(
            filter: const Filter(),
            origin: const Filter(),
          ),
        );
      });
    });

    group('update attributes', () {
      test('name', () async {
        const Filter origin = Filter(name: 'default');
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updateName('update');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(name: 'update'),
            origin: origin,
          ),
        );
      });
      test('order', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updateOrder(ListOrder.descending);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(order: ListOrder.descending),
            origin: origin,
          ),
        );
      });
      test('filter', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updateFilter(ListFilter.completedOnly);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(filter: ListFilter.completedOnly),
            origin: origin,
          ),
        );
      });
      test('group', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updateGroup(ListGroup.priority);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(group: ListGroup.priority),
            origin: origin,
          ),
        );
      });
    });

    group('priority', () {
      test('add', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.addPriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(priorities: {Priority.A}),
            origin: origin,
          ),
        );
      });
      test('add (already exists)', () async {
        const Filter origin = Filter(priorities: {Priority.A});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.addPriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(priorities: {Priority.A}),
            origin: origin,
          ),
        );
      });
      test('remove', () async {
        const Filter origin = Filter(priorities: {Priority.A});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.removePriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(priorities: {}),
            origin: origin,
          ),
        );
      });
      test('remove (not exists)', () async {
        const Filter origin = Filter(priorities: {Priority.A});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.removePriority(Priority.B);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(priorities: {Priority.A}),
            origin: origin,
          ),
        );
      });
      test('update multiple', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updatePriorities({Priority.A, Priority.B});

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(
              priorities: {Priority.A, Priority.B},
            ),
            origin: origin,
          ),
        );
      });
    });

    group('project', () {
      test('add', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.addProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(projects: {'project1'}),
            origin: origin,
          ),
        );
      });
      test('add (already exists)', () async {
        const Filter origin = Filter(projects: {'project1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.addProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(projects: {'project1'}),
            origin: origin,
          ),
        );
      });
      test('remove', () async {
        const Filter origin = Filter(projects: {'project1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.removeProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(projects: {}),
            origin: origin,
          ),
        );
      });
      test('remove (not exists)', () async {
        const Filter origin = Filter(projects: {'project1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.removeProject('project2');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(projects: {'project1'}),
            origin: origin,
          ),
        );
      });
      test('update multiple', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updateProjects({'project1', 'project2'});

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(projects: {'project1', 'project2'}),
            origin: origin,
          ),
        );
      });
    });

    group('context', () {
      test('add', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.addContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(contexts: {'context1'}),
            origin: origin,
          ),
        );
      });
      test('add (already exists)', () async {
        const Filter origin = Filter(contexts: {'context1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.addContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(contexts: {'context1'}),
            origin: origin,
          ),
        );
      });
      test('remove', () async {
        const Filter origin = Filter(contexts: {'context1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.removeContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(contexts: {}),
            origin: origin,
          ),
        );
      });
      test('remove (not exists)', () async {
        const Filter origin = Filter(contexts: {'context1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.removeContext('context2');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(contexts: {'context1'}),
            origin: origin,
          ),
        );
      });
      test('update multiple', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        cubit.updateContexts({'context1', 'context2'});

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter().copyWith(contexts: {'context1', 'context2'}),
            origin: origin,
          ),
        );
      });
    });
  });

  group('default filter', () {
    group('update', () {
      test('order', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        await cubit.updateDefaultOrder(ListOrder.descending);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter().copyWith(order: ListOrder.descending),
            origin: const Filter().copyWith(order: ListOrder.descending),
          ),
        );
      });
      test('filter', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        await cubit.updateDefaultFilter(ListFilter.completedOnly);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter().copyWith(filter: ListFilter.completedOnly),
            origin: const Filter().copyWith(filter: ListFilter.completedOnly),
          ),
        );
      });
      test('group', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        await cubit.updateDefaultGroup(ListGroup.priority);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter().copyWith(group: ListGroup.priority),
            origin: const Filter().copyWith(group: ListGroup.priority),
          ),
        );
      });
    });

    group('reset', () {
      test('full', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: settingRepository,
          filterRepository: filterRepository,
          filter: origin,
        );
        await cubit.updateDefaultOrder(ListOrder.descending);
        await cubit.updateDefaultFilter(ListFilter.completedOnly);
        await cubit.updateDefaultGroup(ListGroup.priority);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              order: ListOrder.descending,
              filter: ListFilter.completedOnly,
              group: ListGroup.priority,
            ),
            origin: const Filter(
              order: ListOrder.descending,
              filter: ListFilter.completedOnly,
              group: ListGroup.priority,
            ),
          ),
        );

        await cubit.resetToDefaults();
        expect(
          cubit.state,
          FilterSaved(
            filter: origin,
            origin: origin,
          ),
        );
      });
    });
  });
}
