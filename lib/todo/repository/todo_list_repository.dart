import 'package:ntodotxt/todo/api/todo_list_api.dart';
import 'package:ntodotxt/todo/model/todo_model.dart';

/// A repository that handles `todo` related requests.
class TodoListRepository {
  final TodoListApi api;

  TodoListRepository(this.api);

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList() => api.getTodoList();

  Future<void> initSource() => api.initSource();

  /// Read [todoList] from source.
  Future<void> readFromSource() => api.readFromSource();

  /// Write [todoList] to source.
  Future<void> writeToSource() => api.writeToSource();

  bool existsTodo(Todo todo) => api.existsTodo(todo);

  /// Saves a [todo].
  /// If a [todo] with [id] already exists, it will be replaced.
  /// If the [todo] with [id] already exists it will be updated/merged.
  void saveTodo(Todo todo) => api.saveTodo(todo);

  /// Saves multiple [todos] by [id] at once.
  void saveMultipleTodos(List<Todo> todos) => api.saveMultipleTodos(todos);

  /// Deletes the given [todo] by [id].
  void deleteTodo(Todo todo) => api.deleteTodo(todo);

  /// Deletes multiple [todos] by [id] at once.
  void deleteMultipleTodos(List<Todo> todos) => api.deleteMultipleTodos(todos);
}
