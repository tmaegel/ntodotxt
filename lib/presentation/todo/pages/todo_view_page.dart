import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/common_widgets/app_bar.dart';
import 'package:todotxt/common_widgets/chip.dart';
import 'package:todotxt/common_widgets/navigation_bar.dart';
import 'package:todotxt/constants/placeholder.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Todo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text('<todo_placeholder>'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Priority",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: <Widget>[
                for (var p in priorities) ActionChoiceChip(label: p)
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Projects",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: <Widget>[
                for (var p in projects) ActionChoiceChip(label: p)
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Contexts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: <Widget>[
                for (var c in contexts) ActionChoiceChip(label: c)
              ],
            ),
          ],
        ),
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
