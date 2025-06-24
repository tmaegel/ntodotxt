import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/drawer/state/drawer_state.dart';

/// Keep the state of the selected item within the drawer.
class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit() : super(const DrawerState(index: 0));

  void reset() => emit(const DrawerState(index: 0));

  void next(int index) {
    emit(
      DrawerState(
        prevIndex: state.index,
        index: index,
      ),
    );
  }

  void back() {
    emit(
      DrawerState(
        prevIndex: null,
        index: state.prevIndex ?? 0,
      ),
    );
  }
}
