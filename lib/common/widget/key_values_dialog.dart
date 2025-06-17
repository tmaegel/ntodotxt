import 'package:flutter/material.dart';
import 'package:ntodotxt/common/widget/tag_dialog.dart';
import 'package:ntodotxt/todo/model/todo_model.dart';
import 'package:ntodotxt/todo/state/todo_cubit.dart';

class TodoKeyValueTagDialog extends TagDialog {
  final TodoCubit cubit;

  const TodoKeyValueTagDialog({
    required this.cubit,
    super.title = 'Key values',
    super.tagName = 'key:value',
    super.availableTags,
    super.addTags = true,
    super.key = const Key('TodoKeyValueTagDialog'),
  });

  @override
  RegExp get regex => Todo.patternKeyValue;

  static Future<void> dialog({
    required BuildContext context,
    required TodoCubit cubit,
    required Set<String> availableTags,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => TodoKeyValueTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<TodoKeyValueTagDialog> createState() => _TodoKeyValueTagDialogState();
}

class _TodoKeyValueTagDialogState
    extends TagDialogState<TodoKeyValueTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(
          name: t,
          selected: widget.cubit.state.todo.fmtKeyValues.contains(t),
        ),
      ),
      // Overwrites key values of todo with selected=true
      ...widget.cubit.state.todo.fmtKeyValues.map(
        (String t) => Tag(name: t, selected: true),
      ),
    };
  }

  @override
  void onUpdate() {
    widget.cubit.updateKeyValues({
      for (Tag t in tags)
        if (t.selected) t.name
    });
  }
}
