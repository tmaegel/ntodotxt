import 'package:flutter/material.dart';
import 'package:ntodotxt/common/widget/tag_dialog.dart';
import 'package:ntodotxt/filter/state/filter_cubit.dart' show FilterCubit;
import 'package:ntodotxt/todo/state/todo_cubit.dart';

class FilterContextTagDialog extends TagDialog {
  final FilterCubit cubit;

  const FilterContextTagDialog({
    required this.cubit,
    super.title = 'Contexts',
    super.tagName = 'context',
    super.availableTags,
    super.addTags = false,
    super.key = const Key('FilterContextTagDialog'),
  });

  @override
  RegExp get regex => RegExp(r'^\S+$');

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
    required Set<String> availableTags,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => FilterContextTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<FilterContextTagDialog> createState() => _FilterContextTagDialogState();
}

class _FilterContextTagDialogState
    extends TagDialogState<FilterContextTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(
          name: t,
          selected: widget.cubit.state.filter.contexts.contains(t),
        ),
      ),
    };
  }

  @override
  void onUpdate() {
    widget.cubit.updateContexts({
      for (Tag t in tags)
        if (t.selected) t.name
    });
  }
}

class TodoContextTagDialog extends TagDialog {
  final TodoCubit cubit;

  const TodoContextTagDialog({
    required this.cubit,
    super.title = 'Contexts',
    super.tagName = 'context',
    super.availableTags,
    super.addTags = true,
    super.key = const Key('TodoContextTagDialog'),
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
      builder: (BuildContext context) => TodoContextTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<TodoContextTagDialog> createState() => _TodoContextTagDialogState();
}

class _TodoContextTagDialogState extends TagDialogState<TodoContextTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(
          name: t,
          selected: widget.cubit.state.todo.contexts.contains(t),
        ),
      ),
      // Overwrites contexts of todo with selected=true
      ...widget.cubit.state.todo.contexts.map(
        (String t) => Tag(name: t, selected: true),
      ),
    };
  }

  @override
  void onUpdate() {
    widget.cubit.updateContexts({
      for (Tag t in tags)
        if (t.selected) t.name
    });
  }
}
