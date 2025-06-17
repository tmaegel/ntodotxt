import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/filter/model/filter_model.dart';
import 'package:ntodotxt/filter/repository/filter_repository.dart';
import 'package:ntodotxt/filter/state/filter_list_event.dart';
import 'package:ntodotxt/filter/state/filter_list_state.dart';

class FilterListBloc extends Bloc<FilterListEvent, FilterListState> {
  final FilterRepository _repository;

  FilterListBloc({required FilterRepository repository})
      : _repository = repository,
        super(const FilterListLoading()) {
    on<FilterListSubscriped>(_onFilterListSubscriped);
    on<FilterListSynchronizationRequested>(_onFilterSynchronizationRequested);
  }

  Future<void> _onFilterListSubscriped(
    FilterListSubscriped event,
    Emitter<FilterListState> emit,
  ) async {
    await emit.forEach<List<Filter>>(
      _repository.stream,
      onData: (filterList) {
        return state.copyWith(filterList: filterList);
      },
      onError: (e, _) => state.error(message: e.toString()),
    );
  }

  Future<void> _onFilterSynchronizationRequested(
    FilterListSynchronizationRequested event,
    Emitter<FilterListState> emit,
  ) async {
    try {
      emit(state.loading());
      await _repository.refresh();
      emit(state.success());
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
