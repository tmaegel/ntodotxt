import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/tag_dialog.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

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
  void onSubmit(BuildContext context, Set<String> values) =>
      cubit.updateContexts(values);

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
  void onSubmit(BuildContext context, Set<String> values) =>
      cubit.updateContexts(values);

  @override
  State<TodoContextTagDialog> createState() => _TodoContextTagDialogState();
}

class _TodoContextTagDialogState extends TagDialogState<TodoContextTagDialog> {
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
