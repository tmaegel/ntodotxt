import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/tag_dialog.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

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
    super.initState();
    selectedItems = {...widget.cubit.state.filter.projects};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Projects'),
      content: GenericChipGroup(
        children: [
          for (String item in widget.items.toList()..sort())
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

class ProjectTagDialog extends TagDialog {
  const ProjectTagDialog({
    required super.cubit,
    super.title = 'Projects',
    super.tagName = 'project',
    super.availableTags,
    super.key = const Key('addProjectTagDialog'),
  });

  @override
  RegExp get regex => RegExp(r'^\S+$');

  static Future<void> dialog({
    required BuildContext context,
    required TodoCubit cubit,
    required Set<String> availableTags,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => ProjectTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  void onSubmit(BuildContext context, Set<String> values) =>
      cubit.updateProjects(values);

  @override
  State<ProjectTagDialog> createState() => _ProjectTagDialogState();
}

class _ProjectTagDialogState extends TagDialogState<ProjectTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(name: t, selected: false),
      ),
      ...widget.cubit.state.todo.projects.map(
        (String t) => Tag(name: t, selected: true),
      ),
    };
  }
}
