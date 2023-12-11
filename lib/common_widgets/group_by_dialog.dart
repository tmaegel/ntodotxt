import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class GroupByTodoListBottomSheet extends StatelessWidget {
  final Map<String, TodoListGroupBy> items;

  const GroupByTodoListBottomSheet({super.key})
      : items = const {
          'None': TodoListGroupBy.none,
          'Upcoming': TodoListGroupBy.upcoming,
          'Priority': TodoListGroupBy.priority,
          'Project': TodoListGroupBy.project,
          'Context': TodoListGroupBy.context,
        };

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key('GroupByTodoListBottomSheet'),
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            String key = items.keys.elementAt(index);
            TodoListGroupBy value = items[key]!;
            return RadioListTile<TodoListGroupBy>(
              key: Key('${value.name}BottomSheetRadioButton'),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(key),
              value: value,
              groupValue: context.read<TodoListBloc>().state.group,
              onChanged: (TodoListGroupBy? value) {
                Navigator.pop(
                  context,
                  value ?? context.read<TodoListBloc>().state.group,
                );
              },
            );
          },
        );
      },
    );
  }
}

class GroupBySettingsDialog extends StatelessWidget {
  final Map<String, TodoListGroupBy> items;

  const GroupBySettingsDialog({super.key})
      : items = const {
          'None': TodoListGroupBy.none,
          'Upcoming': TodoListGroupBy.upcoming,
          'Priority': TodoListGroupBy.priority,
          'Project': TodoListGroupBy.project,
          'Context': TodoListGroupBy.context,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('GroupBySettingsDialog'),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          TodoListGroupBy value = items[key]!;
          return RadioListTile<TodoListGroupBy>(
            key: Key('${value.name}DialogRadioButton'),
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            value: value,
            title: Text(key),
            groupValue: TodoListGroupBy.values.byName(
              context.read<SettingsCubit>().state.todoGrouping,
            ),
            onChanged: (TodoListGroupBy? value) =>
                Navigator.pop(context, value),
          );
        },
      ),
    );
  }
}
