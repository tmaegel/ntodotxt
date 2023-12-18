import 'package:flutter/material.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class ContextListBottomSheet extends StatefulWidget {
  final FilterCubit cubit;
  final Set<String> items;

  const ContextListBottomSheet({
    required this.cubit,
    required this.items,
    super.key,
  });

  @override
  State<ContextListBottomSheet> createState() => _ContextListBottomSheetState();
}

class _ContextListBottomSheetState extends State<ContextListBottomSheet> {
  Set<String> selectedItems = {};

  @override
  void initState() {
    selectedItems = {...widget.cubit.state.filter.contexts};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key('ContextsTodoListBottomSheet'),
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(left: 8.0),
                title: const Text('Select contexts'),
                trailing: TextButton(
                  onPressed: () {
                    widget.cubit.updateContexts(selectedItems);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (BuildContext context, int index) {
                  String context = widget.items.elementAt(index);
                  return CheckboxListTile(
                    key: Key('${context}BottomSheetCheckboxButton'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
            ],
          ),
        );
      },
    );
  }
}
