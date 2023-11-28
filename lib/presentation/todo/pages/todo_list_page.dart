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
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocListener<TodoListBloc, TodoListState>(
      listener: (context, state) {
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

  Widget _buildPrimaryToolBarActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Group by',
          icon: const Icon(Icons.widgets),
          onPressed: () async {
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
        IconButton(
          tooltip: 'Sort',
          icon: const Icon(Icons.sort_by_alpha),
          onPressed: () async {
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
        IconButton(
          tooltip: 'Filter',
          icon: const Icon(Icons.filter_alt),
          onPressed: () async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Todos",
        toolbar: !isNarrowLayout
            ? BlocBuilder<TodoListBloc, TodoListState>(
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
              )
            : null,
      ),
      drawer: isNarrowLayout ? const ResponsiveNavigationDrawer() : null,
      floatingActionButtonLocation: isNarrowLayout
          ? FloatingActionButtonLocation.endContained
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: PrimaryFloatingActionButton(
        icon: const Icon(Icons.add),
        tooltip: 'Add',
        action: () => context.push(
          context.namedLocation('todo-create'),
        ),
      ),
      bottomNavigationBar: isNarrowLayout
          ? PrimaryBottomAppBar(
              children: [
                BlocBuilder<TodoListBloc, TodoListState>(
                  buildWhen:
                      (TodoListState previousState, TodoListState state) {
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
