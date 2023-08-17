import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/search_bar.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < maxScreenWidthCompact) {
      return const TodoListNarrowView();
    } else {
      return const TodoListWideView();
    }
  }
}

abstract class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  /// Add new todo
  void _createAction(BuildContext context) {
    context.push(context.namedLocation('todo-create'));
  }

  /// Switch todo list ordering.
  void _orderAction(BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListOrderChanged());
  }

  List<Widget> _buildToolBarActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Visibility',
        icon: const Icon(Icons.visibility_outlined),
        onPressed: () {},
      ),
      IconButton(
        tooltip: 'Sort',
        icon: const Icon(Icons.sort),
        onPressed: () => _orderAction(context),
      ),
      IconButton(
        tooltip: 'Filter',
        icon: const Icon(Icons.filter_alt_outlined),
        onPressed: () {},
      ),
    ];
  }
}

class TodoListNarrowView extends TodoListView {
  const TodoListNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72.0, // Height (56) + Padding (16))
        title: const GenericSearchBar(),
      ),
      body: const TodoList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: PrimaryBottomAppBar(
        children: _buildToolBarActions(context),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () => _createAction(context),
    );
  }
}

class TodoListWideView extends TodoListView {
  const TodoListWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 72.0, // Height (56) + Padding (16))
          title: const GenericSearchBar(),
          actions: [
            ..._buildToolBarActions(context),
            const SizedBox(width: 16.0),
          ]),
      body: const TodoList(),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        // @todo: SingleChildScrollView
        return Column(
          children: [
            Expanded(
              child: ListView(
                children: _buildExpandedListViewByFilter(
                  state: state,
                  sections: state.priorities,
                  filterCallback: (priority) => state.filteredByPriority(
                    priority: priority,
                    excludeCompleted: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<TodoListSection> _buildExpandedListViewByFilter({
    required TodoListState state,
    required List<String?> sections,
    required Function filterCallback,
  }) {
    List<TodoListSection> items = [];
    for (var p in sections) {
      final Iterable<Todo> filteredList = filterCallback(p);
      // Hide sections with only completed todos inside.
      if (filteredList.isNotEmpty) {
        items.add(
          TodoListSection(
            title: p ?? "No priority",
            children: [
              for (var todo in filteredList) TodoTile(todo: todo),
            ],
          ),
        );
      }
    }

    return _appendCompleted(state, items);
  }

  List<TodoListSection> _appendCompleted(
      TodoListState state, List<TodoListSection> items) {
    final Iterable<Todo> filteredList = state.filteredByCompleted;
    // Hide sections if no completed todos inside.
    if (filteredList.isNotEmpty) {
      items.add(
        TodoListSection(
          title: "Done",
          children: [
            for (var todo in filteredList) TodoTile(todo: todo),
          ],
        ),
      );
    }

    return items;
  }
}

class TodoListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  TodoListSection({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: PageStorageKey<String>(title));

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: key,
      initiallyExpanded: true,
      shape: const Border.fromBorderSide(BorderSide.none),
      title: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: priorityChipColor,
            ),
            child: Text(title),
          ),
          Expanded(child: Container())
        ],
      ),
      children: children,
    );
  }
}

class TodoTile extends StatelessWidget {
  final Todo todo;

  TodoTile({
    required this.todo,
    Key? key,
  }) : super(key: PageStorageKey<int>(todo.id));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      leading: Checkbox(
        value: todo.completion,
        onChanged: (bool? completion) {
          context.read<TodoListBloc>().add(
                TodoListTodoCompletionToggled(
                  id: todo.id,
                  completion: completion,
                ),
              );
        },
      ),
      title: _buildDesription(),
      onTap: () => _onTapAction(context),
    );
  }

  Widget _buildDesription() {
    return Wrap(
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
          child: Text(todo.description),
        ),
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
    context.go(
      context.namedLocation(
        'todo-view',
        pathParameters: {
          'id': todo.id.toString(),
        },
      ),
    );
  }
}
