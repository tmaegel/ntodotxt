import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

/// A repository that handles `todo` related requests.
class TodoListRepository {
  final TodoListApi _todoListApi;

  TodoListRepository({
    required TodoListApi todoListApi,
  }) : _todoListApi = todoListApi;

  /// Initialize repository. Not needed for testing.
  void init() => _todoListApi.init();

  /// Provides a [Stream] of all todos read from the source.
  Stream<List<Todo>> getTodoList() => _todoListApi.getTodoList();

  /// Read [todoList] from source.
  Future<void> readFromSource() => _todoListApi.readFromSource();

  /// Write [todoList] to source.
  Future<void> writeToSource() => _todoListApi.writeToSource();

  /// Saves a [todo].
  /// If a [todo] with the same id already exists, it will be replaced.
  /// If the id of [todo] is null, it will be created.
  void saveTodo(Todo todo) => _todoListApi.saveTodo(todo);

  /// Saves multiple [todos] at once.
  void saveMultipleTodos(List<Todo> todos) =>
      _todoListApi.saveMultipleTodos(todos);

  /// Deletes the given [todo].
  /// If the [todo] not exists, a [TodoNotFound] error is thrown.
  void deleteTodo(Todo todo) => _todoListApi.deleteTodo(todo);

  /// Deletes multiple [todos] at once.
  void deleteMultipleTodos(List<Todo> todos) =>
      _todoListApi.deleteMultipleTodos(todos);
}
