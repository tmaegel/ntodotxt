import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/common_widgets/app_bar.dart';
import 'package:todotxt/common_widgets/navigation_bar.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

class TodoViewPage extends StatelessWidget {
  final String? todoIndex;

  const TodoViewPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MainAppBar(
        title: "View",
        icon: const Icon(Icons.arrow_back),
        action: () => _cancelAction(context),
      ),
      body: Center(
        child: Text('Viewing todo $todoIndex'),
      ),
      floatingActionButton: screenWidth < maxScreenWidthCompact
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  /// Edit todo
  void _primaryAction(BuildContext context) {
    context.read<TodoCubit>().edit(index: int.parse(todoIndex!));
    context.push(context.namedLocation('todo-edit',
        pathParameters: {'todoIndex': todoIndex.toString()}));
  }

  /// Mark todo as done
  void _secondaryAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }

  void _cancelAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          mini: true,
          action: () => _primaryAction(context),
        ),
        const SizedBox(height: 16),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.done),
          tooltip: 'Done',
          action: () => _secondaryAction(context),
        ),
      ],
    );
  }
}
