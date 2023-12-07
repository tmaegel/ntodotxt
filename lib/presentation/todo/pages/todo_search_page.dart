import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class TodoSearchPage extends SearchDelegate {
  List<Todo> _getResults(List<Todo> todoList) {
    List<Todo> matchQuery = [];
    for (var todo in todoList) {
      if (todo.toString().toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(todo);
      }
    }

    return matchQuery;
  }

  Widget _buildResults(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        final List<Todo> matchQuery = _getResults(state.todoList);
        return ListView.builder(
          itemCount: matchQuery.length,
          itemBuilder: (BuildContext context, int index) {
            Todo todo = matchQuery[index];
            return TodoSearchTile(todo: todo);
          },
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      const SizedBox(width: 16),
    ];
  }

  @override
  String get searchFieldLabel => 'Search ...';

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults(context);
}

class TodoSearchTile extends StatelessWidget {
  final Todo todo;

  TodoSearchTile({
    required this.todo,
    Key? key,
  }) : super(key: PageStorageKey<String>(todo.id));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.completion ? TextDecoration.lineThrough : null,
          decorationThickness: 2.0,
        ),
      ),
      subtitle: _buildSubtitle(),
      onTap: () => _onTapAction(context),
    );
  }

  Widget? _buildSubtitle() {
    if (todo.creationDate == null &&
        todo.priority == Priority.none &&
        todo.projects.isEmpty &&
        todo.contexts.isEmpty &&
        todo.keyValues.isEmpty) {
      return null;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        if (todo.priority != Priority.none)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtPriority),
          ),
        if (todo.creationDate != null && todo.completion == false)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(Todo.differenceToToday(todo.creationDate!)),
          ),
        if (todo.completionDate != null && todo.completion == true)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(Todo.differenceToToday(todo.completionDate!)),
          ),
        if (todo.projects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtProjects.join(' ')),
          ),
        if (todo.contexts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtContexts.join(' ')),
          ),
        if (todo.keyValues.isNotEmpty) Text(todo.fmtKeyValues.join(' ')),
      ],
    );
  }

  void _onTapAction(BuildContext context) {
    context.pushNamed("todo-edit", extra: todo);
  }
}
