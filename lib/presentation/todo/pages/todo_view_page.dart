import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_cubit.dart';

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
            leadingAction: screenWidth < maxScreenWidthCompact
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _cancelAction(context),
                  )
                : null,
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
                  chips: [
                    for (var p in todoListRepository.getAllPriorities())
                      ChipEntity(label: p, selected: state.todo.priority == p),
                  ],
                ),
                const Subheader(title: "Projects"),
                GenericChipGroup(
                  chips: [
                    for (var p in state.todo.projects)
                      ChipEntity(label: p, selected: true),
                  ],
                ),
                const Subheader(title: "Contexts"),
                GenericChipGroup(
                  chips: [
                    for (var c in state.todo.contexts)
                      ChipEntity(label: c, selected: true),
                  ],
                ),
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
    context.read<TodoBloc>().add(TodoCompletionToggled(!state.todo.completion));
  }

  /// Cancel current view process
  void _cancelAction(BuildContext context) {
    context.read<TodoModeCubit>().list();
    context.go(context.namedLocation('todo-list'));
  }
}
