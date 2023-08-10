import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

enum TodoStatus { initial, loading, success, failure }

final class TodoState extends Equatable {
  final TodoStatus status;
  final int index;
  final Todo todo;

  const TodoState({
    this.status = TodoStatus.initial,
    required this.index,
    required this.todo,
  });

  TodoState copyWith({
    TodoStatus? status,
    int? index,
    Todo? todo,
  }) {
    return TodoState(
      status: status ?? this.status,
      index: index ?? this.index,
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object?> get props => [
        status,
        index,
        todo,
      ];

  @override
  String toString() => 'TodoState { status: $status index: $index }';
}