import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/tag_dialog.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

class KeyValueTagDialog extends TagDialog {
  const KeyValueTagDialog({
    required super.cubit,
    super.title = 'Key Values',
    super.tagName = 'key:value',
    super.availableTags,
    super.key = const Key('addKeyValueTagDialog'),
  });

  @override
  RegExp get regex => RegExp(r'^([^\+\@].*[^:\s]):(.*[^:\s])$');

  static Future<void> dialog({
    required BuildContext context,
    required TodoCubit cubit,
    required Set<String> availableTags,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => KeyValueTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  void onSubmit(BuildContext context, Set<String> values) =>
      cubit.updateKeyValues(values);

  @override
  State<KeyValueTagDialog> createState() => _KeyValueTagDialogState();
}

class _KeyValueTagDialogState extends TagDialogState<KeyValueTagDialog> {
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
