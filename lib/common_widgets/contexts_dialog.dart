import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/tag_dialog.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

class ContextListDialog extends StatefulWidget {
  final FilterCubit cubit;
  final Set<String> items;

  const ContextListDialog({
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
          ContextListDialog(cubit: cubit, items: items),
    );
  }

  @override
  State<ContextListDialog> createState() => _ContextListDialogState();
}

class _ContextListDialogState extends State<ContextListDialog> {
  Set<String> selectedItems = {};

  @override
  void initState() {
    super.initState();
    selectedItems = {...widget.cubit.state.filter.contexts};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Contexts'),
      content: widget.items.isEmpty == true
          ? const Text('No context tags available')
          : GenericChipGroup(
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: widget.items.isEmpty == true
              ? null
              : () {
                  widget.cubit.updateContexts(selectedItems);
                  Navigator.pop(context);
                },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class ContextTagDialog extends TagDialog {
  const ContextTagDialog({
    required super.cubit,
    super.title = 'Contexts',
    super.tagName = 'context',
    super.availableTags,
    super.key = const Key('addContextTagDialog'),
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
      builder: (BuildContext context) => ContextTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  void onSubmit(BuildContext context, Set<String> values) =>
      cubit.updateContexts(values);

  @override
  State<ContextTagDialog> createState() => _ContextTagDialogState();
}

class _ContextTagDialogState extends TagDialogState<ContextTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(name: t, selected: false),
      ),
      ...widget.cubit.state.todo.contexts.map(
        (String t) => Tag(name: t, selected: true),
      ),
    };
  }
}
