import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class GroupByDialog extends StatelessWidget {
  final Map<String, TodoListGroupBy> items;

  const GroupByDialog({super.key})
      : items = const {
          'Upcoming': TodoListGroupBy.upcoming,
          'Priority': TodoListGroupBy.priority,
          'Project': TodoListGroupBy.project,
          'Context': TodoListGroupBy.context,
        };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        // Rebuild if groupBy is changed only.
        return previousState.groupBy != state.groupBy;
      },
      builder: (BuildContext context, TodoListState state) {
        return BottomSheet(
          enableDrag: false,
          showDragHandle: false,
          onClosing: () {},
          builder: (context) {
            return ListView.builder(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                String key = items.keys.elementAt(index);
                return ListTile(
                  title: Text(key),
                  leading: Radio<TodoListGroupBy>(
                    value: items[key]!,
                    groupValue: state.groupBy,
                    onChanged: (TodoListGroupBy? value) =>
                        _setState(context, value),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _setState(BuildContext context, TodoListGroupBy? groupBy) {
    if (groupBy != null) {
      context
          .read<TodoListBloc>()
          .add(TodoListGroupByChanged(groupBy: groupBy));
    }
    Navigator.pop(context);
  }
}
