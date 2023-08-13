import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/todo.dart';
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
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "View",
            leadingAction: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelAction(context),
            ),
            toolbar: _buildToolBar(context, state),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Subheader(title: "Todo"),
                Text(state.todo.description),
                const Subheader(title: "Priority"),
                GenericChipGroup(
                  children: [
                    for (var p in priorities)
                      GenericChip(
                        label: p,
                        selected: state.todo.priority == p,
                        color: priorityChipColor[p],
                      ),
                  ],
                ),
                const Subheader(title: "Projects"),
                GenericChipGroup(
                  children: [
                    for (var p in state.todo.projects)
                      GenericChip(
                        label: p,
                        selected: true,
                        color: projectChipColor,
                      ),
                  ],
                ),
                const Subheader(title: "Contexts"),
                GenericChipGroup(
                  children: [
                    for (var c in state.todo.contexts)
                      GenericChip(
                        label: c,
                        selected: true,
                        color: contextChipColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit),
          onPressed: () => _editAction(context, state),
        ),
      ],
    );
  }

  /// Edit current todo
  void _editAction(BuildContext context, TodoState state) {
    context.go(
      context.namedLocation(
        'todo-edit',
        pathParameters: {
          'index': state.index.toString(),
        },
      ),
    );
  }

  /// Toggle completion
  void _toggleAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoCompletionToggled(!state.todo.completion));
  }

  /// Cancel current view process
  void _cancelAction(BuildContext context) {
    context.go(context.namedLocation('todo-list'));
  }
}
