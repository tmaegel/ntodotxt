import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

sealed class FilterState extends Equatable {
  final Filter filter;

  const FilterState({
    required this.filter,
  });

  FilterSuccess success({
    Filter? filter,
  }) {
    return FilterSuccess(
      filter: filter ?? this.filter,
    );
  }

  FilterError error({
    required String message,
    Filter? filter,
  }) {
    return FilterError(
      message: message,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        filter,
      ];

  @override
  String toString() => 'FilterState { filter: $filter }';
}

final class FilterSuccess extends FilterState {
  const FilterSuccess({
    required super.filter,
  });

  FilterSuccess copyWith({
    Filter? filter,
  }) {
    return FilterSuccess(
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        filter,
      ];

  @override
  String toString() => 'FilterSuccess { filter: $filter }';
}

final class FilterError extends FilterState {
  final String message;

  const FilterError({
    required this.message,
    required super.filter,
  });

  FilterError copyWith({
    String? message,
    Filter? filter,
  }) {
    return FilterError(
      message: message ?? this.message,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        message,
        filter,
      ];

  @override
  String toString() => 'FilterError { message: $message filter: "$filter" }';
}
