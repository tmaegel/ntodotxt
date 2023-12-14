import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/filter_dialog.dart';
import 'package:ntodotxt/common_widgets/group_by_dialog.dart';
import 'package:ntodotxt/common_widgets/order_dialog.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart'
    show ListFilter, ListGroup, ListOrder;
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/todo/pages/todo_search_page.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';

class ActionWrapper {
  final String label;
  final Function action;
  final IconData? icon;

  const ActionWrapper({
    required this.label,
    required this.action,
    this.icon,
  });
}

///
/// Todo list specific actions
///

List<ActionWrapper> appBarActions = <ActionWrapper>[
  ActionWrapper(
    label: 'Search',
    icon: Icons.search,
    action: (BuildContext context) {
      showSearch(
        context: context,
        delegate: TodoSearchPage(),
      );
    },
  ),
  ActionWrapper(
    label: 'Sort',
    action: (BuildContext context) async {
      context.read<TodoListBloc>().add(
            TodoListOrderChanged(
              order: await showModalBottomSheet<ListOrder?>(
                context: context,
                builder: (BuildContext context) =>
                    const OrderTodoListBottomSheet(),
              ),
            ),
          );
    },
  ),
  ActionWrapper(
    label: 'Filter',
    action: (BuildContext context) async {
      context.read<TodoListBloc>().add(
            TodoListFilterChanged(
              filter: await showModalBottomSheet<ListFilter?>(
                context: context,
                builder: (BuildContext context) =>
                    const FilterTodoListBottomSheet(),
              ),
            ),
          );
    },
  ),
  ActionWrapper(
    label: 'Group by',
    action: (BuildContext context) async {
      context.read<TodoListBloc>().add(
            TodoListGroupChanged(
              group: await showModalBottomSheet<ListGroup?>(
                context: context,
                builder: (BuildContext context) =>
                    const GroupByTodoListBottomSheet(),
              ),
            ),
          );
    },
  ),
];

ActionWrapper primaryAddTodoAction = ActionWrapper(
  label: 'Add todo',
  icon: Icons.add,
  action: (BuildContext context) {
    context.push(
      context.namedLocation('todo-create'),
    );
  },
);

ActionWrapper selectionDeleteAction = ActionWrapper(
  label: 'Delete',
  icon: Icons.delete,
  action: (BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListSelectionDeleted());
    SnackBarHandler.info(context, 'Todos deleted.');
  },
);

ActionWrapper selectionMarkAsDoneAction = ActionWrapper(
  label: 'Mark as done',
  icon: Icons.done_all,
  action: (BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListSelectionCompleted());
    SnackBarHandler.info(context, 'Mark todos as done.');
  },
);

ActionWrapper selectionMarkAsUndoneAction = ActionWrapper(
  label: 'Mark as undone',
  icon: Icons.remove_done,
  action: (BuildContext context) {
    context.read<TodoListBloc>().add(const TodoListSelectionIncompleted());
    SnackBarHandler.info(context, 'Mark todos as undone.');
  },
);

///
/// Filter list specific actions
///

ActionWrapper primaryAddFilterAction = ActionWrapper(
  label: 'Add filter',
  icon: Icons.add,
  action: (BuildContext context) {
    context.push(
      context.namedLocation('filter-create'),
    );
  },
);
