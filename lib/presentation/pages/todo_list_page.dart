import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

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
  final String title = "Todo List";

  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < maxScreenWidthCompact) {
      return _buildCompactPage();
    } else {
      return _buildExtendedPage();
    }
  }

  Widget _buildCompactPage() {
    return Scaffold(
      appBar: MainAppBar(title: title, showToolBar: true),
      body: ListView(children: [
        for (var i = 0; i < Todo.todos.length; i++) TodoTile(todoIndex: i)
      ]),
    );
  }

  Widget _buildExtendedPage() {
    return Row(
      children: [
        Expanded(
          child: ListView(children: [
            for (var i = 0; i < Todo.todos.length; i++) TodoTile(todoIndex: i)
          ]),
        ),
        const Expanded(
          child: Card(
            shadowColor: Colors.transparent,
            child: Center(child: Text("Details")),
          ),
        ),
      ],
    );
  }
}

class TodoTile extends StatelessWidget {
  final int todoIndex;

  const TodoTile({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
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
        context.push(context.namedLocation('todo-details',
            pathParameters: {'todoIndex': todoIndex.toString()}));
      },
    );
  }
}
