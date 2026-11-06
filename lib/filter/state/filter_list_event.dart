import 'package:equatable/equatable.dart';
import 'package:ntodotxt/filter/model/filter_model.dart';

sealed class FilterListEvent extends Equatable {
  const FilterListEvent();

  @override
  List<Object?> get props => [];
}

final class FilterListSubscriped extends FilterListEvent {
  const FilterListSubscriped();
}

final class FilterListSynchronizationRequested extends FilterListEvent {
  const FilterListSynchronizationRequested();
}

final class FilterListFilterDeleted extends FilterListEvent {
  final Filter filter;

  const FilterListFilterDeleted({
    required this.filter,
  });

  @override
  List<Object?> get props => [filter];
}
