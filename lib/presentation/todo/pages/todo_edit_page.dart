import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/common_widgets/app_bar.dart';
import 'package:todotxt/common_widgets/chip.dart';
import 'package:todotxt/common_widgets/navigation_bar.dart';
import 'package:todotxt/constants/placeholder.dart';
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
            TextField(
              minLines: 3,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xfff1f1f1),
              ),
            ),
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
