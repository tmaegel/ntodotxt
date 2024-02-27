import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

/// Keep the state of the selected item within the drawer.
class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit() : super(const DrawerState(index: 0));

  void reset() => emit(state.copyWith(index: 0));

  void next(int index) {
    emit(
      state.copyWith(
        prevIndices: [...state.prevIndices, state.index],
        index: index,
      ),
    );
  }

  void back() {
    int index = 0;
    List<int> prevIndices = [...state.prevIndices];
    if (prevIndices.isNotEmpty) {
      index = prevIndices.removeLast();
    }
    emit(
      state.copyWith(
        prevIndices: prevIndices,
        index: index,
      ),
    );
  }
}

final class DrawerState extends Equatable {
  final int index;
  final List<int> prevIndices;

  const DrawerState({
    required this.index,
    this.prevIndices = const [],
  });

  DrawerState copyWith({
    int? index,
    List<int>? prevIndices,
  }) {
    return DrawerState(
      index: index ?? this.index,
      prevIndices: prevIndices ?? this.prevIndices,
    );
  }

  @override
  List<Object?> get props => [
        index,
        prevIndices,
      ];

  @override
  String toString() =>
      'DrawerState { index: $index prevIndices: $prevIndices }';
}
