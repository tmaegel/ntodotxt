import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/common_widgets/app_bar.dart';
import 'package:todotxt/common_widgets/navigation_bar.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

class TodoEditPage extends StatelessWidget {
  final String? todoIndex;

  const TodoEditPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MainAppBar(
        title: "Edit",
        icon: const Icon(Icons.close),
        action: () => _cancelAction(context),
        toolbar: _buildToolBar(context),
      ),
      body: Center(
        child: Text('Editing todo $todoIndex'),
      ),
      floatingActionButton: screenWidth < maxScreenWidthCompact
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  /// Save current todo
  void _primaryAction(BuildContext context) {
    context.read<TodoCubit>().view(index: int.parse(todoIndex!));
    context.pop();
  }

  void _deleteAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }

  void _cancelAction(BuildContext context) {
    context.read<TodoCubit>().view(index: int.parse(todoIndex!));
    context.pop();
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => _primaryAction(context),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteAction(context),
        ),
      ],
    );
  }
}
