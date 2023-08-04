import 'package:equatable/equatable.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

enum TodoListStatus { initial, loading, success, failure }

final class TodoListState extends Equatable {
  final TodoListStatus status;
  final List<Todo> todoList;

  const TodoListState({
    this.status = TodoListStatus.initial,
    this.todoList = const [],
  });

  TodoListState copyWith({
    TodoListStatus? status,
    List<Todo>? todoList,
  }) {
    return TodoListState(
      status: status ?? this.status,
      todoList: todoList ?? this.todoList,
    );
  }

  @override
  List<Object?> get props => [
        status,
        todoList,
      ];

  @override
  String toString() => 'TodoListState { status: $status }';
}
