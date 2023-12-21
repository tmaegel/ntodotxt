import 'package:flutter/material.dart';
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
      title: const Center(
        child: Text('Projects'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            String project = widget.items.elementAt(index);
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(project),
              value: selectedItems.contains(project),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedItems.add(project);
                  } else {
                    selectedItems.remove(project);
                  }
                });
              },
            );
          },
        ),
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
