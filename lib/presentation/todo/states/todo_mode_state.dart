import 'package:equatable/equatable.dart';

enum TodoModeStatus { initial, list, view, edit, create }

class TodoModeState extends Equatable {
  final TodoModeStatus status;
  final int? index;

  const TodoModeState({this.status = TodoModeStatus.initial, this.index});

  const TodoModeState.list() : this(status: TodoModeStatus.list);

  const TodoModeState.create() : this(status: TodoModeStatus.create);

  const TodoModeState.view(int index)
      : this(status: TodoModeStatus.view, index: index);

  const TodoModeState.edit(int index)
      : this(status: TodoModeStatus.edit, index: index);

  TodoModeState copyWith({
    TodoModeStatus? status,
    int? index,
  }) {
    return TodoModeState(
      status: status ?? this.status,
      index: index ?? this.index,
    );
  }

  @override
  List<Object?> get props => [status, index];

  @override
  String toString() => 'TodoModeState { status: $status index: $index }';
}
