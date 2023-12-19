import 'package:flutter/material.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;

class ProjectListBottomSheet extends StatefulWidget {
  final FilterCubit cubit;
  final Set<String> items;

  const ProjectListBottomSheet({
    required this.cubit,
    required this.items,
    super.key,
  });

  @override
  State<ProjectListBottomSheet> createState() => _ProjectListBottomSheetState();
}

class _ProjectListBottomSheetState extends State<ProjectListBottomSheet> {
  Set<String> selectedItems = {};

  @override
  void initState() {
    selectedItems = {...widget.cubit.state.filter.projects};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      key: const Key('ProjectsTodoListBottomSheet'),
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
                title: const Text('Select projects'),
                trailing: TextButton(
                  onPressed: () {
                    widget.cubit.updateProjects(selectedItems);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (BuildContext context, int index) {
                  String project = widget.items.elementAt(index);
                  return CheckboxListTile(
                    key: Key('${project}BottomSheetCheckboxButton'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
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
            ],
          ),
        );
      },
    );
  }
}
