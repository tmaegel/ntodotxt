import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/tag_dialog.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

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
  void onSubmit(BuildContext context, Set<String> values) =>
      cubit.updateKeyValues(values);

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
        (String t) => Tag(name: t, selected: false),
      ),
      ...widget.cubit.state.todo.fmtKeyValues.map(
        (String t) => Tag(name: t, selected: true),
      ),
    };
  }
}
