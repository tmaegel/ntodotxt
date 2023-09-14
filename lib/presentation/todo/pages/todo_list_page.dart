import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/navigation_drawer.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_search_page.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < maxScreenWidthCompact) {
      return const TodoListNarrowView();
    } else {
      return const TodoListWideView();
    }
  }
}

abstract class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  /// Switch todo list ordering.
  void _orderAction(BuildContext context) {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) => const OrderDialog(),
    );
  }

  /// Switch todo list filter.
  void _filterAction(BuildContext context) {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) => const FilterDialog(),
    );
  }

  /// Switch todo group by view.
  void _groupByAction(BuildContext context) {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) => const GroupByDialog(),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () => context.push(
        context.namedLocation('todo-create'),
      ),
    );
  }

  Widget _buildPrimaryToolBarActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Group by',
          icon: const Icon(Icons.widgets),
          onPressed: () => _groupByAction(context),
        ),
        IconButton(
          tooltip: 'Sort',
          icon: const Icon(Icons.sort_by_alpha),
          onPressed: () => _orderAction(context),
        ),
        IconButton(
          tooltip: 'Filter',
          icon: const Icon(Icons.filter_alt),
          onPressed: () => _filterAction(context),
        ),
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: TodoSearchPage(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecondaryToolBarActions(
      BuildContext context, TodoListState state) {
    final bool isSelectedCompleted = state.isSelectedCompleted;
    return Row(
      children: [
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () {
            context.read<TodoListBloc>().add(const TodoListSelectionDeleted());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                content: const Text('Todos deleted.'),
              ),
            );
          },
        ),
        isSelectedCompleted
            ? IconButton(
                tooltip: 'Mark as undone',
                icon: const Icon(Icons.remove_done),
                onPressed: () {
                  context
                      .read<TodoListBloc>()
                      .add(const TodoListSelectionIncompleted());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      content: const Text('Mark todos as undone.'),
                    ),
                  );
                },
              )
            : IconButton(
                tooltip: 'Mark as done',
                icon: const Icon(Icons.done_all),
                onPressed: () {
                  context
                      .read<TodoListBloc>()
                      .add(const TodoListSelectionCompleted());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      content: const Text('Mark todos as done.'),
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class TodoListNarrowView extends TodoListView {
  const TodoListNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Todos",
      ),
      body: const TodoList(),
      drawer: const ResponsiveNavigationDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: PrimaryBottomAppBar(
        children: [
          BlocBuilder<TodoListBloc, TodoListState>(
            buildWhen: (TodoListState previousState, TodoListState state) {
              // Rebuild if selection has changed only.
              return previousState.isSelected != state.isSelected;
            },
            builder: (BuildContext context, TodoListState state) {
              if (state.isSelected) {
                return _buildSecondaryToolBarActions(context, state);
              } else {
                return _buildPrimaryToolBarActions(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class TodoListWideView extends TodoListView {
  const TodoListWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Todos",
        toolbar: BlocBuilder<TodoListBloc, TodoListState>(
          buildWhen: (TodoListState previousState, TodoListState state) {
            // Rebuild if selection has changed only.
            return previousState.isSelected != state.isSelected;
          },
          builder: (BuildContext context, TodoListState state) {
            if (state.isSelected) {
              return _buildSecondaryToolBarActions(context, state);
            } else {
              return _buildPrimaryToolBarActions(context);
            }
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      body: const TodoList(),
    );
  }
}
