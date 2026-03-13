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
    on<FilterListFilterDeleted>(_onFilterDeleted);
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

  Future<void> _onFilterDeleted(
    FilterListFilterDeleted event,
    Emitter<FilterListState> emit,
  ) async {
    final List<Filter> previousList = state.filterList;
    final List<Filter> updatedList = previousList
        .where((Filter item) => item.id != event.filter.id)
        .toList(growable: false);

    // Important: Remove item instantily for Dismissible.
    // Otherwise we get an error:
    // A dismissed Dismissible widget is still part of the tree.
    emit(state.success(filterList: updatedList));
    try {
      await _repository.delete(id: event.filter.id!);
    } on Exception catch (e) {
      // If error rollback to previous list.
      emit(state.error(message: e.toString(), filterList: previousList));
    }
  }
}
