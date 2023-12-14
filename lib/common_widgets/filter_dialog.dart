import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListFilter;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart'
    show TodoListBloc;

class FilterTodoListBottomSheet extends StatelessWidget {
  final Map<String, ListFilter> items;

  const FilterTodoListBottomSheet({super.key})
      : items = const {
          'All': ListFilter.all,
          'Completed only': ListFilter.completedOnly,
          'Incompleted only': ListFilter.incompletedOnly,
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
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            String key = items.keys.elementAt(index);
            ListFilter value = items[key]!;
            return RadioListTile<ListFilter>(
              key: Key('${value.name}BottomSheetRadioButton'),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(key),
              value: value,
              groupValue: context.read<TodoListBloc>().state.filter.filter,
              onChanged: (ListFilter? value) {
                Navigator.pop(
                  context,
                  value ?? context.read<TodoListBloc>().state.filter.filter,
                );
              },
            );
          },
        );
      },
    );
  }
}

class FilterSettingsDialog extends StatelessWidget {
  final Map<String, ListFilter> items;

  const FilterSettingsDialog({super.key})
      : items = const {
          'All': ListFilter.all,
          'Completed only': ListFilter.completedOnly,
          'Incompleted only': ListFilter.incompletedOnly,
        };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('FilterSettingsDialog'),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          String key = items.keys.elementAt(index);
          ListFilter value = items[key]!;
          return RadioListTile<ListFilter>(
            key: Key('${value.name}DialogRadioButton'),
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            value: value,
            title: Text(key),
            groupValue: context.read<DefaultFilterCubit>().state.filter,
            onChanged: (ListFilter? value) => Navigator.pop(context, value),
          );
        },
      ),
    );
  }
}
