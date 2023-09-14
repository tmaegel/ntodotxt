import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';

class TodoTagDialog extends StatefulWidget {
  final String tagName;

  const TodoTagDialog({
    required this.tagName,
    super.key,
  });

  Set<String> availableTags(BuildContext context) => {};

  void onSubmit(BuildContext context, List<String> values) {}

  @override
  State<TodoTagDialog> createState() => _TodoTagDialogState();
}

class _TodoTagDialogState<T extends TodoTagDialog> extends State<T> {
  // Holds the selected tags before adding to the regular state.
  List<String> selectedTags = [];

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> availableTags = widget.availableTags(context);
    return BottomSheet(
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText:
                      'Enter <${widget.tagName}> tags seperated by whitespaces ...',
                  isDense: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
              trailing: IconButton.filled(
                icon: const Icon(Icons.done),
                tooltip: 'Add ${widget.tagName} tags',
                onPressed: () {
                  // Remove duplicate whitespaces from input
                  // and split string by whitespaces.
                  final List<String> addedTags = _controller.text
                      .trim()
                      .replaceAllMapped(RegExp(r'\s+'), (match) {
                    return ' ';
                  }).split(' ')
                    ..removeWhere((value) => value.isEmpty);
                  widget.onSubmit(context, [...addedTags, ...selectedTags]);
                  Navigator.pop(context);
                },
              ),
            ),
            if (availableTags.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: GenericChipGroup(
                  children: [
                    for (var t in availableTags)
                      GenericChoiceChip(
                        label: Text(t),
                        selected: selectedTags.contains(t),
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              selectedTags.add(t);
                            });
                          } else {
                            setState(() {
                              selectedTags.remove(t);
                            });
                          }
                        },
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class TodoProjectTagDialog extends TodoTagDialog {
  const TodoProjectTagDialog({
    super.tagName = 'project',
    super.key,
  });

  @override
  Set<String> availableTags(BuildContext context) {
    return context
        .read<TodoListBloc>()
        .state
        .projects
        .where((p) => !context.read<TodoBloc>().state.todo.projects.contains(p))
        .toSet();
  }

  @override
  void onSubmit(BuildContext context, List<String> values) {
    context.read<TodoBloc>().add(TodoProjectsAdded(values));
  }

  @override
  State<TodoProjectTagDialog> createState() => _TodoProjectTagDialogState();
}

class _TodoProjectTagDialogState
    extends _TodoTagDialogState<TodoProjectTagDialog> {}

class TodoContextTagDialog extends TodoTagDialog {
  const TodoContextTagDialog({
    super.tagName = 'context',
    super.key,
  });

  @override
  Set<String> availableTags(BuildContext context) {
    return context
        .read<TodoListBloc>()
        .state
        .contexts
        .where((c) => !context.read<TodoBloc>().state.todo.contexts.contains(c))
        .toSet();
  }

  @override
  void onSubmit(BuildContext context, List<String> values) {
    context.read<TodoBloc>().add(TodoContextsAdded(values));
  }

  @override
  State<TodoContextTagDialog> createState() => _TodoContextTagDialogState();
}

class _TodoContextTagDialogState
    extends _TodoTagDialogState<TodoContextTagDialog> {}

class TodoKeyValueTagDialog extends TodoTagDialog {
  const TodoKeyValueTagDialog({
    super.tagName = 'key:value',
    super.key,
  });

  @override
  Set<String> availableTags(BuildContext context) {
    final Set<String> formattedKeyValues =
        context.read<TodoBloc>().state.todo.formattedKeyValues;
    return context
        .read<TodoListBloc>()
        .state
        .keyValues
        .where((c) => !formattedKeyValues.contains(c))
        .toSet();
  }

  @override
  void onSubmit(BuildContext context, List<String> values) {
    context.read<TodoBloc>().add(TodoKeyValuesAdded(values));
  }

  @override
  State<TodoKeyValueTagDialog> createState() => _TodoKeyValueTagDialogState();
}

class _TodoKeyValueTagDialogState
    extends _TodoTagDialogState<TodoKeyValueTagDialog> {}
