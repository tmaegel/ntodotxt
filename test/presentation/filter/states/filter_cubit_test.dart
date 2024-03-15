import 'package:flutter_test/flutter_test.dart';
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

  late String databasePath;

  setUp(() {
    databasePath = inMemoryDatabasePath;
  });

  group('saved filter', () {
    group('initial', () {
      test('initial filter', () async {
        const Filter origin = Filter(name: 'filter');
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              name: 'filter',
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: origin,
          ),
        );
      });
    });

    group('create (repository)', () {
      test('not exists', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
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

    group('update (repository)', () {});

    group('delete (repository)', () {});

    group('update', () {
      test('name', () async {
        const Filter origin = Filter(name: 'filter');
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateName('update');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              name: 'update',
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: origin,
          ),
        );
      });
      test('order', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateOrder(ListOrder.descending);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.descending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: origin,
          ),
        );
      });
      test('filter', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateFilter(ListFilter.completedOnly);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.completedOnly,
              group: ListGroup.none,
            ),
            origin: origin,
          ),
        );
      });
      test('group', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateGroup(ListGroup.priority);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.priority,
            ),
            origin: origin,
          ),
        );
      });
    });

    group('priority', () {
      test('add', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.addPriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              priorities: {Priority.A},
            ),
            origin: origin,
          ),
        );
      });
      test('add (already exists)', () async {
        const Filter origin = Filter(priorities: {Priority.A});
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.addPriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              priorities: {Priority.A},
            ),
            origin: origin,
          ),
        );
      });
      test('remove', () async {
        const Filter origin = Filter(priorities: {Priority.A});
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.removePriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              priorities: {},
            ),
            origin: origin,
          ),
        );
      });
      test('remove (not exists)', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.removePriority(Priority.A);

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              priorities: {},
            ),
            origin: origin,
          ),
        );
      });
      test('update multiple', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updatePriorities({Priority.A, Priority.B});

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.addProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {'project1'},
            ),
            origin: origin,
          ),
        );
      });
      test('add (already exists)', () async {
        const Filter origin = Filter(projects: {'project1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.addProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {'project1'},
            ),
            origin: origin,
          ),
        );
      });
      test('remove', () async {
        const Filter origin = Filter(projects: {'project1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.removeProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {},
            ),
            origin: origin,
          ),
        );
      });
      test('remove (not exists)', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.removeProject('project1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {},
            ),
            origin: origin,
          ),
        );
      });
      test('update multiple', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateProjects({'project1', 'project2'});

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {'project1', 'project2'},
            ),
            origin: origin,
          ),
        );
      });
    });

    group('context', () {
      test('add', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.addContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {'context1'},
            ),
            origin: origin,
          ),
        );
      });
      test('add (already exists)', () async {
        const Filter origin = Filter(contexts: {'context1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.addContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {'context1'},
            ),
            origin: origin,
          ),
        );
      });
      test('remove', () async {
        const Filter origin = Filter(contexts: {'context1'});
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.removeContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {},
            ),
            origin: origin,
          ),
        );
      });
      test('remove (not exists)', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.removeContext('context1');

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {},
            ),
            origin: origin,
          ),
        );
      });
      test('update multiple', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateContexts({'context1', 'context2'});

        expect(
          cubit.state,
          FilterChanged(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {'context1', 'context2'},
            ),
            origin: origin,
          ),
        );
      });
    });
  });

  group('saved filter', () {
    group('initial', () {
      test('initial filter', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: origin,
          ),
        );
      });
    });

    group('update', () {
      test('order', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateDefaultOrder(ListOrder.descending);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              order: ListOrder.descending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
            origin: const Filter(
              order: ListOrder.descending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
          ),
        );
      });
      test('filter', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateDefaultFilter(ListFilter.completedOnly);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.completedOnly,
              group: ListGroup.none,
            ),
            origin: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.completedOnly,
              group: ListGroup.none,
            ),
          ),
        );
      });
      test('group', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateDefaultGroup(ListGroup.priority);

        expect(
          cubit.state,
          FilterSaved(
            filter: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.priority,
            ),
            origin: const Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.priority,
            ),
          ),
        );
      });
    });

    group('reset', () {
      test('full', () async {
        const Filter origin = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: origin,
        );
        cubit.updateDefaultOrder(ListOrder.descending);
        cubit.updateDefaultFilter(ListFilter.completedOnly);
        cubit.updateDefaultGroup(ListGroup.priority);

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

        cubit.resetToDefaults();
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
