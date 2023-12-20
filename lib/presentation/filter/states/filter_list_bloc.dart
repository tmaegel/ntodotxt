import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_state.dart';

class FilterListBloc extends Bloc<FilterListEvent, FilterListState> {
  final FilterRepository _repository;

  FilterListBloc({required FilterRepository repository})
      : _repository = repository,
        super(const FilterListSuccess()) {
    on<FilterListSubscriped>(_onFilterListSubscriped);
  }

  Future<void> _onFilterListSubscriped(
    FilterListSubscriped event,
    Emitter<FilterListState> emit,
  ) async {
    await _repository.refresh();
    await emit.forEach<List<Filter>>(
      _repository.stream,
      onData: (filterList) {
        return state.success(filterList: filterList);
      },
      onError: (e, _) => state.error(message: e.toString()),
    );
  }
}
