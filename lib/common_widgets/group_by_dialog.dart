import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListGroup;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart'
    show TodoListBloc;

class GroupByTodoListBottomSheet extends StatelessWidget {
  final Map<String, ListGroup> items;

  const GroupByTodoListBottomSheet({super.key})
      : items = const {
          'None': ListGroup.none,
          'Upcoming': ListGroup.upcoming,
          'Priority': ListGroup.priority,
          'Project': ListGroup.project,
          'Context': ListGroup.context,
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
            ListGroup value = items[key]!;
            return RadioListTile<ListGroup>(
              key: Key('${value.name}BottomSheetRadioButton'),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(key),
              value: value,
              groupValue: context.read<TodoListBloc>().state.filter.group,
              onChanged: (ListGroup? value) {
                Navigator.pop(
                  context,
                  value ?? context.read<TodoListBloc>().state.filter.group,
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
  final Map<String, ListGroup> items;

  const GroupBySettingsDialog({super.key})
      : items = const {
          'None': ListGroup.none,
          'Upcoming': ListGroup.upcoming,
          'Priority': ListGroup.priority,
          'Project': ListGroup.project,
          'Context': ListGroup.context,
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
          ListGroup value = items[key]!;
          return RadioListTile<ListGroup>(
            key: Key('${value.name}DialogRadioButton'),
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            value: value,
            title: Text(key),
            groupValue: context.read<DefaultFilterCubit>().state.group,
            onChanged: (ListGroup? value) => Navigator.pop(context, value),
          );
        },
      ),
    );
  }
}
