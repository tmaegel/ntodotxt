import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show Filter, ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_state.dart';

class DefaultFilterCubit extends Cubit<DefaultFilterState> {
  final SettingRepository _repository;

  DefaultFilterCubit({
    required Filter filter,
    required SettingRepository repository,
  })  : _repository = repository,
        super(
          DefaultFilterState(filter: filter),
        );

  Future<void> reset() async {
    const Filter defaultFilter = Filter();
    emit(state.copyWith(
      filter: defaultFilter,
    ));
    for (var k in ['order', 'filter', 'group']) {
      await _repository.delete(key: k);
    }
  }

  Future<void> updateListOrder(ListOrder? value) async {
    if (value != null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(order: value),
        ),
      );
      await _repository.updateOrInsert(
        Setting(key: 'order', value: value.name),
      );
    }
  }

  Future<void> updateListFilter(ListFilter? value) async {
    if (value != null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(filter: value),
        ),
      );
      await _repository.updateOrInsert(
        Setting(key: 'filter', value: value.name),
      );
    }
  }

  Future<void> updateListGroup(ListGroup? value) async {
    if (value != null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(group: value),
        ),
      );
      await _repository.updateOrInsert(
        Setting(key: 'group', value: value.name),
      );
    }
  }
}
