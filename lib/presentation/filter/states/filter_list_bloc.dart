import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_event.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_state.dart';
import 'package:rxdart/rxdart.dart';

class FilterListBloc extends Bloc<FilterListEvent, FilterListState> {
  final FilterRepository _repository;
  final PublishSubject<List<Filter>> _controller =
      PublishSubject<List<Filter>>();

  FilterListBloc({required FilterRepository repository})
      : _repository = repository,
        super(const FilterListSuccess()) {
    on<FilterListSubscriped>(_onFilterListSubscriped);
    on<FilterCreated>(_onFilterCreated);
    on<FilterUpdated>(_onFilterUpdated);
    on<FilterDeleted>(_onFilterDeleted);
    _refresh();
  }

  Stream<List<Filter>> get _list => _controller.stream;

  Future<void> _refresh() async {
    _controller.sink.add(await _repository.list());
  }

  Future<void> _onFilterListSubscriped(
    FilterListSubscriped event,
    Emitter<FilterListState> emit,
  ) async {
    await emit.forEach<List<Filter>>(
      _list,
      onData: (filterList) {
        return state.success(filterList: filterList);
      },
      onError: (e, _) => state.error(message: e.toString()),
    );
  }

  Future<void> _onFilterCreated(
    FilterCreated event,
    Emitter<FilterListState> emit,
  ) async {
    try {
      await _repository.insert(event.filter);
      await _refresh();
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onFilterUpdated(
    FilterUpdated event,
    Emitter<FilterListState> emit,
  ) async {
    try {
      await _repository.update(event.filter);
      await _refresh();
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> _onFilterDeleted(
    FilterDeleted event,
    Emitter<FilterListState> emit,
  ) async {
    try {
      await _repository.delete(id: event.filter.id!);
      await _refresh();
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
