import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, Filters, Groups, ListFilter, ListGroup, ListOrder, Order;
import 'package:ntodotxt/domain/filter/filter_repository.dart'
    show FilterRepository;
import 'package:ntodotxt/domain/settings/setting_model.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  final SettingRepository _settingRepository;
  final FilterRepository _filterRepository;

  FilterCubit({
    required SettingRepository settingRepository,
    required FilterRepository filterRepository,
    Filter? filter,
  })  : _settingRepository = settingRepository,
        _filterRepository = filterRepository,
        super(
          filter == null
              ? const FilterLoading(filter: Filter())
              : FilterSaved(filter: filter),
        );

  Future<void> initial() async {
    if (state is FilterLoading) {
      emit(
        state.save(
          filter: Filter(
            order: Order.byName(
                (await _settingRepository.get(key: 'order'))?.value),
            filter: Filters.byName(
                (await _settingRepository.get(key: 'filter'))?.value),
            group: Groups.byName(
                (await _settingRepository.get(key: 'group'))?.value),
          ),
        ),
      );
    }
  }

  ///
  /// Regular filter (saved filter)
  ///

  Future<void> create(Filter filter) async {
    try {
      int id = await _filterRepository.insert(filter);
      if (id > 0) {
        emit(state.save(filter: filter.copyWith(id: id)));
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> update(Filter filter) async {
    try {
      int id = await _filterRepository.update(filter);
      if (id > 0) {
        emit(state.save(filter: filter));
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> delete(Filter filter) async {
    try {
      if (filter.id != null) {
        await _filterRepository.delete(id: filter.id!);
      }
      emit(state.save(filter: filter.copyWithUnsaved()));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateName(String name) {
    try {
      emit(state.update(
        filter: state.filter.copyWith(name: name),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateOrder(ListOrder order) {
    try {
      emit(state.update(
        filter: state.filter.copyWith(order: order),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateFilter(ListFilter filter) {
    try {
      emit(state.update(
        filter: state.filter.copyWith(filter: filter),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateGroup(ListGroup group) {
    try {
      emit(state.update(
        filter: state.filter.copyWith(group: group),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addPriority(Priority priority) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            priorities: {...state.filter.priorities, priority},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removePriority(Priority priority) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            priorities: {...state.filter.priorities}..remove(priority),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updatePriorities(Set<Priority> priorities) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            priorities: {...priorities},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addProject(String project) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            projects: {...state.filter.projects, project},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeProject(String project) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            projects: {...state.filter.projects}..remove(project),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateProjects(Set<String> projects) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            projects: {...projects},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addContext(String context) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            contexts: {...state.filter.contexts, context},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeContext(String context) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            contexts: {...state.filter.contexts}..remove(context),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateContexts(Set<String> contexts) {
    try {
      emit(
        state.update(
          filter: state.filter.copyWith(
            contexts: {...contexts},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  ///
  /// Default filter
  ///

  Future<void> resetToDefaults() async {
    const Filter defaultFilter = Filter();
    emit(state.save(
      filter: defaultFilter,
    ));
    for (var k in ['order', 'filter', 'group']) {
      await _settingRepository.delete(key: k);
    }
  }

  Future<void> updateDefaultOrder(ListOrder? value) async {
    if (value != null) {
      emit(
        state.save(
          filter: state.filter.copyWith(order: value),
        ),
      );
      await _settingRepository.updateOrInsert(
        Setting(key: 'order', value: value.name),
      );
    }
  }

  Future<void> updateDefaultFilter(ListFilter? value) async {
    if (value != null) {
      emit(
        state.save(
          filter: state.filter.copyWith(filter: value),
        ),
      );
      await _settingRepository.updateOrInsert(
        Setting(key: 'filter', value: value.name),
      );
    }
  }

  Future<void> updateDefaultGroup(ListGroup? value) async {
    if (value != null) {
      emit(
        state.save(
          filter: state.filter.copyWith(group: value),
        ),
      );
      await _settingRepository.updateOrInsert(
        Setting(key: 'group', value: value.name),
      );
    }
  }
}
