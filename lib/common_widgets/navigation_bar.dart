import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_mode_state.dart';

class PrimaryNavigationRail extends StatelessWidget {
  const PrimaryNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: null,
      extended: false,
      leading: _buildActionButtons(context),
      groupAlignment: 1.0,
      destinations: _buildDestinations(),
      onDestinationSelected: (int index) {
        switch (index) {
          case 0: // Manage todos
            context.read<TodoModeCubit>().list();
            context.go(context.namedLocation('todo-list'));
            break;
          case 1: // Manage shortcuts
            // context.push(context.namedLocation('shortcut-list'));
            break;
          default:
        }
      },
    );
  }

  List<NavigationRailDestination> _buildDestinations() {
    return [
      const NavigationRailDestination(
        label: Text('Manage todos'),
        icon: Icon(Icons.rule),
      ),
      const NavigationRailDestination(
        label: Text('Manage shortcuts'),
        icon: Icon(Icons.auto_awesome),
      ),
    ];
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<TodoModeCubit, TodoModeState>(
      builder: (BuildContext context, TodoModeState state) {
        switch (state.status) {
          case TodoModeStatus.view:
            return Column(
              children: [
                _buildCreateActionButton(context),
                const SizedBox(height: 8),
                _buildEditActionButton(context, state),
              ],
            );
          case TodoModeStatus.create:
            return Column(
              children: [
                _buildSaveActionButton(context, state),
              ],
            );
          case TodoModeStatus.edit:
            return Column(
              children: [
                _buildSaveActionButton(context, state),
                const SizedBox(height: 8),
                _buildDoneActionButton(context, state),
                const SizedBox(height: 8),
                _buildDeleteActionButton(context, state),
              ],
            );
          default:
            return _buildCreateActionButton(context);
        }
      },
    );
  }

  Widget _buildCreateActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Create',
      action: () {
        context.read<TodoModeCubit>().create();
        context.push(context.namedLocation('todo-create'));
      },
    );
  }

  Widget _buildEditActionButton(BuildContext context, TodoModeState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Edit',
      action: () {
        final index = state.index!;
        context.read<TodoModeCubit>().edit(index);
        context.push(
          context.namedLocation(
            'todo-edit',
            pathParameters: {'index': index.toString()},
          ),
        );
      },
    );
  }

  Widget _buildSaveActionButton(BuildContext context, TodoModeState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () {
        final index = state.index;
        if (index == null) {
          context
              .read<TodoModeCubit>()
              .list(); // @todo: Go to view of created todo here.
          context.go(context.namedLocation('todo-list'));
        } else {
          context.read<TodoModeCubit>().view(index);
          context.pop();
        }
      },
    );
  }

  Widget _buildDoneActionButton(BuildContext context, TodoModeState state) {
    return IconButton(
      tooltip: 'Mark as done',
      icon: const Icon(Icons.done_all),
      onPressed: () {
        final index = state.index!;
        context
            .read<TodoListBloc>()
            .add(TodoListTodoCompletionToggled(index: index));
      },
    );
  }

  Widget _buildDeleteActionButton(BuildContext context, TodoModeState state) {
    return IconButton(
      tooltip: 'Delete',
      icon: const Icon(Icons.delete),
      onPressed: () {
        final index = state.index!;
        context.read<TodoListBloc>().add(TodoListTodoDeleted(index: index));
        context.go(context.namedLocation('todo-list'));
      },
    );
  }
}
