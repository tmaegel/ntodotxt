import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

sealed class FilterState extends Equatable {
  final Filter filter;

  const FilterState({
    required this.filter,
  });

  FilterChanged update({
    Filter? filter,
  }) {
    return FilterChanged(
      filter: filter ?? this.filter,
    );
  }

  FilterSaved save({
    Filter? filter,
  }) {
    return FilterSaved(
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

final class FilterLoading extends FilterState {
  const FilterLoading({
    required super.filter,
  });

  FilterLoading copyWith({
    Filter? filter,
  }) {
    return FilterLoading(
      filter: filter ?? this.filter,
    );
  }

  @override
  String toString() => 'FilterLoading { filter: $filter }';
}

final class FilterChanged extends FilterState {
  const FilterChanged({
    required super.filter,
  });

  FilterChanged copyWith({
    Filter? filter,
  }) {
    return FilterChanged(
      filter: filter ?? this.filter,
    );
  }

  @override
  String toString() => 'FilterChanged { filter: $filter }';
}

final class FilterSaved extends FilterState {
  const FilterSaved({
    required super.filter,
  });

  FilterSaved copyWith({
    Filter? filter,
  }) {
    return FilterSaved(
      filter: filter ?? this.filter,
    );
  }

  @override
  String toString() => 'FilterSaved { filter: $filter }';
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
  String toString() => 'FilterError { message: $message filter: $filter }';
}
