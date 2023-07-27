import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/navigation_bar.dart';
import 'package:ntodotxt/constants/placeholder.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class TodoViewPage extends StatelessWidget {
  final int todoIndex;

  const TodoViewPage({required this.todoIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<TodoListCubit, List<Todo>>(
      buildWhen: (List<Todo> previousState, List<Todo> state) {
        // Rebuild if this todo entry is changed only.
        if (previousState[todoIndex] != state[todoIndex]) {
          return true;
        } else {
          return false;
        }
      },
      builder: (BuildContext context, List<Todo> state) {
        final Todo todo = state[todoIndex];
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
                _buildHeading("Todo"),
                Text(todo.completion
                    ? '${todo.description} (DONE)'
                    : todo.description),
                _buildHeading("Priority"),
                _buildPriority(context, todo),
                _buildHeading("Projects"),
                _buildProjects(context, todo),
                _buildHeading("Contexts"),
                _buildContexts(context, todo),
              ],
            ),
          ),
          floatingActionButton: screenWidth < maxScreenWidthCompact
              ? _buildFloatingActionButton(context, todo)
              : null,
        );
      },
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

  Widget _buildPriority(BuildContext context, Todo todo) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var p in priorities)
          BasicChip(label: p, status: todo.priority == p)
      ],
    );
  }

  Widget _buildProjects(BuildContext context, Todo todo) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var p in todo.projects) BasicChip(label: p, status: true)
      ],
    );
  }

  Widget _buildContexts(BuildContext context, Todo todo) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var c in todo.contexts) BasicChip(label: c, status: true)
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, Todo todo) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PrimaryFloatingActionButton(
          icon: todo.completion
              ? const Icon(Icons.remove_done)
              : const Icon(Icons.done),
          tooltip: todo.completion ? 'Undone' : 'Done',
          action: () => _secondaryAction(context),
        ),
        const SizedBox(height: 16),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          action: () => _primaryAction(context),
        ),
      ],
    );
  }

  /// Edit todo
  void _primaryAction(BuildContext context) {
    context.read<TodoCubit>().edit(index: todoIndex);
    context.push(context.namedLocation('todo-edit',
        pathParameters: {'todoIndex': todoIndex.toString()}));
  }

  /// Toggle completion
  void _secondaryAction(BuildContext context) =>
      context.read<TodoListCubit>().toggleCompletion(index: todoIndex);

  /// Cancel current view process
  void _cancelAction(BuildContext context) {
    context.read<TodoCubit>().back();
    context.pop();
  }
}
