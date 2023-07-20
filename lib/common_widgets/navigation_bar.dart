import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/presentation/todo/states/todo.dart';

class PrimaryNavigationRail extends StatelessWidget {
  const PrimaryNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: null,
      extended: false,
      leading: _buildFloatingActionButton(context),
      groupAlignment: 1.0,
      destinations: _buildDestinations(),
      onDestinationSelected: (int index) {
        switch (index) {
          case 0: // Manage todos
            context.read<TodoCubit>().reset();
            context.go(context.namedLocation('todo-list'));
            break;
          case 1: // Manage shortcuts
            context.read<TodoCubit>().reset();
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

  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is TodoViewing) {
          return _buildViewActions(context, state);
        } else if (state is TodoEditing) {
          return _buildEditActions(context, state);
        } else if (state is TodoCreating) {
          return _buildCreateActions(context);
        } else if (state is TodoInitial) {
          return _buildListActions(context);
        } else {
          return _buildListActions(context);
        }
      },
    );
  }

  Widget _buildListActions(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () {
        // @todo: Check for shortcut or todo mode late.
        context.read<TodoCubit>().create();
        context.push(context.namedLocation('todo-create'));
      },
    );
  }

  Widget _buildViewActions(BuildContext context, TodoState state) {
    return Column(
      children: [
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.done),
          tooltip: 'Done',
          action: () {
            // @todo: Check for shortcut or todo mode late.
            context.read<TodoCubit>().reset();
            context.go(context.namedLocation('todo-list'));
          },
        ),
        const SizedBox(height: 8),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit',
          mini: true,
          hideColor: true,
          action: () {
            final index = state.index!;
            context.read<TodoCubit>().edit(index: index);
            context.push(context.namedLocation('todo-edit',
                pathParameters: {'todoIndex': index.toString()}));
          },
        ),
      ],
    );
  }

  Widget _buildEditActions(BuildContext context, TodoState state) {
    return Column(
      children: [
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.save),
          tooltip: 'Save',
          action: () {
            final int index = state.index!;
            context.read<TodoCubit>().view(index: index);
            context.pop();
          },
        ),
        const SizedBox(height: 8),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          mini: true,
          hideColor: true,
          action: () {
            context.read<TodoCubit>().reset();
            context.go(context.namedLocation('todo-list'));
          },
        ),
        const SizedBox(height: 8),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          mini: true,
          hideColor: true,
          action: () {
            context.read<TodoCubit>().reset();
            context.go(context.namedLocation('todo-list'));
          },
        ),
      ],
    );
  }

  Widget _buildCreateActions(BuildContext context) {
    return Column(
      children: [
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.save),
          tooltip: 'Save',
          action: () {
            context.read<TodoCubit>().reset();
            context.pop();
          },
        ),
        const SizedBox(height: 8),
        PrimaryFloatingActionButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          mini: true,
          hideColor: true,
          action: () {
            context.read<TodoCubit>().reset();
            context.go(context.namedLocation('todo-list'));
          },
        ),
      ],
    );
  }
}

class PrimaryFloatingActionButton extends StatelessWidget {
  final String tooltip;
  final Icon icon;
  final Function action;
  final bool mini;
  final bool hideColor;

  const PrimaryFloatingActionButton({
    required this.icon,
    required this.tooltip,
    required this.action,
    this.mini = false,
    this.hideColor = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'tag-$tooltip',
      mini: mini,
      backgroundColor: hideColor ? Colors.white70 : null,
      elevation: 0.0,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      tooltip: tooltip,
      onPressed: () => action(),
      child: icon,
    );
  }
}
