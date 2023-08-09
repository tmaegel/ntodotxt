import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_cubit.dart';

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

class TodoListNarrowView extends StatelessWidget {
  const TodoListNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const TodoList(),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () => _primaryAction(context),
    );
  }

  /// Add new todo
  void _primaryAction(BuildContext context) {
    context.push(context.namedLocation('todo-create'));
  }
}

class TodoListWideView extends StatelessWidget {
  const TodoListWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TodoList(),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        return ListView(
          children: [
            const SearchBar(),
            for (var i = 0; i < state.todoList.length; i++)
              TodoTile(index: i, todo: state.todoList[i])
          ],
        );
      },
    );
  }
}

class TodoTile extends StatelessWidget {
  final int index;
  final Todo todo;

  const TodoTile({
    required this.index,
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.description),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (var project in todo.projects)
            BasicChip(label: project, status: true),
          for (var context in todo.contexts)
            BasicChip(label: context, status: true),
        ],
      ),
      leading: _buildPriority(todo.priority),
      trailing: Checkbox(
        value: todo.completion,
        onChanged: (bool? completion) {
          context.read<TodoListBloc>().add(
                TodoListTodoCompletionToggled(
                  index: index,
                  completion: completion,
                ),
              );
        },
      ),
      onTap: () => _onTapAction(context),
    );
  }

  void _onTapAction(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    context.read<TodoModeCubit>().view(index);
    // Replace the navigation stack if the wide layout is used.
    if (screenWidth < maxScreenWidthCompact) {
      context.push(
        context.namedLocation(
          'todo-view',
          pathParameters: {'index': index.toString()},
        ),
      );
    } else {
      // @todo: go doesn't work here
      context.push(
        context.namedLocation(
          'todo-view',
          pathParameters: {'index': index.toString()},
        ),
      );
    }
  }

  Widget? _buildPriority(String? value) {
    final Color avatarColor;
    switch (value) {
      case 'A':
        avatarColor = Colors.redAccent.shade100;
        break;
      case 'B':
        avatarColor = Colors.purpleAccent.shade100;
        break;
      case 'C':
        avatarColor = Colors.orangeAccent.shade100;
        break;
      case 'D':
        avatarColor = Colors.blueAccent.shade100;
        break;
      case 'E':
        avatarColor = Colors.greenAccent.shade100;
        break;
      case 'F':
        avatarColor = Colors.grey.shade300;
        break;
      default:
        avatarColor = Colors.transparent;
    }

    return CircleAvatar(
      backgroundColor: avatarColor,
      child: Text(value ?? ""),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xfff1f1f1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          hintText: "Search",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
