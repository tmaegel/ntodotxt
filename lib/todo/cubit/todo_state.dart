import 'package:equatable/equatable.dart';

enum TodoStatus { initial, viewing, editing, creating }

class TodoState extends Equatable {
  final int? index;
  final TodoStatus status;

  const TodoState({this.index, this.status = TodoStatus.initial});

  const TodoState.viewing(int index)
      : this(index: index, status: TodoStatus.viewing);

  const TodoState.editing(int index)
      : this(index: index, status: TodoStatus.editing);

  const TodoState.creating() : this(status: TodoStatus.creating);

  @override
  List<Object?> get props => [index, status];

  @override
  String toString() => 'TodoState { index: $index, status: $status }';
}
