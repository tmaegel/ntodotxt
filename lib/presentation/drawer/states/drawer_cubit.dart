import 'package:flutter_bloc/flutter_bloc.dart';

/// Keep the state of the selected item within the drawer.
class DrawerCubit extends Cubit<int> {
  DrawerCubit() : super(0);

  void select(int index) => emit(index);
}
