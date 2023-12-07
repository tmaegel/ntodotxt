import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';

class FilterTodoListBottomSheet extends StatelessWidget {
  final Map<String, TodoListFilter> items;

  const FilterTodoListBottomSheet({super.key})
      : items = const {
          'All': TodoListFilter.all,
          'Completed only': TodoListFilter.completedOnly,
          'Incompleted only': TodoListFilter.incompletedOnly,
        };

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key('FilterTodoListBottomSheet'),
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
              leading: Radio<TodoListFilter>(
                key: Key('${items[key]!.name}BottomSheetRadioButton'),
                value: items[key]!,
                groupValue: context.read<TodoListBloc>().state.filter,
                onChanged: (TodoListFilter? value) => Navigator.pop(context,
                    value ?? context.read<TodoListBloc>().state.filter),
              ),
            );
          },
        );
      },
    );
  }
}

class FilterSettingsDialog extends StatelessWidget {
  final Map<String, TodoListFilter> items;

  const FilterSettingsDialog({super.key})
      : items = const {
          'All': TodoListFilter.all,
          'Completed only': TodoListFilter.completedOnly,
          'Incompleted only': TodoListFilter.incompletedOnly,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('FilterSettingsDialog'),
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
            leading: Radio<TodoListFilter>(
              key: Key('${items[key]!.name}DialogRadioButton'),
              value: items[key]!,
              groupValue: TodoListFilter.values.byName(
                context.read<SettingsCubit>().state.todoFilter,
              ),
              onChanged: (TodoListFilter? value) =>
                  Navigator.pop(context, value),
            ),
          );
        },
      ),
    );
  }
}
