import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/actions.dart'
    show
        ActionWrapper,
        appBarActions,
        primaryAddTodoAction,
        selectionDeleteAction,
        selectionMarkAsDoneAction,
        selectionMarkAsUndoneAction;
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/navigation_drawer.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show Filter;
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority, Todo;
import 'package:ntodotxt/misc.dart';
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
    if (filter == null) {
      // Using existing BlocProvdier in parent widget.
      return const TodoListView();
    } else {
      return BlocProvider(
        create: (BuildContext context) => TodoListBloc(
          filter: filter,
          repository: context.read<TodoListRepository>(),
        )
          ..add(const TodoListSubscriptionRequested())
          ..add(const TodoListSynchronizationRequested()),
        child: TodoListView(filter: filter),
      );
    }
  }
}

class TodoListView extends StatelessWidget {
  final Filter? filter;

  const TodoListView({
    this.filter,
    super.key,
  });

  bool get filtered => filter != null;

  @override
  Widget build(BuildContext context) {
    final bool isNarrowLayout =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;
    return BlocConsumer<TodoListBloc, TodoListState>(
      listener: (BuildContext context, TodoListState state) {
        // Catch errors on the highes possible layer.
        if (state is TodoListError) {
          SnackBarHandler.error(context, state.message);
        }
      },
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if selection has changed only.
        return previousState.isAnySelected != state.isAnySelected;
      },
      builder: (BuildContext context, TodoListState state) {
        return Scaffold(
          appBar: MainAppBar(
            title: filtered == false ? 'Todos' : 'Todos (${filter!.name})',
            toolbar: filtered
                ? null
                : Row(
                    children: [
                      IconButton(
                        tooltip: appBarActions[0].label,
                        icon: Icon(appBarActions[0].icon),
                        onPressed: () => appBarActions[0].action(context),
                      ),
                      PopupMenuButton<ActionWrapper>(
                        itemBuilder: (BuildContext context) {
                          return appBarActions.skip(1).map(
                            (ActionWrapper item) {
                              return PopupMenuItem<ActionWrapper>(
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
          drawer: isNarrowLayout && !filtered
              ? const ResponsiveNavigationDrawer(selectedIndex: 0)
              : null,
          floatingActionButton: !state.isAnySelected
              ? PrimaryFloatingActionButton(
                  icon: Icon(primaryAddTodoAction.icon),
                  tooltip: primaryAddTodoAction.label,
                  action: () => primaryAddTodoAction.action(context),
                )
              : null,
          bottomNavigationBar: state.isAnySelected
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
              child: const TodoListLoadingWrapper(),
            ),
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
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        Map<String, Iterable<Todo>?> sectionList = state.groupedByTodoList;
        return ListView.builder(
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
                  TodoListTileDismissable(
                    todo: todo,
                    isAnySelected: state.isAnySelected,
                  )
              ],
            );
          },
        );
      },
    );
  }
}

class TodoListTileDismissable extends StatelessWidget {
  final Todo todo;
  final bool isAnySelected;

  const TodoListTileDismissable({
    required this.todo,
    this.isAnySelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Allow swiping if no todo is selected only.
    if (isAnySelected) {
      return TodoListTile(
        todo: todo,
        isAnySelected: isAnySelected,
      );
    } else {
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
          isAnySelected: isAnySelected,
        ),
      );
    }
  }
}

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final bool isAnySelected;

  TodoListTile({
    required this.todo,
    this.isAnySelected = false,
    Key? key,
  }) : super(key: PageStorageKey<String>(todo.id));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      selected: todo.selected,
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.completion ? TextDecoration.lineThrough : null,
          decorationThickness: 2.0,
        ),
      ),
      subtitle: _buildSubtitle(),
      onTap: () {
        if (isAnySelected) {
          context.read<TodoListBloc>().add(TodoListTodoSelectedToggled(
              todo: todo, selected: !todo.selected));
        } else {
          context.pushNamed('todo-edit', extra: todo);
        }
      },
      onLongPress: () => context.read<TodoListBloc>().add(
          TodoListTodoSelectedToggled(todo: todo, selected: !todo.selected)),
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
