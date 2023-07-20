import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/common_widgets/app_bar.dart';
import 'package:todotxt/common_widgets/navigation_bar.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

class TodoAddPage extends StatelessWidget {
  const TodoAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MainAppBar(
        title: "Add",
        icon: const Icon(Icons.close),
        action: () => _cancelAction(context),
      ),
      body: const Center(
        child: Text('Adding todo'),
      ),
      floatingActionButton: screenWidth < maxScreenWidthCompact
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  /// Save new todo
  void _primaryAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }

  void _cancelAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => _primaryAction(context),
    );
  }
}
