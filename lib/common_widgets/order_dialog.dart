import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class OrderTodoListBottomSheet extends StatelessWidget {
  final Map<String, TodoListOrder> items;

  const OrderTodoListBottomSheet({super.key})
      : items = const {
          'Ascending': TodoListOrder.ascending,
          'Descending': TodoListOrder.descending,
        };

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key("OrderTodoListBottomSheet"),
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
              leading: Radio<TodoListOrder>(
                key: Key('${items[key]!.name}BottomSheetRadioButton'),
                value: items[key]!,
                groupValue: context.read<TodoListBloc>().state.order,
                onChanged: (TodoListOrder? value) => Navigator.pop(
                    context, value ?? context.read<TodoListBloc>().state.order),
              ),
            );
          },
        );
      },
    );
  }
}

class OrderSettingsDialog extends StatelessWidget {
  final Map<String, TodoListOrder> items;

  const OrderSettingsDialog({super.key})
      : items = const {
          'Ascending': TodoListOrder.ascending,
          'Descending': TodoListOrder.descending,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key("OrderSettingsDialog"),
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
            leading: Radio<TodoListOrder>(
              key: Key('${items[key]!.name}DialogRadioButton'),
              value: items[key]!,
              groupValue: TodoListOrder.values.byName(
                context.read<SettingsCubit>().state.todoOrder,
              ),
              onChanged: (TodoListOrder? value) =>
                  Navigator.pop(context, value),
            ),
          );
        },
      ),
    );
  }
}
