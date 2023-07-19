import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todotxt/presentation/todo/states/todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(const TodoInitial());

  void view({required int index}) => emit(TodoViewing(index));

  void edit({required int index}) => emit(TodoEditing(index));

  void create() => emit(const TodoCreating());

  void search() => emit(const TodoSearching());

  void reset() => emit(const TodoInitial());

  /// Setting state for backwards navigation.
  void back() {
    if (state is TodoEditing) {
      view(index: state.index!);
    } else if (state is TodoViewing ||
        state is TodoCreating ||
        state is TodoSearching) {
      reset();
    } else {
      reset();
    }
  }
}
