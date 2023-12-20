import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';

sealed class FilterListState extends Equatable {
  final List<Filter> filterList;

  const FilterListState({
    this.filterList = const [],
  });

  bool filterExists(Filter filter) =>
      filterList.indexWhere((Filter f) => f == filter) != -1;

  FilterListState success({
    List<Filter>? filterList,
  }) {
    return FilterListSuccess(
      filterList: filterList ?? this.filterList,
    );
  }

  FilterListState error({
    required String message,
    List<Filter>? filterList,
  }) {
    return FilterListError(
      message: message,
      filterList: filterList ?? this.filterList,
    );
  }

  @override
  List<Object?> get props => [
        filterList,
      ];

  @override
  String toString() => 'FilterListState { filters: $filterList }';
}

final class FilterListSuccess extends FilterListState {
  const FilterListSuccess({
    super.filterList,
  });

  @override
  String toString() => 'FilterListSuccess { filters: [ "$filterList" ] }';
}

final class FilterListError extends FilterListState {
  final String message;

  const FilterListError({
    required this.message,
    super.filterList,
  });

  @override
  List<Object?> get props => [
        message,
        filterList,
      ];

  @override
  String toString() =>
      'FilterListError { message: $message filters: $filterList }';
}
