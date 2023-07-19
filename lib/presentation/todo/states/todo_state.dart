import 'package:equatable/equatable.dart';

sealed class TodoState extends Equatable {
  final int? index;

  const TodoState(this.index);

  @override
  List<Object?> get props => [index];
}

final class TodoInitial extends TodoState {
  const TodoInitial() : super(null);

  @override
  String toString() => 'TodoInitial { index: $index }';
}

final class TodoViewing extends TodoState {
  const TodoViewing(super.index);

  @override
  String toString() => 'TodoViewing { index: $index }';
}

final class TodoEditing extends TodoState {
  const TodoEditing(super.index);

  @override
  String toString() => 'TodoEditing { index: $index }';
}

final class TodoCreating extends TodoState {
  const TodoCreating() : super(null);

  @override
  String toString() => 'TodoCreating { index: $index }';
}

final class TodoSearching extends TodoState {
  const TodoSearching() : super(null);

  @override
  String toString() => 'TodoSearching { index: $index }';
}
