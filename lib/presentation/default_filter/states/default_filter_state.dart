import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;

final class DefaultFilterState extends Equatable {
  final Filter filter;

  const DefaultFilterState({
    this.filter = const Filter(),
  });

  DefaultFilterState copyWith({
    Filter? filter,
  }) {
    return DefaultFilterState(
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [
        filter,
      ];

  @override
  String toString() => 'DefaultFilterState { filter: $filter }';
}
