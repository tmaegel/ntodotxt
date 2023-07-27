import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/navigation_bar.dart';
import 'package:ntodotxt/constants/placeholder.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

class TodoCreatePage extends StatelessWidget {
  const TodoCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: MainAppBar(
        title: "Create",
        icon: const Icon(Icons.close),
        action: () => _cancelAction(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeading("Todo"),
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
            _buildHeading("Priority"),
            _buildPriority(context),
            _buildHeading("Projects"),
            _buildProjects(context),
            _buildHeading("Contexts"),
            _buildContexts(context),
          ],
        ),
      ),
      floatingActionButton: screenWidth < maxScreenWidthCompact
          ? _buildFloatingActionButton(context)
          : null,
    );
  }

  Widget _buildHeading(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriority(BuildContext context) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[for (var p in priorities) ActionChoiceChip(label: p)],
    );
  }

  Widget _buildProjects(BuildContext context) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[for (var p in projects) ActionChoiceChip(label: p)],
    );
  }

  Widget _buildContexts(BuildContext context) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[for (var c in contexts) ActionChoiceChip(label: c)],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => _primaryAction(context),
    );
  }

  /// Save new todo
  void _primaryAction(BuildContext context) {
    context.read<TodoCubit>().reset();
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current create process
  void _cancelAction(BuildContext context) {
    context.read<TodoCubit>().back();
    context.pop();
  }
}
