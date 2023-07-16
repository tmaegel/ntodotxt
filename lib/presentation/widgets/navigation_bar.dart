import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:todotxt/todo/cubit/todo.dart';

class PrimaryNavigationRail extends StatelessWidget {
  const PrimaryNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        return NavigationRail(
          selectedIndex: null,
          destinations: _buildDestinations(state),
          extended: false,
          leading: const PrimaryFloatingActionButton(),
        );
      },
    );
  }

  List<NavigationRailDestination> _buildDestinations(TodoState state) {
    switch (state.status) {
      case TodoStatus.viewing:
        return _viewDestinations();
      case TodoStatus.creating:
      case TodoStatus.editing:
        return _addEditDestinations();
      default:
        return _listDestinations();
    }
  }

  List<NavigationRailDestination> _listDestinations() {
    return [
      const NavigationRailDestination(
        label: Text('Shortcut 1'),
        icon: Icon(Icons.star_outline),
      ),
      const NavigationRailDestination(
        label: Text('Shortcut 2'),
        icon: Icon(Icons.star_outline),
      ),
    ];
  }

  List<NavigationRailDestination> _viewDestinations() {
    return [
      const NavigationRailDestination(
        label: Text('Mark as done'),
        icon: Icon(Icons.rule),
      ),
      const NavigationRailDestination(
        label: Text('Delete'),
        icon: Icon(Icons.delete_outline),
      ),
    ];
  }

  List<NavigationRailDestination> _addEditDestinations() {
    return [
      const NavigationRailDestination(
        label: Text('Project'),
        icon: Icon(Icons.outlined_flag),
      ),
      const NavigationRailDestination(
        label: Text('Context'),
        icon: Icon(Icons.label_outline),
      ),
      const NavigationRailDestination(
        label: Text('Due date'),
        icon: Icon(Icons.alarm),
      ),
    ];
  }
}

class PrimaryFloatingActionButton extends StatelessWidget {
  const PrimaryFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        return FloatingActionButton(
          elevation: 0.0,
          focusElevation: 0.0,
          hoverElevation: 0.0,
          tooltip: _tooltip(state),
          onPressed: () {
            switch (state.status) {
              case TodoStatus.viewing:
                _editAction(context, state.index!);
                break;
              case TodoStatus.creating:
              case TodoStatus.editing:
                _saveAction(context, state.index);
                break;
              default:
                _addAction(context);
                break;
            }
          },
          child: _icon(state),
        );
      },
    );
  }

  void _saveAction(BuildContext context, int? index) {
    if (index == null) {
      context.read<TodoCubit>().reset();
    } else {
      context.read<TodoCubit>().view(index: index);
    }
    context.pop();
  }

  void _addAction(BuildContext context) {
    context.read<TodoCubit>().create();
    context.push(context.namedLocation('todo-add'));
  }

  void _editAction(BuildContext context, int index) {
    context.read<TodoCubit>().edit(index: index);
    context.push(context.namedLocation('todo-edit',
        pathParameters: {'todoIndex': index.toString()}));
  }

  Icon _icon(TodoState state) {
    switch (state.status) {
      case TodoStatus.viewing:
        return const Icon(Icons.edit);
      case TodoStatus.creating:
      case TodoStatus.editing:
        return const Icon(Icons.check);
      default:
        return const Icon(Icons.add);
    }
  }

  String _tooltip(TodoState state) {
    switch (state.status) {
      case TodoStatus.viewing:
        return 'Edit';
      case TodoStatus.creating:
      case TodoStatus.editing:
        return 'Save';
      default:
        return 'Add';
    }
  }
}

class PrimaryBottomAppBar extends StatelessWidget {
  const PrimaryBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        switch (state.status) {
          case TodoStatus.viewing:
            return _viewBottomAppBar(context);
          case TodoStatus.creating:
          case TodoStatus.editing:
            return _addEditBottomAppBar(context);
          default:
            return _listBottomAppBar(context);
        }
      },
    );
  }

  Widget _listBottomAppBar(BuildContext context) {
    return const BottomAppBar(
      child: Row(
        children: <Widget>[],
      ),
    );
  }

  Widget _viewBottomAppBar(BuildContext context) {
    return const BottomAppBar(
      child: Row(
        children: <Widget>[],
      ),
    );
  }

  Widget _addEditBottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Due date',
            icon: const Icon(Icons.alarm),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Context',
            icon: const Icon(Icons.outlined_flag),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Project',
            icon: const Icon(Icons.label_outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
