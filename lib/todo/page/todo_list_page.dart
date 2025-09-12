import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common/misc.dart' show PopScopeDrawer, SnackBarHandler;
import 'package:ntodotxt/common/widget/app_bar.dart';
import 'package:ntodotxt/common/widget/chip.dart';
import 'package:ntodotxt/common/widget/confirm_dialog.dart';
import 'package:ntodotxt/common/widget/scroll_to_top.dart';
import 'package:ntodotxt/drawer/state/drawer_cubit.dart';
import 'package:ntodotxt/filter/model/filter_model.dart' show Filter;
import 'package:ntodotxt/filter/repository/filter_repository.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart';
import 'package:ntodotxt/filter/state/filter_state.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/todo/model/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/todo/state/todo_list_bloc.dart';
import 'package:ntodotxt/todo/state/todo_list_event.dart';
import 'package:ntodotxt/todo/state/todo_list_state.dart';

class TodoListPage extends StatelessWidget {
  final Filter? filter;

  const TodoListPage({
    this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      filter == null ? _build(context) : _buildWithFilter(context);

  Widget _build(BuildContext context) {
    // @todo: Activate WideLayout later!
    return const TodoListViewNarrow();
    // final bool isNarrowLayout =
    //     MediaQuery.of(context).size.width < maxScreenWidthCompact;
    // return isNarrowLayout
    //     ? const TodoListViewNarrow()
    //     : const TodoListViewWide();
  }

  Widget _buildWithFilter(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => FilterCubit(
        settingRepository: context.read<SettingRepository>(),
        filterRepository: context.read<FilterRepository>(),
        filter: filter,
      )..load(),
      child: Builder(
        builder: (BuildContext context) => _build(context),
      ),
    );
  }
}

///
/// Narrow layout
///

class TodoListViewNarrow extends ScollToTopView {
  const TodoListViewNarrow({super.key});

  @override
  State<TodoListViewNarrow> createState() => _TodoListViewNarrowState();
}

class _TodoListViewNarrowState extends ScollToTopViewState<TodoListViewNarrow> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState todoListState) =>
          (previousState is! TodoListLoading &&
              todoListState is TodoListLoading) ||
          (previousState is TodoListLoading &&
              todoListState is! TodoListLoading),
      builder: (BuildContext context, TodoListState todoListState) {
        return BlocBuilder<FilterCubit, FilterState>(
          buildWhen: (FilterState previousState, FilterState filterState) =>
              previousState.filter.name != filterState.filter.name,
          builder: (BuildContext context, FilterState filterState) {
            return PopScopeDrawer(
              child: Scaffold(
                appBar: MainAppBar(
                  title: filterState.filter.name.isEmpty
                      ? 'Todos'
                      : 'Filter: ${filterState.filter.name}',
                  toolbar: Row(
                    children: [
                      const TodoListDeleteFilter(),
                      const TodoListSaveFilter(),
                      IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search),
                        onPressed: () => context.pushNamed('todo-search',
                            extra: filterState.filter),
                      ),
                    ],
                  ),
                  bottom: const AppBarFilterList(),
                ),
                drawer: Container(),
                floatingActionButton: scrolledDown
                    ? FloatingActionButton.small(
                        tooltip: 'Go to top',
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () => scrollToTop(),
                      )
                    : FloatingActionButton(
                        tooltip: 'Add todo',
                        child: const Icon(Icons.add),
                        onPressed: () {
                          String initDescription = '';
                          if (filterState.filter.projects.isNotEmpty) {
                            initDescription =
                                '+${filterState.filter.projects.join(' +')}';
                          }
                          if (filterState.filter.contexts.isNotEmpty) {
                            initDescription =
                                '$initDescription @${filterState.filter.contexts.join(' @')}';
                          }
                          context.pushNamed(
                            'todo-create',
                            extra: Todo.fromString(value: initDescription),
                          );
                        },
                      ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<TodoListBloc>()
                        .add(const TodoListSynchronizationRequested());
                  },
                  child: LoadingIndicatorWrapper(
                    loading: todoListState is TodoListLoading,
                    child: TodoList(scrollController: scrollController),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

///
/// Wide layout
///

class TodoListViewWide extends ScollToTopView {
  const TodoListViewWide({super.key});

  @override
  State<TodoListViewWide> createState() => _TodoListViewWideState();
}

class _TodoListViewWideState extends ScollToTopViewState<TodoListViewWide> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState todoListState) =>
          (previousState is! TodoListLoading &&
              todoListState is TodoListLoading) ||
          (previousState is TodoListLoading &&
              todoListState is! TodoListLoading),
      builder: (BuildContext context, TodoListState todoListState) {
        return BlocBuilder<FilterCubit, FilterState>(
          buildWhen: (FilterState previousState, FilterState filterState) =>
              previousState.filter.name != filterState.filter.name,
          builder: (BuildContext context, FilterState filterState) {
            return PopScopeDrawer(
              child: Scaffold(
                appBar: MainAppBar(
                  title: filterState.filter.name.isEmpty
                      ? 'Todos'
                      : 'Filter: ${filterState.filter.name}',
                  toolbar: Row(
                    children: [
                      const TodoListDeleteFilter(),
                      const TodoListSaveFilter(),
                      IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search),
                        onPressed: () => context.pushNamed('todo-search',
                            extra: filterState.filter),
                      ),
                    ],
                  ),
                  bottom: const AppBarFilterList(),
                ),
                floatingActionButton: scrolledDown
                    ? FloatingActionButton.small(
                        tooltip: 'Go to top',
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () => scrollToTop(),
                      )
                    : FloatingActionButton(
                        tooltip: 'Add todo',
                        child: const Icon(Icons.add),
                        onPressed: () {
                          String initDescription = '';
                          if (filterState.filter.projects.isNotEmpty) {
                            initDescription =
                                '+${filterState.filter.projects.join(' +')}';
                          }
                          if (filterState.filter.contexts.isNotEmpty) {
                            initDescription =
                                '$initDescription @${filterState.filter.contexts.join(' @')}';
                          }
                          context.pushNamed(
                            'todo-create',
                            extra: Todo.fromString(value: initDescription),
                          );
                        },
                      ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<TodoListBloc>()
                        .add(const TodoListSynchronizationRequested());
                  },
                  child: LoadingIndicatorWrapper(
                    loading: todoListState is TodoListLoading,
                    child: TodoList(scrollController: scrollController),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

///
/// Components
///

class LoadingIndicatorWrapper extends StatelessWidget {
  final Widget child;
  final bool loading;

  const LoadingIndicatorWrapper({
    required this.child,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Stack(
        children: <Widget>[
          child,
          // Custom progress indicator.
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return child;
    }
  }
}

class TodoList extends StatelessWidget {
  final ScrollController scrollController;

  const TodoList({
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState todoListState) {
        return BlocBuilder<FilterCubit, FilterState>(
          builder: (BuildContext context, FilterState filterState) {
            final Map<String, Iterable<Todo>?> sectionList =
                todoListState.groupedTodoList(
              filterState.filter,
            );
            return ListView.builder(
              key: const PageStorageKey('TodoList'),
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sectionList.length,
              itemBuilder: (BuildContext context, int index) {
                String section = sectionList.keys.elementAt(index);
                Iterable<Todo> todoList = sectionList[section]!;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        key: PageStorageKey<String>(section),
                        title: Text(
                          section,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ),
                    for (var todo in todoList)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TodoListTile(todo: todo),
                      ),
                    if (index < sectionList.length - 1) const Divider(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class TodoListTile extends StatelessWidget {
  final Todo todo;

  TodoListTile({
    required this.todo,
    Key? key,
  }) : super(key: PageStorageKey<String>(todo.id));

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Theme.of(context).colorScheme.error, // red
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16.0),
        child: Icon(Icons.delete),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.primaryContainer, // blue
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(todo.completion ? Icons.remove_done : Icons.done_all),
      ),
      onDismissed: (DismissDirection direction) {
        // Done / Undone
        if (todo.completion) {
          SnackBarHandler.info(context, 'Todo has marked as not completed');
        } else {
          SnackBarHandler.info(context, 'Todo has marked as completed');
        }
        if (direction == DismissDirection.endToStart) {
          context.read<TodoListBloc>().add(
                TodoListTodoCompletionToggled(
                  todo: todo,
                  completion: !todo.completion,
                ),
              );
        } else if (direction == DismissDirection.startToEnd) {
          // Delete
          context.read<TodoListBloc>().add(
                TodoListTodoDeleted(
                  todo: todo,
                ),
              );
          SnackBarHandler.info(context, 'Todo has been deleted');
        }
      },
      child: ListTile(
        key: key,
        title: _buildTitle(context),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: _buildSubtitle(),
        ),
        onTap: () => context.pushNamed('todo-edit', extra: todo),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final List<String> items = todo.description.split(' ')
      ..removeWhere(
        (String item) => item.startsWith('due:'),
      );

    return RichText(
      text: TextSpan(
        style: todo.completion
            ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 4.0,
                )
            : Theme.of(context).textTheme.titleMedium,
        text: '',
        children: <TextSpan>[
          for (int i = 0; i < items.length; i++)
            TextSpan(
                text: i == items.length - 1 ? items[i] : '${items[i]} ',
                style: Todo.matchProject(items[i]) ||
                        Todo.matchContext(items[i]) ||
                        Todo.matchKeyValue(items[i])
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildSubtitle() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2.0, // gap between adjacent chips
      runSpacing: 2.0, // gap between lines
      children: <Widget>[
        if (todo.priority != Priority.none)
          BasicIconChip(
            mono: true,
            iconData: Icons.flag_outlined,
            label: todo.priority.name,
          ),
        if (todo.creationDate != null)
          BasicIconChip(
            mono: true,
            iconData: Icons.edit_calendar,
            label: Todo.differenceToToday(todo.creationDate!),
          ),
        if (todo.completionDate != null && todo.completion)
          BasicIconChip(
            mono: true,
            iconData: Icons.event_available,
            label: Todo.differenceToToday(todo.completionDate!),
          ),
        if (todo.dueDate != null)
          BasicIconChip(
            mono: true,
            iconData: Icons.event,
            label: Todo.date2Str(todo.dueDate!)!,
          )
      ],
    );
  }
}

class TodoListDeleteFilter extends StatelessWidget {
  const TodoListDeleteFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        return state.changed || state.filter.id == null
            ? Container()
            : IconButton(
                tooltip: 'Delete filter',
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final bool confirm = await ConfirmationDialog.dialog(
                    context: context,
                    title: 'Delete filter',
                    message: 'Do you want to delete the filter?',
                    actionLabel: 'Delete',
                    cancelLabel: 'Cancel',
                  );
                  if (context.mounted && confirm) {
                    await context.read<FilterCubit>().delete(state.filter);
                    if (context.mounted) {
                      SnackBarHandler.info(context, 'Filter deleted');
                      context.pop();
                      context.read<DrawerCubit>().back();
                    }
                  }
                },
              );
      },
    );
  }
}

class TodoListSaveFilter extends StatelessWidget {
  const TodoListSaveFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        return !state.changed || state.filter.id == null
            ? Container()
            : IconButton(
                tooltip: 'Save filter',
                icon: const Icon(Icons.save),
                onPressed: () async {
                  await context
                      .read<FilterCubit>()
                      .update(state.filter.copyWith());
                  if (context.mounted) {
                    SnackBarHandler.info(context, 'Filter saved');
                  }
                },
              );
      },
    );
  }
}
