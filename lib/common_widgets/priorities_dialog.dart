import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class PriorityListDialog extends StatefulWidget {
  final FilterCubit cubit;
  final Set<Priority> items;

  const PriorityListDialog({
    required this.cubit,
    required this.items,
    super.key,
  });

  static Future<String?> dialog({
    required BuildContext context,
    required FilterCubit cubit,
    required Set<Priority> items,
  }) async {
    return await showDialog<String?>(
      context: context,
      builder: (BuildContext context) =>
          PriorityListDialog(cubit: cubit, items: items),
    );
  }

  @override
  State<PriorityListDialog> createState() => _PriorityListDialogState();
}

class _PriorityListDialogState extends State<PriorityListDialog> {
  Set<Priority> selectedItems = {};

  @override
  void initState() {
    super.initState();
    selectedItems = {...widget.cubit.state.filter.priorities};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Priorities'),
      content: GenericChipGroup(
        children: [
          for (Priority item in widget.items)
            GenericChoiceChip(
              label: Text(item.name),
              selected: selectedItems.contains(item),
              onSelected: (bool selected) {
                setState(() {
                  if (selected == true) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
              },
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Apply'),
          onPressed: () {
            widget.cubit.updatePriorities(selectedItems);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
