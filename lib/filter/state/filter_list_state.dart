import 'package:equatable/equatable.dart';
import 'package:ntodotxt/filter/model/filter_model.dart';

sealed class FilterListState extends Equatable {
  final List<Filter> filterList;

  const FilterListState({
    this.filterList = const [],
  });

  FilterListState copyWith({
    List<Filter>? filterList,
  });

  FilterListLoading loading({
    List<Filter>? filterList,
  }) {
    return FilterListLoading(
      filterList: filterList ?? this.filterList,
    );
  }

  FilterListSuccess success({
    List<Filter>? filterList,
  }) {
    return FilterListSuccess(
      filterList: filterList ?? this.filterList,
    );
  }

  FilterListError error({
    required String message,
    List<Filter>? filterList,
  }) {
    return FilterListError(
      message: message,
      filterList: filterList ?? this.filterList,
    );
  }

  @override
  List<Object> get props => [
        filterList,
      ];

  @override
  String toString() => 'FilterListState { filters: $filterList }';
}

final class FilterListLoading extends FilterListState {
  const FilterListLoading({
    super.filterList,
  });

  @override
  FilterListLoading copyWith({List<Filter>? filterList}) =>
      super.loading(filterList: filterList ?? this.filterList);

  @override
  String toString() => 'FilterListLoading { filters: $filterList }';
}

final class FilterListSuccess extends FilterListState {
  const FilterListSuccess({
    super.filterList,
  });

  @override
  FilterListSuccess copyWith({List<Filter>? filterList}) =>
      super.success(filterList: filterList ?? this.filterList);

  @override
  String toString() => 'FilterListSuccess { filters: $filterList }';
}

final class FilterListError extends FilterListState {
  final String message;

  const FilterListError({
    required this.message,
    super.filterList,
  });

  @override
  FilterListError copyWith({
    String? message,
    List<Filter>? filterList,
  }) =>
      super.error(
        message: message ?? this.message,
        filterList: filterList ?? this.filterList,
      );

  @override
  List<Object> get props => [
        message,
        filterList,
      ];

  @override
  String toString() =>
      'FilterListError { message: $message filters: $filterList }';
}
