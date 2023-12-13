import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/saved_filter/filter_model.dart';

class FilterState extends Equatable {
  final Filter filter;

  const FilterState({
    required this.filter,
  });

  FilterState copyWith({
    Filter? filter,
  }) {
    return FilterState(
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
