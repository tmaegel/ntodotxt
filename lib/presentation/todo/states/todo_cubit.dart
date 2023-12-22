import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/exceptions/exceptions.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit({
    required Todo todo,
  }) : super(TodoSuccess(todo: todo));

  void updateTodo(Todo todo) {
    try {
      emit(state.success(
        todo: todo.copyWith(),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void toggleCompletion({bool? completion}) {
    try {
      emit(state.success(
        todo: state.todo.copyWith(
          completion: completion ?? !state.todo.completion,
        ),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateDescription(String description) {
    try {
      emit(state.success(
        todo: state.todo.copyWith(description: description),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void setPriority(Priority priority) {
    try {
      emit(state.success(
        todo: state.todo.copyWith(priority: priority),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void unsetPriority() {
    try {
      emit(state.success(
        todo: state.todo.copyWith(priority: Priority.none),
      ));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addProject(String project) {
    try {
      emit(
        state.success(
          todo: state.todo.copyWith(
            projects: {...state.todo.projects, project},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateProjects(Set<String> projects) {
    try {
      emit(
        state.success(
          todo: state.todo.copyWith(
            projects: {...projects},
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
          todo: state.todo.copyWith(
            projects: {...state.todo.projects}..remove(project),
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
          todo: state.todo.copyWith(
            contexts: {...state.todo.contexts, context},
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateContexts(Set<String> contexts) {
    try {
      emit(
        state.success(
          todo: state.todo.copyWith(
            contexts: {...contexts},
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
          todo: state.todo.copyWith(
            contexts: {...state.todo.contexts}..remove(context),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addKeyValue(String kv) {
    try {
      if (!Todo.patternKeyValue.hasMatch(kv)) {
        throw TodoInvalidKeyValueTag(tag: kv);
      }

      Map<String, String> keyValues = {...state.todo.keyValues};
      final List<String> splittedKeyValue = kv.split(':');
      if (splittedKeyValue.length == 2) {
        keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
      }
      final Todo todo = state.todo.copyWith(keyValues: keyValues);
      emit(state.success(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateKeyValues(Set<String> kvs) {
    try {
      Map<String, String> keyValues = {};
      for (var kv in kvs) {
        if (!Todo.patternKeyValue.hasMatch(kv)) {
          throw TodoInvalidKeyValueTag(tag: kv);
        }
        final List<String> splittedKeyValue = kv.split(':');
        if (splittedKeyValue.length == 2) {
          keyValues[splittedKeyValue[0]] = splittedKeyValue[1];
        }
      }
      final Todo todo = state.todo.copyWith(keyValues: keyValues);
      emit(state.success(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeKeyValue(String kv) {
    try {
      if (!Todo.patternKeyValue.hasMatch(kv)) {
        throw TodoInvalidKeyValueTag(tag: kv);
      }

      Map<String, String> keyValues = {...state.todo.keyValues};
      final List<String> splittedKeyValue = kv.split(':');
      if (splittedKeyValue.length == 2) {
        keyValues.remove(splittedKeyValue[0]);
      }
      final Todo todo = state.todo.copyWith(keyValues: keyValues);
      emit(state.success(todo: todo));
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
