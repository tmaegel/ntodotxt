import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart'
    show TodoListFilter, TodoListGroupBy, TodoListOrder;

class FilterCubit extends Cubit<FilterState> {
  FilterCubit({
    required Filter filter,
  }) : super(FilterSuccess(filter: filter));

  void updateName(String name) {
    try {
      emit(state.success(
        filter: state.filter.copyWith(name: name),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateOrder(TodoListOrder order) {
    try {
      emit(state.success(
        filter: state.filter.copyWith(order: order),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateFilter(TodoListFilter filter) {
    try {
      emit(state.success(
        filter: state.filter.copyWith(filter: filter),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateGroupBy(TodoListGroupBy groupBy) {
    try {
      emit(state.success(
        filter: state.filter.copyWith(groupBy: groupBy),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addPriority(Priority priority) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(
            priorities: {...state.filter.priorities, priority},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removePriority(Priority priority) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(
            priorities: {...state.filter.priorities}..remove(priority),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addProject(String project) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(
            projects: {...state.filter.projects, project},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeProject(String project) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(
            projects: {...state.filter.projects}..remove(project),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addContext(String context) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(
            contexts: {...state.filter.contexts, context},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeContext(String context) {
    try {
      emit(
        state.success(
          filter: state.filter.copyWith(
            contexts: {...state.filter.contexts}..remove(context),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
