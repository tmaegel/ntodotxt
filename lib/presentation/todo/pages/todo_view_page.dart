import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/navigation_bar.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

class TodoViewPage extends StatelessWidget {
  final int index;

  const TodoViewPage({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TodoListRepository todoListRepository =
        context.read<TodoListRepository>();
    return BlocProvider(
      create: (context) => TodoBloc(
        todoListRepository: todoListRepository,
        index: index,
        todo: todoListRepository.getTodo(index),
      ),
      child: TodoViewView(todoListRepository: todoListRepository),
    );
  }
}

class TodoViewView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoViewView({
    required this.todoListRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
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
                Text(state.todo.description),
                _buildHeading("Priority"),
                _buildPriority(context, state),
                _buildHeading("Projects"),
                _buildProjects(context, state),
                _buildHeading("Contexts"),
                _buildContexts(context, state),
              ],
            ),
          ),
          floatingActionButton: screenWidth < maxScreenWidthCompact
              ? _buildFloatingActionButton(context, state)
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

  Widget _buildPriority(BuildContext context, TodoState state) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var p in todoListRepository.getAllPriorities())
          BasicChip(label: p, status: state.todo.priority == p),
      ],
    );
  }

  Widget _buildProjects(BuildContext context, TodoState state) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var p in state.todo.projects) BasicChip(label: p, status: true),
      ],
    );
  }

  Widget _buildContexts(BuildContext context, TodoState state) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var c in state.todo.contexts) BasicChip(label: c, status: true),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, TodoState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PrimaryFloatingActionButton(
          icon: state.todo.completion
              ? const Icon(Icons.remove_done)
              : const Icon(Icons.done),
          tooltip: state.todo.completion ? 'Undone' : 'Done',
          action: () => _secondaryAction(context, state),
        ),
        const SizedBox(height: 16),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          action: () => _primaryAction(context, state),
        ),
      ],
    );
  }

  /// Edit todo
  void _primaryAction(BuildContext context, TodoState state) {
    context.pushNamed(
      'todo-edit',
      pathParameters: {'index': state.index.toString()},
      extra: state.todo,
    );
  }

  /// Toggle completion
  void _secondaryAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoCompletionChanged(!state.todo.completion));
  }

  /// Cancel current view process
  void _cancelAction(BuildContext context) {
    context.pop();
  }
}
