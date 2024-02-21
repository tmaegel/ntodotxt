import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/filter/filter_model.dart' show ListGroup;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class FilterStateGroupDialog extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListGroup> items;

  const FilterStateGroupDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'None': ListGroup.none,
          'Upcoming': ListGroup.upcoming,
          'Priority': ListGroup.priority,
          'Project': ListGroup.project,
          'Context': ListGroup.context,
        };

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) => FilterStateGroupDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ListView.builder(
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
      ),
    );
  }
}

class DefaultFilterStateGroupDialog extends StatelessWidget {
  final FilterCubit cubit;
  final Map<String, ListGroup> items;

  const DefaultFilterStateGroupDialog({
    required this.cubit,
    super.key,
  }) : items = const {
          'None': ListGroup.none,
          'Upcoming': ListGroup.upcoming,
          'Priority': ListGroup.priority,
          'Project': ListGroup.project,
          'Context': ListGroup.context,
        };

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
  }) async {
    return await showDialog<Future<void>>(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) =>
          DefaultFilterStateGroupDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  cubit.updateDefaultGroup(value);
                }
                Navigator.pop(context);
              });
        },
      ),
    );
  }
}
