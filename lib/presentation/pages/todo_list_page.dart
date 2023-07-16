import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';
import 'package:todotxt/todo/cubit/todo.dart';

class Todo {
  final String title;
  final String subtitle;
  final String priority;

  Todo(this.title, this.subtitle, this.priority);

  static List<Todo> todos = [
    Todo("Call mom", "@smartphone", "A"),
    Todo("Go to the school", "@school", "A"),
    Todo("Do nothing", "@home +chill", "B"),
    Todo("Working on app", "@home", "C"),
    Todo("Eating something", "@home", "F"),
  ];
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: screenWidth < maxScreenWidthCompact
          ? const MainAppBar(showToolBar: true)
          : null,
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return ListView(
      children: [
        for (var i = 0; i < Todo.todos.length; i++) TodoTile(todoIndex: i)
      ],
    );
  }
}

class TodoTile extends StatelessWidget {
  final int todoIndex;

  const TodoTile({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      title: Text(
        Todo.todos[todoIndex].title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
      subtitle: Text(Todo.todos[todoIndex].subtitle),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            Todo.todos[todoIndex].priority,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ],
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
}
