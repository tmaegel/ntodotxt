import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

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
      key: const Key("GroupByTodoListBottomSheet"),
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            String key = items.keys.elementAt(index);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(key),
              leading: Radio<TodoListGroupBy>(
                key: Key('${items[key]!.name}BottomSheetRadioButton'),
                value: items[key]!,
                groupValue: context.read<TodoListBloc>().state.group,
                onChanged: (TodoListGroupBy? value) => Navigator.pop(
                    context, value ?? context.read<TodoListBloc>().state.group),
              ),
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
      key: const Key("GroupBySettingsDialog"),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(key),
            leading: Radio<TodoListGroupBy>(
              key: Key('${items[key]!.name}DialogRadioButton'),
              value: items[key]!,
              groupValue: TodoListGroupBy.values.byName(
                context.read<SettingsCubit>().state.todoGrouping,
              ),
              onChanged: (TodoListGroupBy? value) =>
                  Navigator.pop(context, value),
            ),
          );
        },
      ),
    );
  }
}
