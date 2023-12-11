import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
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

  List<TodoListSection> _buildExpandedListView(
      BuildContext context, TodoListState state) {
    List<TodoListSection> items = [];
    for (var section in state.groupedByTodoList.keys) {
      final Iterable<Todo>? todoList = state.groupedByTodoList[section];
      if (todoList != null) {
        items.add(
          TodoListSection(
            title: section,
            children: [
              for (var todo in todoList)
                TodoListTile(
                  todo: todo,
                  isAnySelected: state.isAnySelected,
                )
            ],
          ),
        );
      }
    }

    return items;
  }
}
