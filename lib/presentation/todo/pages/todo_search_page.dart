import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/common_widgets/app_bar.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

class TodoSearchPage extends StatelessWidget {
  const TodoSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Search",
        icon: const Icon(Icons.arrow_back),
        action: () => _cancelAction(context),
      ),
      body: const Center(
        child: Text('Searching ...'),
      ),
    );
  }

  void _cancelAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }
}
