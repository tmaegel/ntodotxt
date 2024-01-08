import 'package:equatable/equatable.dart';

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
