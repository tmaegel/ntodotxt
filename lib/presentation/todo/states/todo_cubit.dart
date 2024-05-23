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
      if (state.todo.containsProject(project)) {
        emit(
          state.success(todo: state.todo.copyWith()),
        );
      } else {
        if (!Todo.matchProject(Todo.fmtProject(project))) {
          throw TodoInvalidProjectTag(tag: project);
        }
        emit(
          state.success(
            todo: state.todo.copyWith(
              description:
                  '${state.todo.description} ${Todo.fmtProject(project)}',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateProjects(Set<String> projectList) {
    try {
      Set<String> projects = {for (String p in projectList) p.toLowerCase()};
      for (String project in projects) {
        if (!Todo.matchProject(Todo.fmtProject(project))) {
          throw TodoInvalidProjectTag(tag: project);
        }
      }
      String description = state.todo.description;
      Iterable<String> addProjects =
          projects.where((p) => !state.todo.containsProject(p));
      Iterable<String> removeProjects =
          state.todo.projects.where((p) => !projects.contains(p));
      // Remove projects
      for (String p in removeProjects) {
        description = description.replaceAll(Todo.fmtProject(p), '');
      }
      // Add projects
      description = '$description ${{
        for (String p in addProjects) Todo.fmtProject(p)
      }.join(" ")}';
      emit(
        state.success(
          todo: state.todo.copyWith(
            description: description,
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeProject(String project) {
    try {
      if (!Todo.matchProject(Todo.fmtProject(project))) {
        throw TodoInvalidProjectTag(tag: project);
      }
      emit(
        state.success(
          todo: state.todo.copyWith(
            description: state.todo.description
                .replaceAll(Todo.fmtProject(project), '')
                .trim(),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addContext(String context) {
    try {
      if (state.todo.containsContext(context)) {
        emit(
          state.success(todo: state.todo.copyWith()),
        );
      } else {
        if (!Todo.matchContext(Todo.fmtContext(context))) {
          throw TodoInvalidContextTag(tag: context);
        }
        emit(
          state.success(
            todo: state.todo.copyWith(
              description:
                  '${state.todo.description} ${Todo.fmtContext(context)}',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateContexts(Set<String> contextList) {
    try {
      Set<String> contexts = {for (String c in contextList) c.toLowerCase()};
      for (String context in contexts) {
        if (!Todo.matchContext(Todo.fmtContext(context))) {
          throw TodoInvalidContextTag(tag: context);
        }
      }
      String description = state.todo.description;
      Iterable<String> addContexts =
          contexts.where((c) => !state.todo.containsContext(c));
      Iterable<String> removeContexts =
          state.todo.contexts.where((c) => !contexts.contains(c));
      // Remove projects
      for (String c in removeContexts) {
        description = description.replaceAll(Todo.fmtContext(c), '');
      }
      // Add projects
      description = '$description ${{
        for (String c in addContexts) Todo.fmtContext(c)
      }.join(" ")}';
      emit(
        state.success(
          todo: state.todo.copyWith(
            description: description,
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeContext(String context) {
    try {
      if (!Todo.matchContext(Todo.fmtContext(context))) {
        throw TodoInvalidContextTag(tag: context);
      }
      emit(
        state.success(
          todo: state.todo.copyWith(
            description: state.todo.description
                .replaceAll(Todo.fmtContext(context), '')
                .trim(),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addKeyValue(String kv) {
    try {
      if (!Todo.matchKeyValue(Todo.fmtKeyValue(kv))) {
        throw TodoInvalidKeyValueTag(tag: kv);
      }
      if (state.todo.containsKeyValue(kv)) {
        emit(
          state.success(
            todo: state.todo.copyWith(
              description: state.todo.description.replaceAllMapped(
                RegExp('${kv.split(':')[0]}:\\S+'),
                (match) => Todo.fmtKeyValue(kv),
              ),
            ),
          ),
        );
      } else {
        emit(
          state.success(
            todo: state.todo.copyWith(
              description: '${state.todo.description} ${Todo.fmtKeyValue(kv)}',
            ),
          ),
        );
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void updateKeyValues(Set<String> keyValueList) {
    try {
      Set<String> kvs = {for (String kv in keyValueList) kv.toLowerCase()};
      for (String kv in kvs) {
        if (!Todo.matchKeyValue(Todo.fmtKeyValue(kv))) {
          throw TodoInvalidKeyValueTag(tag: kv);
        }
      }
      String description = state.todo.description;
      Iterable<String> addKeyValues =
          kvs.where((kv) => !state.todo.containsKeyValue(kv));
      Iterable<String> removeKeyValues = state.todo.keyValues.where((kv) {
        for (String keyVal in kvs) {
          if (kv.toLowerCase().split(':')[0] ==
              keyVal.toLowerCase().split(':')[0]) {
            return false;
          }
        }
        return true;
      });
      Iterable<String> existingKeyValues =
          kvs.where((kv) => state.todo.containsKeyValue(kv));
      // Remove projects
      for (String kv in removeKeyValues) {
        description = description.replaceAll(Todo.fmtKeyValue(kv), '');
      }
      description = '$description ${{
        for (String kv in addKeyValues) Todo.fmtKeyValue(kv)
      }.join(" ")}';
      // Replace existing key values instead concat them.
      for (String kv in existingKeyValues) {
        description = description.replaceAllMapped(
          RegExp('${kv.split(':')[0]}:\\S+'),
          (match) => Todo.fmtKeyValue(kv),
        );
      }
      emit(
        state.success(
          todo: state.todo.copyWith(
            description: description,
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void removeKeyValue(String kv) {
    try {
      if (!Todo.matchKeyValue(Todo.fmtKeyValue(kv))) {
        throw TodoInvalidKeyValueTag(tag: kv);
      }
      emit(
        state.success(
          todo: state.todo.copyWith(
            description: state.todo.description
                .replaceAll(Todo.fmtKeyValue(kv), '')
                .trim(),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
