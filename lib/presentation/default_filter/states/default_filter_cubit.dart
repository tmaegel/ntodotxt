import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_state.dart';

class DefaultFilterCubit extends Cubit<DefaultFilterState> {
  DefaultFilterCubit() : super(const DefaultFilterState());

  void resetSettings() {}

  void updateTodoOrder(ListOrder? value) {
    if (value != null) {
      emit(state.copyWith(order: value));
    }
  }

  void updateTodoFilter(ListFilter? value) {
    if (value != null) {
      emit(state.copyWith(filter: value));
    }
  }

  void updateTodoGrouping(ListGroup? value) {
    if (value != null) {
      emit(state.copyWith(group: value));
    }
  }
}
