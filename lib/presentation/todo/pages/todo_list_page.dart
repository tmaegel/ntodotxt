import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';
import 'package:ntodotxt/common_widgets/input_dialog.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/filter/filter_repository.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/misc.dart' show PopScopeDrawer, SnackBarHandler;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart';
import 'package:ntodotxt/presentation/filter/states/filter_list_bloc.dart'
    show FilterListBloc;
import 'package:ntodotxt/presentation/filter/states/filter_state.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_search_page.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class TodoListPage extends StatelessWidget {
  final Filter? filter;

  const TodoListPage({
    this.filter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => FilterCubit(
        settingRepository: context.read<SettingRepository>(),
        filterRepository: context.read<FilterRepository>(),
        filter: filter,
      )..initial(),
      child: Builder(
        builder: (BuildContext context) {
          final bool isNarrowLayout =
              MediaQuery.of(context).size.width < maxScreenWidthCompact;
          Widget child;
          if (isNarrowLayout) {
            child = const TodoListViewNarrow();
          } else {
            child = const TodoListViewWide();
          }
          return BlocListener<TodoListBloc, TodoListState>(
            listener: (BuildContext context, TodoListState state) {
              if (state is TodoListError) {
                SnackBarHandler.error(context, state.message);
              }
            },
            child: child,
          );
        },
      ),
    );
  }
}

class TodoListViewNarrow extends StatelessWidget {
  const TodoListViewNarrow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.name != state.filter.name,
      builder: (BuildContext context, FilterState state) {
        return PopScopeDrawer(
          child: Scaffold(
            appBar: MainAppBar(
              title: state.filter.name.isEmpty
                  ? 'Todos'
                  : 'Filter: ${state.filter.name}',
              bottom: const AppBarFilterList(),
            ),
            drawer: Container(),
            bottomNavigationBar: const TodoListBottomAppBar(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endContained,
            floatingActionButton: FloatingActionButton(
              tooltip: 'Add todo',
              child: const Icon(Icons.add),
              onPressed: () => context.push(
                context.namedLocation('todo-create'),
              ),
            ),
            body: const TodoListLoadingWrapper(),
          ),
        );
      },
    );
  }
}

class TodoListViewWide extends StatelessWidget {
  const TodoListViewWide({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      buildWhen: (FilterState previousState, FilterState state) =>
          previousState.filter.name != state.filter.name,
      builder: (BuildContext context, FilterState state) {
        return PopScopeDrawer(
          child: Scaffold(
            appBar: MainAppBar(
              title:
                  'Todo: ${state.filter.name.isEmpty ? 'all' : state.filter.name}',
              toolbar: Row(
                children: [
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search),
                    onPressed: () => showSearch(
                      context: context,
                      delegate: TodoSearchPage(),
                    ),
                  ),
                  const TodoListSaveFilter(),
                ],
              ),
              bottom: const AppBarFilterList(),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Add todo',
              child: const Icon(Icons.add),
              onPressed: () => context.push(
                context.namedLocation('todo-create'),
              ),
            ),
            body: const TodoListLoadingWrapper(),
          ),
        );
      },
    );
  }
}

class TodoListLoadingWrapper extends StatelessWidget {
  const TodoListLoadingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: GlobalKey<RefreshIndicatorState>(),
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
        child: BlocBuilder<TodoListBloc, TodoListState>(
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
                      padding: const EdgeInsets.only(top: 90),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const TodoList();
            }
          },
        ),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState todoListState) {
        return BlocBuilder<FilterCubit, FilterState>(
          builder: (BuildContext context, FilterState filterState) {
            Map<String, Iterable<Todo>?> sectionList =
                todoListState.groupedTodoList(
              filterState.filter,
            );
            return ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              itemCount: sectionList.length,
              itemBuilder: (BuildContext context, int index) {
                String section = sectionList.keys.elementAt(index);
                Iterable<Todo> todoList = sectionList[section]!;
                return ExpansionTile(
                  key: PageStorageKey<String>(section),
                  initiallyExpanded: true,
                  title: Text(section),
                  children: [
                    for (var todo in todoList)
                      TodoListTileDismissable(todo: todo)
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

class TodoListTileDismissable extends StatelessWidget {
  final Todo todo;

  const TodoListTileDismissable({
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>(todo.id),
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.done),
            ),
            Text(todo.completion == true ? 'Undone' : 'Done'),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            Text(todo.completion == true ? 'Undone' : 'Done'),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(Icons.done),
            ),
          ],
        ),
      ),
      onDismissed: (DismissDirection direction) {
        context.read<TodoListBloc>().add(
              TodoListTodoCompletionToggled(
                  todo: todo, completion: !todo.completion),
            );
      },
      child: TodoListTile(
        todo: todo,
      ),
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
    return ListTile(
      key: key,
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.completion ? TextDecoration.lineThrough : null,
          decorationThickness: 2.0,
        ),
      ),
      subtitle: _buildSubtitle(),
      onTap: () => context.pushNamed('todo-edit', extra: todo),
    );
  }

  Widget? _buildSubtitle() {
    if (todo.creationDate == null &&
        todo.priority == Priority.none &&
        todo.projects.isEmpty &&
        todo.contexts.isEmpty &&
        todo.keyValues.isEmpty) {
      return null;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        if (todo.priority != Priority.none)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtPriority),
          ),
        if (todo.creationDate != null && todo.completion == false)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(Todo.differenceToToday(todo.creationDate!)),
          ),
        if (todo.completionDate != null && todo.completion == true)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(Todo.differenceToToday(todo.completionDate!)),
          ),
        if (todo.projects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtProjects.join(' ')),
          ),
        if (todo.contexts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtContexts.join(' ')),
          ),
        if (todo.keyValues.isNotEmpty) Text(todo.fmtKeyValues.join(' ')),
      ],
    );
  }
}

class TodoListBottomAppBar extends StatelessWidget {
  const TodoListBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: TodoSearchPage(),
            ),
          ),
          const TodoListSaveFilter(),
        ],
      ),
    );
  }
}

class TodoListSaveFilter extends StatelessWidget {
  const TodoListSaveFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (BuildContext context, FilterState state) {
        // Exclude the default filter.
        if (state.filter == const Filter()) {
          return Container();
        }
        if (context.read<FilterListBloc>().state.filterExists(state.filter)) {
          return IconButton(
            tooltip: 'Delete filter',
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              final bool confirm = await ConfirmationDialog.dialog(
                context: context,
                title: 'Delete filter',
                message: 'Do you want to delete the filter?',
                actionLabel: 'Delete',
              );
              if (context.mounted && confirm) {
                await context.read<FilterCubit>().delete(state.filter);
                if (context.mounted) {
                  SnackBarHandler.info(context, 'Filter deleted');
                  context.go(context.namedLocation('todo-list'));
                }
              }
            },
          );
        } else {
          return IconButton(
            tooltip: 'Save filter',
            icon: const Icon(Icons.favorite_border),
            onPressed: () async {
              final String? filterName = await InputDialog.dialog(
                context: context,
                title: 'Save filter',
                label: 'Enter filter name',
              );
              if (context.mounted && filterName != null) {
                await context
                    .read<FilterCubit>()
                    .create(state.filter.copyWith(name: filterName));
                if (context.mounted) {
                  SnackBarHandler.info(context, 'Filter saved');
                }
              }
            },
          );
        }
      },
    );
  }
}
