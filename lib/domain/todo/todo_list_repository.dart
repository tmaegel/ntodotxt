import 'package:ntodotxt/data/todo/todo_list_api.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

/// A repository that handles `todo` related requests.
class TodoListRepository {
  final TodoListApi _todoListApi;

  TodoListRepository({
    required TodoListApi todoListApi,
  }) : _todoListApi = todoListApi;

  /// Provides a [Stream] of all todos.
  Stream<List<Todo>> getTodoList() => _todoListApi.getTodoList();

  /// Get a single [todo] by id.
  Todo getTodo(int id) => _todoListApi.getTodo(id);

  /// Saves a [todo].
  /// If a [todo] with the same id already exists, it will be replaced.
  void saveTodo(int? id, Todo todo) => _todoListApi.saveTodo(id, todo);

  /// Deletes the `todo` with the given id.
  /// If no `todo` with the given id exists, a [TodoNotFoundException] error is thrown.
  void deleteTodo(int id) => _todoListApi.deleteTodo(id);

  List<String?> getAllPriorities() => _todoListApi.getAllPriorities();

  List<String> getAllProjects() => _todoListApi.getAllProjects();

  List<String> getAllContexts() => _todoListApi.getAllContexts();
}
