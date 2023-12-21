import 'package:flutter/material.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

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
    selectedItems = {...widget.cubit.state.filter.contexts};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Contexts'),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            String context = widget.items.elementAt(index);
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(context),
              value: selectedItems.contains(context),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedItems.add(context);
                  } else {
                    selectedItems.remove(context);
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
            widget.cubit.updateContexts(selectedItems);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
