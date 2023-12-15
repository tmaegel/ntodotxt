import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart'
    show SettingController;
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/default_filter/states/default_filter_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingRepository repository;
  late SettingController controller;

  setUp(() async {
    controller = SettingController(inMemoryDatabasePath);
    repository = SettingRepository(controller);
  });

  group('initial', () {
    test('initial filter', () async {
      final DefaultFilterCubit cubit = DefaultFilterCubit(
        filter: const Filter(),
        repository: repository,
      );

      expect(
        cubit.state,
        const DefaultFilterState(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        ),
      );
    });
  });

  group('update', () {
    test('order', () async {
      final DefaultFilterCubit cubit = DefaultFilterCubit(
        filter: const Filter(),
        repository: repository,
      );
      cubit.updateListOrder(ListOrder.descending);

      expect(
        cubit.state,
        const DefaultFilterState(
          order: ListOrder.descending,
          filter: ListFilter.all,
          group: ListGroup.none,
        ),
      );
    });
    test('filter', () async {
      final DefaultFilterCubit cubit = DefaultFilterCubit(
        filter: const Filter(),
        repository: repository,
      );
      cubit.updateListFilter(ListFilter.completedOnly);

      expect(
        cubit.state,
        const DefaultFilterState(
          order: ListOrder.ascending,
          filter: ListFilter.completedOnly,
          group: ListGroup.none,
        ),
      );
    });
    test('group', () async {
      final DefaultFilterCubit cubit = DefaultFilterCubit(
        filter: const Filter(),
        repository: repository,
      );
      cubit.updateListGroup(ListGroup.priority);

      expect(
        cubit.state,
        const DefaultFilterState(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.priority,
        ),
      );
    });
  });

  group('reset', () {
    test('full', () async {
      final DefaultFilterCubit cubit = DefaultFilterCubit(
        filter: const Filter(),
        repository: repository,
      );
      cubit.updateListOrder(ListOrder.descending);
      cubit.updateListFilter(ListFilter.completedOnly);
      cubit.updateListGroup(ListGroup.priority);
      expect(
        cubit.state,
        const DefaultFilterState(
          order: ListOrder.descending,
          filter: ListFilter.completedOnly,
          group: ListGroup.priority,
        ),
      );

      cubit.reset();
      expect(
        cubit.state,
        const DefaultFilterState(
          order: ListOrder.ascending,
          filter: ListFilter.all,
          group: ListGroup.none,
        ),
      );
    });
  });
}
