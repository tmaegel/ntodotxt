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

  /// Get a single [todo] by index.
  Todo getTodo(int index) => _todoListApi.getTodo(index);

  /// Saves a [todo].
  /// If a [todo] with the same index already exists, it will be replaced.
  void saveTodo(int? index, Todo todo) => _todoListApi.saveTodo(index, todo);

  /// Deletes the `todo` with the given index.
  /// If no `todo` with the given id exists, a [TodoNotFoundException] error is thrown.
  void deleteTodo(int index) => _todoListApi.deleteTodo(index);

  List<String?> getAllPriorities() => _todoListApi.getAllPriorities();

  List<String> getAllProjects() => _todoListApi.getAllProjects();

  List<String> getAllContexts() => _todoListApi.getAllContexts();
}
