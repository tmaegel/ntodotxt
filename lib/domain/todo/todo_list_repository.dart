import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

/// A repository that handles `todo` related requests.
class TodoListRepository {
  final TodoListApi _api;

  TodoListRepository({
    required TodoListApi api,
  }) : _api = api;

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList() => _api.getTodoList();

  /// Read [todoList] from source.
  Future<void> readFromSource() => _api.readFromSource();

  /// Write [todoList] to source.
  Future<void> writeToSource() => _api.writeToSource();

  /// Update the state.
  Future<void> update() => _api.update();

  bool existsTodo(Todo todo) => _api.existsTodo(todo);

  /// Saves a [todo].
  /// If a [todo] with [id] already exists, it will be replaced.
  /// If the [todo] with [id] already exists it will be updated/merged.
  void saveTodo(Todo todo) => _api.saveTodo(todo);

  /// Saves multiple [todos] by [id] at once.
  void saveMultipleTodos(List<Todo> todos) => _api.saveMultipleTodos(todos);

  /// Deletes the given [todo] by [id].
  void deleteTodo(Todo todo) => _api.deleteTodo(todo);

  /// Deletes multiple [todos] by [id] at once.
  void deleteMultipleTodos(List<Todo> todos) => _api.deleteMultipleTodos(todos);
}
