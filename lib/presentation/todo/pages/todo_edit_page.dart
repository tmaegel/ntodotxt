import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_cubit.dart';

class TodoEditPage extends StatelessWidget {
  final int index;

  const TodoEditPage({
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
      child: TodoEditView(todoListRepository: todoListRepository),
    );
  }
}

class TodoEditView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoEditView({
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
            title: "Edit",
            leadingAction: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelAction(context, state),
            ),
            toolbar: _buildToolBar(context, state),
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
                  controller: TextEditingController()
                    ..text = state.todo.description,
                ),
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
              ? _buildFloatingActionButton(context)
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
          BasicChip(label: p, status: p == state.todo.priority),
      ],
    );
  }

  Widget _buildProjects(BuildContext context, TodoState state) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var p in todoListRepository.getAllProjects())
          BasicChip(label: p, status: state.todo.projects.contains(p)),
      ],
    );
  }

  Widget _buildContexts(BuildContext context, TodoState state) {
    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        for (var c in todoListRepository.getAllContexts())
          BasicChip(label: c, status: state.todo.contexts.contains(c)),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => _primaryAction(context),
    );
  }

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteAction(context, state),
        ),
      ],
    );
  }

  /// Save current todo
  void _primaryAction(BuildContext context) {
    // context.read<TodoBloc>().add(TodoSubmitted(!state.todo.completion));
    context.pop();
  }

  /// Delete current todo
  void _deleteAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoDeleted(state.index));
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current edit process
  void _cancelAction(BuildContext context, TodoState state) {
    context.read<TodoModeCubit>().view(state.index);
    context.pop();
  }
}
