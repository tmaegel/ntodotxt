import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart' show Priority;
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/filter/states/filter_cubit.dart'
    show FilterCubit;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';

class PriorityTag {
  Priority priority;
  bool selected;

  PriorityTag({
    required this.priority,
    required this.selected,
  });

  @override
  String toString() => priority.name;
}

class PriorityTagDialog extends StatefulWidget {
  final String title;
  final Set<Priority> availableTags;

  const PriorityTagDialog({
    required this.title,
    this.availableTags = const {},
    super.key,
  });

  @override
  State<PriorityTagDialog> createState() => PriorityTagDialogState();
}

class PriorityTagDialogState<T extends PriorityTagDialog> extends State<T> {
  // Holds the selected tags before adding to the regular state.
  Set<PriorityTag> tags = {};

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Set<PriorityTag> get sortedTags {
    List<PriorityTag> t = tags.toList()
      ..sort(
        (PriorityTag a, PriorityTag b) => a.toString().compareTo(b.toString()),
      );
    return t.toSet();
  }

  void onUpdate(PriorityTag value, bool selected) {}

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  title: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              if (tags.isNotEmpty) const Divider(),
              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                    title: GenericChipGroup(
                      children: [
                        for (var t in sortedTags)
                          GenericChoiceChip(
                            label: Text(t.priority.name),
                            selected: t.selected,
                            onSelected: (bool selected) =>
                                onUpdate(t, selected),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class FilterPriorityTagDialog extends PriorityTagDialog {
  final FilterCubit cubit;

  const FilterPriorityTagDialog({
    required this.cubit,
    super.title = 'Priorities',
    super.availableTags,
    super.key = const Key('FilterPriorityTagDialog'),
  });

  static Future<void> dialog({
    required BuildContext context,
    required FilterCubit cubit,
    required Set<Priority> availableTags,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => FilterPriorityTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<FilterPriorityTagDialog> createState() =>
      _FilterPriorityTagDialogState();
}

class _FilterPriorityTagDialogState
    extends PriorityTagDialogState<FilterPriorityTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (Priority t) => PriorityTag(
          priority: t,
          selected: widget.cubit.state.filter.priorities.contains(t),
        ),
      ),
    };
  }

  @override
  void onUpdate(PriorityTag value, bool selected) {
    setState(() {
      value.selected = selected;
    });
    widget.cubit.updatePriorities({
      for (PriorityTag t in tags)
        if (t.selected) t.priority
    });
  }
}

class TodoPriorityTagDialog extends PriorityTagDialog {
  final TodoCubit cubit;

  const TodoPriorityTagDialog({
    required this.cubit,
    super.title = 'Priorities',
    super.availableTags,
    super.key = const Key('TodoPriorityTagDialog'),
  });

  static Future<void> dialog({
    required BuildContext context,
    required TodoCubit cubit,
    required Set<Priority> availableTags,
  }) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => TodoPriorityTagDialog(
        cubit: cubit,
        availableTags: availableTags,
      ),
    );
  }

  @override
  State<TodoPriorityTagDialog> createState() => _TodoPriorityTagDialogState();
}

class _TodoPriorityTagDialogState
    extends PriorityTagDialogState<TodoPriorityTagDialog> {
  @override
  void initState() {
    super.initState();
    super.tags = {
      ...widget.availableTags.map(
        (Priority t) => PriorityTag(
          priority: t,
          selected: widget.cubit.state.todo.priority == t,
        ),
      ),
    };
  }

  @override
  void onUpdate(PriorityTag value, bool selected) {
    setState(() {
      // Unset priorities first.
      for (PriorityTag tag in tags) {
        tag.selected = false;
      }
      value.selected = selected;
    });
    widget.cubit.setPriority(value.priority);
  }
}
