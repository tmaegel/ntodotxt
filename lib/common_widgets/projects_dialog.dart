import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class ProjectListDialog extends StatefulWidget {
  final FilterCubit cubit;
  final Set<String> items;

  const ProjectListDialog({
    required this.cubit,
    required this.items,
    super.key,
  });

  static Future<String?> dialog({
    required BuildContext context,
    required FilterCubit cubit,
    required Set<String> items,
  }) async {
    return await showDialog<String?>(
      context: context,
      builder: (BuildContext context) =>
          ProjectListDialog(cubit: cubit, items: items),
    );
  }

  @override
  State<ProjectListDialog> createState() => _ProjectListDialogState();
}

class _ProjectListDialogState extends State<ProjectListDialog> {
  Set<String> selectedItems = {};

  @override
  void initState() {
    selectedItems = {...widget.cubit.state.filter.projects};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Projects'),
      content: GenericChipGroup(
        children: [
          for (String item in widget.items)
            GenericChoiceChip(
              label: Text(item),
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
            widget.cubit.updateProjects(selectedItems);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
