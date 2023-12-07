import 'package:flutter/gestures.dart';
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
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';

class Action {
  final String label;
  final Function action;
  final IconData? icon;

  const Action({
    required this.label,
    required this.action,
    this.icon,
  });
}

List<Action> appBarActions = <Action>[
  Action(
    label: 'Search',
    icon: Icons.search,
    action: (BuildContext context) {
      showSearch(
        context: context,
        delegate: TodoSearchPage(),
      );
    },
  ),
  Action(
    label: 'Sort',
    action: (BuildContext context) async {
      context.read<TodoListBloc>().add(
            TodoListOrderChanged(
              order: await showModalBottomSheet<TodoListOrder?>(
                context: context,
                builder: (BuildContext context) =>
                    const OrderTodoListBottomSheet(),
              ),
            ),
          );
    },
  ),
  Action(
    label: 'Filter',
    action: (BuildContext context) async {
      context.read<TodoListBloc>().add(
            TodoListFilterChanged(
              filter: await showModalBottomSheet<TodoListFilter?>(
                context: context,
                builder: (BuildContext context) =>
                    const FilterTodoListBottomSheet(),
              ),
            ),
          );
    },
  ),
  Action(
    label: 'Group by',
    action: (BuildContext context) async {
      context.read<TodoListBloc>().add(
            TodoListGroupByChanged(
              group: await showModalBottomSheet<TodoListGroupBy?>(
                context: context,
                builder: (BuildContext context) =>
                    const GroupByTodoListBottomSheet(),
              ),
            ),
          );
    },
  ),
];

Action primaryAddTodoAction = Action(
  label: 'Add todo',
  icon: Icons.add,
  action: (BuildContext context) {
    context.push(
      context.namedLocation('todo-create'),
    );
  },
);

Action selectionDeleteAction = Action(
  label: 'Delete',
  icon: Icons.delete,
  action: (BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListSelectionDeleted());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: const Text('Todos deleted.'),
      ),
    );
  },
);

Action selectionMarkAsDoneAction = Action(
  label: 'Mark as done',
  icon: Icons.done_all,
  action: (BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListSelectionCompleted());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: const Text('Mark todos as done.'),
      ),
    );
  },
);

Action selectionMarkAsUndoneAction = Action(
  label: 'Mark as undone',
  icon: Icons.remove_done,
  action: (BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListSelectionIncompleted());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: const Text('Mark todos as undone.'),
      ),
    );
  },
);

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocListener<TodoListBloc, TodoListState>(
      listener: (BuildContext context, TodoListState state) {
        // Catch errors on the highes possible layer.
        if (state is TodoListError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text(state.message),
            ),
          );
        }
      },
      child: screenWidth < maxScreenWidthCompact
          ? TodoListNarrowView()
          : TodoListWideView(),
    );
  }
}

abstract class TodoListView extends StatelessWidget {
  final ScrollController controller = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  TodoListView({
    super.key,
  });

  bool get isNarrowLayout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if selection has changed only.
        return previousState.isSelected != state.isSelected;
      },
      builder: (BuildContext context, TodoListState state) {
        return Scaffold(
          appBar: MainAppBar(
            title: 'Todos',
            toolbar: Row(
              children: [
                IconButton(
                  tooltip: appBarActions[0].label,
                  icon: Icon(appBarActions[0].icon),
                  onPressed: () => appBarActions[0].action(context),
                ),
                PopupMenuButton<Action>(
                  itemBuilder: (BuildContext context) {
                    return appBarActions.skip(1).map(
                      (Action item) {
                        return PopupMenuItem<Action>(
                          value: item,
                          child: Text(item.label),
                          onTap: () => item.action(context),
                        );
                      },
                    ).toList();
                  },
                ),
              ],
            ),
          ),
          drawer: isNarrowLayout ? const ResponsiveNavigationDrawer() : null,
          floatingActionButton: !state.isSelected
              ? PrimaryFloatingActionButton(
                  icon: Icon(primaryAddTodoAction.icon),
                  tooltip: primaryAddTodoAction.label,
                  action: () => primaryAddTodoAction.action(context),
                )
              : null,
          bottomNavigationBar: state.isSelected
              ? PrimaryBottomAppBar(
                  children: [
                    IconButton(
                      tooltip: selectionDeleteAction.label,
                      icon: Icon(selectionDeleteAction.icon),
                      onPressed: () => selectionDeleteAction.action(context),
                    ),
                    state.isSelectedCompleted
                        ? IconButton(
                            tooltip: selectionMarkAsUndoneAction.label,
                            icon: Icon(selectionMarkAsUndoneAction.icon),
                            onPressed: () =>
                                selectionMarkAsUndoneAction.action(context),
                          )
                        : IconButton(
                            tooltip: selectionMarkAsDoneAction.label,
                            icon: Icon(selectionMarkAsDoneAction.icon),
                            onPressed: () =>
                                selectionMarkAsDoneAction.action(context),
                          ),
                  ],
                )
              : null,
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              context
                  .read<TodoListBloc>()
                  .add(const TodoListSynchronizationRequested());
            },
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: _buildTodoList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodoList() {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if loading state is changed only.
        return (previousState is TodoListLoading &&
                state is! TodoListLoading) ||
            (previousState is! TodoListLoading && state is TodoListLoading);
      },
      builder: (BuildContext context, TodoListState state) {
        if (state is TodoListLoading) {
          return Stack(
            children: <Widget>[
              const TodoList(),
              // Custom progress indicator.
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const TodoList();
        }
      },
    );
  }
}

class TodoListNarrowView extends TodoListView {
  TodoListNarrowView({super.key});

  @override
  bool get isNarrowLayout => true;
}

class TodoListWideView extends TodoListView {
  TodoListWideView({super.key});

  @override
  bool get isNarrowLayout => false;
}
