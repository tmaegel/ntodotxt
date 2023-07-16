import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotxt/todo/cubit/todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(const TodoInitial());

  void view({required int index}) => emit(TodoViewing(index));

  void edit({required int index}) => emit(TodoEditing(index));

  void create() => emit(const TodoCreating());

  void search() => emit(const TodoSearching());

  void reset() => emit(const TodoInitial());
}
