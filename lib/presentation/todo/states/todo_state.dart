import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

enum TodoStatus { initial, loading, success, failure }

final class TodoState extends Equatable {
  final TodoStatus status;
  final Todo todo;

  const TodoState({
    this.status = TodoStatus.initial,
    required this.todo,
  });

  TodoState copyWith({
    TodoStatus? status,
    Todo? todo,
  }) {
    return TodoState(
      status: status ?? this.status,
      todo: todo ?? this.todo,
    );
  }

  @override
  List<Object?> get props => [
        status,
        todo,
      ];

  @override
  String toString() => 'TodoState { status: $status todo: "$todo" }';
}
