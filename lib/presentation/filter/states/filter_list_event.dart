import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';

sealed class FilterListEvent extends Equatable {
  const FilterListEvent();

  @override
  List<Object?> get props => [];
}

final class FilterListSubscriped extends FilterListEvent {
  const FilterListSubscriped();
}

final class FilterCreated extends FilterListEvent {
  final Filter filter;

  const FilterCreated({
    required this.filter,
  });

  @override
  List<Object?> get props => [filter];
}

final class FilterUpdated extends FilterListEvent {
  final Filter filter;

  const FilterUpdated({
    required this.filter,
  });

  @override
  List<Object?> get props => [filter];
}

final class FilterDeleted extends FilterListEvent {
  final Filter filter;

  const FilterDeleted({
    required this.filter,
  });

  @override
  List<Object?> get props => [filter];
}
