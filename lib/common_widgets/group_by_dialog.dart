import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListGroup;
import 'package:ntodotxt/presentation/default_filter/states/default_filter_cubit.dart'
    show DefaultFilterCubit;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class GroupByTodoListBottomSheet extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListGroup> items;

  const GroupByTodoListBottomSheet({
    required this.cubit,
    super.key,
  }) : items = const {
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
      builder: (BuildContext context) {
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
              title: Text(key),
              value: value,
              groupValue: cubit.state.filter.group,
              onChanged: (ListGroup? value) {
                if (value != null) {
                  cubit.updateGroup(value);
                }
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class GroupBySettingsDialog extends StatelessWidget {
  final DefaultFilterCubit cubit;
  final Map<String, ListGroup> items;

  const GroupBySettingsDialog({
    required this.cubit,
    super.key,
  }) : items = const {
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
              value: value,
              title: Text(key),
              groupValue: cubit.state.filter.group,
              onChanged: (ListGroup? value) {
                if (value != null) {
                  cubit.updateListGroup(value);
                }
                Navigator.pop(context);
              });
        },
      ),
    );
  }
}
