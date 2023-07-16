import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotxt/todo/cubit/todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(const TodoState());

  void view({required int index}) => emit(TodoState.viewing(index));

  void edit({required int index}) => emit(TodoState.editing(index));

  void create() => emit(const TodoState.creating());

  void reset() => emit(const TodoState());
}
