import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_state.dart';

class TodoModeCubit extends Cubit<TodoModeState> {
  TodoModeCubit() : super(const TodoModeState());

  void list() => emit(const TodoModeState.list());

  void create() => emit(const TodoModeState.create());

  void view(int index) => emit(TodoModeState.view(index));

  void edit(int index) => emit(TodoModeState.edit(index));
}
