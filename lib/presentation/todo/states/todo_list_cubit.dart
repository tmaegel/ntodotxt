import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/constants/placeholder.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

class TodoListCubit extends Cubit<List<Todo>> {
  TodoListCubit() : super(TodoList.fromList(rawTodoList));

  // void add({required Todo todo}) {
  //   state.add(todo);
  //   emit([...state]);
  // }

  void update({required int index, required Todo todo}) {
    List<Todo> newState = List.from(state);
    newState[index] = todo;
    emit(newState);
  }

  // void delete({required int index}) {
  //   state.removeAt(index);
  //   emit([...state]);
  // }

  void toggleCompletion({required int index}) {
    final oldTodo = state[index];
    update(
      index: index,
      todo: Todo(
        completion: !oldTodo.completion,
        description: oldTodo.description,
        priority: oldTodo.priority,
        completionDate: oldTodo.completionDate,
        creationDate: oldTodo.creationDate,
        projects: oldTodo.projects,
        contexts: oldTodo.contexts,
        keyValues: oldTodo.keyValues,
      ),
    );
  }
}
