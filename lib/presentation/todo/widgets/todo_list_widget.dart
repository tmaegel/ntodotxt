import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tile_widget.dart';

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
      shape: const Border(),
      title: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      children: children,
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                children: _buildExpandedListView(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  void _viewAction(BuildContext context, Todo todo) {
    context.pushNamed("todo-view", extra: todo);
  }

  void _toggleCompletionAction(
      BuildContext context, Todo todo, bool? completion) {
    context.read<TodoListBloc>().add(
          TodoListTodoCompletionToggled(
            todo: todo,
            completion: completion ?? false,
          ),
        );
  }

  void _toggleSelectionAction(BuildContext context, Todo todo) {
    context.read<TodoListBloc>().add(
          TodoListTodoSelectedToggled(
            todo: todo,
            selected: !todo.selected,
          ),
        );
  }

  List<TodoListSection> _buildExpandedListView(
      BuildContext context, TodoListState state) {
    final bool isSelected = state.isSelected;
    List<TodoListSection> items = [];
    for (var section in state.groupedByTodoList.keys) {
      final Iterable<Todo>? todoList = state.groupedByTodoList[section];
      if (todoList != null) {
        items.add(
          TodoListSection(
            title: section,
            children: [
              for (var todo in todoList)
                TodoTile(
                  todo: todo,
                  selected: todo.selected,
                  onTap: () {
                    isSelected
                        ? _toggleSelectionAction(context, todo)
                        : _viewAction(context, todo);
                  },
                  onChange: (bool? completion) =>
                      _toggleCompletionAction(context, todo, completion),
                  onLongPress: () => _toggleSelectionAction(context, todo),
                ),
            ],
          ),
        );
      }
    }

    return items;
  }
}
