import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/navigation_bar.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: BlocBuilder<TodoListCubit, List<Todo>>(
        builder: (BuildContext context, List<Todo> state) {
          return _buildList(state);
        },
      ),
      floatingActionButton: screenWidth < maxScreenWidthCompact
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  /// Add new todo
  void _primaryAction(BuildContext context) {
    context.read<TodoCubit>().create();
    context.push(context.namedLocation('todo-create'));
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () => _primaryAction(context),
    );
  }

  Widget _buildList(List<Todo> state) {
    return ListView(
      children: [
        _buildSearchBar(),
        for (var i = 0; i < state.length; i++)
          TodoTile(todoIndex: i, todo: state[i])
      ],
    );
  }

  Widget _buildSearchBar() {
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

class TodoTile extends StatelessWidget {
  final int todoIndex;
  final Todo todo;

  const TodoTile({required this.todoIndex, required this.todo, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
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
        onChanged: (bool? value) {
          context.read<TodoListCubit>().toggleCompletion(index: todoIndex);
        },
      ),
      onTap: () {
        context.read<TodoCubit>().view(index: todoIndex);
        // Replace the navigation stack if the wide layout is used.
        if (screenWidth < maxScreenWidthCompact) {
          context.push(context.namedLocation('todo-view',
              pathParameters: {'todoIndex': todoIndex.toString()}));
        } else {
          context.go(context.namedLocation('todo-view',
              pathParameters: {'todoIndex': todoIndex.toString()}));
        }
      },
    );
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
