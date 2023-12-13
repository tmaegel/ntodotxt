import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_list_widget.dart';

class TodoListPage extends StatelessWidget {
  final ScrollController controller = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  TodoListPage({super.key});

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
            title: 'Todos',
            toolbar: Row(
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
          drawer: isNarrowLayout
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
