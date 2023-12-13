import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/saved_filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/saved_filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart'
    show TodoListGroupBy, TodoListOrder;

class FilterCubit extends Cubit<FilterState> {
  FilterCubit({
    required Filter filter,
  }) : super(FilterState(filter: filter));

  void updateName(String name) {
    emit(state.copyWith(
      filter: state.filter.copyWith(name: name),
    ));
  }

  void updateOrder(TodoListOrder order) {
    emit(state.copyWith(
      filter: state.filter.copyWith(order: order),
    ));
  }

  void updateGroupBy(TodoListGroupBy groupBy) {
    emit(state.copyWith(
      filter: state.filter.copyWith(groupBy: groupBy),
    ));
  }

  void addPriority(Priority priority) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          priorities: {...state.filter.priorities, priority},
        ),
      ),
    );
  }

  void removePriority(Priority priority) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          priorities: {...state.filter.priorities}..remove(priority),
        ),
      ),
    );
  }

  void addProject(String project) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          projects: {...state.filter.projects, project},
        ),
      ),
    );
  }

  void removeProject(String project) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          projects: {...state.filter.projects}..remove(project),
        ),
      ),
    );
  }

  void addContext(String context) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          contexts: {...state.filter.contexts, context},
        ),
      ),
    );
  }

  void removeContext(String context) {
    emit(
      state.copyWith(
        filter: state.filter.copyWith(
          contexts: {...state.filter.contexts}..remove(context),
        ),
      ),
    );
  }
}
