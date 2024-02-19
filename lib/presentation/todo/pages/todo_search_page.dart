import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class TodoSearchPage extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            isDense: true,
            filled: false,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
    );
  }

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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
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
      ),
    );
  }

  Widget? _buildSubtitle() {
    final List<String> items = [
      if (todo.priority != Priority.none) todo.priority.name,
      for (String p in todo.fmtProjects) p,
      for (String c in todo.fmtContexts) c,
      for (String kv in todo.fmtKeyValues) kv,
    ]..removeWhere((value) => value.isEmpty);

    if (items.isEmpty) {
      return null;
    }

    List<String> shortenedItems;
    if (items.length > 5) {
      shortenedItems = items.sublist(0, 5);
      shortenedItems.add('...');
    } else {
      shortenedItems = [...items];
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (String attr in shortenedItems) BasicChip(label: attr, mono: true),
      ],
    );
  }

  void _onTapAction(BuildContext context) {
    context.pushNamed('todo-edit', extra: todo);
  }
}
