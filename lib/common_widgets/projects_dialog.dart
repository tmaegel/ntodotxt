import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/tag_dialog.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

class FilterProjectTagDialog extends TagDialog {
  final FilterCubit cubit;

  const FilterProjectTagDialog({
    required this.cubit,
    super.title = 'Projects',
    super.tagName = 'project',
    super.availableTags,
    super.addTags = false,
    super.key = const Key('FilterProjectTagDialog'),
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
      builder: (BuildContext context) => FilterProjectTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<FilterProjectTagDialog> createState() => _FilterProjectTagDialogState();
}

class _FilterProjectTagDialogState
    extends TagDialogState<FilterProjectTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(
          name: t,
          selected: widget.cubit.state.filter.projects.contains(t),
        ),
      ),
    };
  }

  @override
  void onUpdate() {
    widget.cubit.updateProjects({
      for (Tag t in tags)
        if (t.selected) t.name
    });
  }
}

class TodoProjectTagDialog extends TagDialog {
  final TodoCubit cubit;

  const TodoProjectTagDialog({
    required this.cubit,
    super.title = 'Projects',
    super.tagName = 'project',
    super.availableTags,
    super.addTags = true,
    super.key = const Key('TodoProjectTagDialog'),
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
      builder: (BuildContext context) => TodoProjectTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<TodoProjectTagDialog> createState() => _TodoProjectTagDialogState();
}

class _TodoProjectTagDialogState extends TagDialogState<TodoProjectTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (String t) => Tag(name: t, selected: false),
      ),
      ...widget.cubit.state.todo.projects.map(
        (String t) => Tag(name: t, selected: true),
      ),
    };
  }

  @override
  void onUpdate() {
    widget.cubit.updateProjects({
      for (Tag t in tags)
        if (t.selected) t.name
    });
  }
}
