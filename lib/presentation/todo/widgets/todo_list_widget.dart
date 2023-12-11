import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tile_widget.dart';

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
    context.pushNamed('todo-edit', extra: todo);
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
                _buildTodoListTile(context, todo, isSelected),
            ],
          ),
        );
      }
    }

    return items;
  }

  TodoListTile _buildTodoListTile(
      BuildContext context, Todo todo, bool isSelected) {
    return TodoListTile(
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
    );
  }
}
