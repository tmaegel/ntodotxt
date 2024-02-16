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
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
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

    group('create (repository)', () {
      test('not exists', () async {
        const Filter filter = Filter();
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: filter,
        );
        await cubit.create(filter.copyWith(name: 'created'));

        await expectLater(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateOrder(ListOrder.descending);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.descending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
          ),
        );
      });
      test('filter', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateFilter(ListFilter.completedOnly);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.completedOnly,
              group: ListGroup.none,
            ),
          ),
        );
      });
      test('group', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateGroup(ListGroup.priority);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.addPriority(Priority.A);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(priorities: {Priority.A}),
        );
        cubit.addPriority(Priority.A);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(priorities: {Priority.A}),
        );
        cubit.removePriority(Priority.A);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.removePriority(Priority.A);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              priorities: {},
            ),
          ),
        );
      });
      test('update multiple', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updatePriorities({Priority.A, Priority.B});

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              priorities: {Priority.A, Priority.B},
            ),
          ),
        );
      });
    });

    group('project', () {
      test('add', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.addProject('project1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(projects: {'project1'}),
        );
        cubit.addProject('project1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(projects: {'project1'}),
        );
        cubit.removeProject('project1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.removeProject('project1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {},
            ),
          ),
        );
      });
      test('update multiple', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateProjects({'project1', 'project2'});

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              projects: {'project1', 'project2'},
            ),
          ),
        );
      });
    });

    group('context', () {
      test('add', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.addContext('context1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(contexts: {'context1'}),
        );
        cubit.addContext('context1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(contexts: {'context1'}),
        );
        cubit.removeContext('context1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.removeContext('context1');

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {},
            ),
          ),
        );
      });
      test('update multiple', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateContexts({'context1', 'context2'});

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
              contexts: {'context1', 'context2'},
            ),
          ),
        );
      });
    });
  });

  group('saved filter', () {
    group('initial', () {
      test('initial filter', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
          ),
        );
      });
    });

    group('update', () {
      test('order', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateDefaultOrder(ListOrder.descending);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.descending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
          ),
        );
      });
      test('filter', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateDefaultFilter(ListFilter.completedOnly);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.completedOnly,
              group: ListGroup.none,
            ),
          ),
        );
      });
      test('group', () async {
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateDefaultGroup(ListGroup.priority);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
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
        final FilterCubit cubit = FilterCubit(
          settingRepository: SettingRepository(SettingController(databasePath)),
          filterRepository: FilterRepository(FilterController(databasePath)),
          filter: const Filter(),
        );
        cubit.updateDefaultOrder(ListOrder.descending);
        cubit.updateDefaultFilter(ListFilter.completedOnly);
        cubit.updateDefaultGroup(ListGroup.priority);

        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.descending,
              filter: ListFilter.completedOnly,
              group: ListGroup.priority,
            ),
          ),
        );

        cubit.resetToDefaults();
        expect(
          cubit.state,
          const FilterSuccess(
            filter: Filter(
              order: ListOrder.ascending,
              filter: ListFilter.all,
              group: ListGroup.none,
            ),
          ),
        );
      });
    });
  });
}
