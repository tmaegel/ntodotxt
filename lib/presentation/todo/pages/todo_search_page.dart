import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/todo.dart';
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
  }) : super(key: PageStorageKey<int>(todo.id!));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: _buildLeading(),
      title: Text(todo.description),
      subtitle: _buildSubtitle(),
      onTap: () => _onTapAction(context),
    );
  }

  Widget _buildLeading() {
    return Container(
      height: 35,
      width: 35,
      decoration: const BoxDecoration(
        color: colorLightGrey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          todo.priority ?? '',
          style: const TextStyle(color: colorBlack),
        ),
      ),
    );
  }

  Widget? _buildSubtitle() {
    if (todo.projects.isEmpty &&
        todo.contexts.isEmpty &&
        todo.keyValues.isEmpty) {
      return null;
    }

    return GenericChipGroup(
      children: <Widget>[
        for (var p in todo.projects)
          InlineChipReadOnly(label: p, color: projectChipColor),
        for (var c in todo.contexts)
          InlineChipReadOnly(label: c, color: contextChipColor),
        for (var kv in todo.formattedKeyValues)
          InlineChipReadOnly(label: kv, color: keyValueChipColor),
      ],
    );
  }

  void _onTapAction(BuildContext context) {
    context.goNamed("todo-view", extra: todo);
  }
}
