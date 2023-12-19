import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag_dialog.dart';

abstract class TodoTagSection extends StatelessWidget {
  final Icon leadingIcon;

  const TodoTagSection({
    required this.leadingIcon,
    super.key,
  });

  void _showDialog({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => child,
    );
  }

  void _onSelected(BuildContext context, String value, bool selected);

  Widget _buildChips({
    required BuildContext context,
    required Set<String> tags,
    required Set<String?> selectedTags,
  }) {
    return GenericChipGroup(
      children: [
        for (var t in tags)
          GenericChoiceChip(
            label: Text(t),
            selected: selectedTags.contains(t),
            onSelected: (bool selected) => _onSelected(context, t, selected),
          ),
      ],
    );
  }
}

class TodoPriorityTags extends TodoTagSection {
  const TodoPriorityTags({
    super.leadingIcon = const Icon(Icons.outlined_flag),
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoCubit>().setPriority(Priorities.byName(value));
    } else {
      context.read<TodoCubit>().unsetPriority();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.priority != state.todo.priority;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: Tooltip(
              message: 'Priority',
              child: leadingIcon,
            ),
            title: _buildChips(
              context: context,
              tags: Priorities.priorityNames,
              selectedTags: {state.todo.priority.name},
            ),
          ),
        );
      },
    );
  }
}

class TodoProjectTags extends TodoTagSection {
  final Set<String> availableTags;

  const TodoProjectTags({
    super.leadingIcon = const Icon(Icons.rocket_launch_outlined),
    this.availableTags = const {},
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoCubit>().addMultipleProjects([value]);
    } else {
      context.read<TodoCubit>().removeProject(value);
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoCubit>(context),
        child: TodoProjectTagDialog(
          availableTags: availableTags,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.projects != state.todo.projects;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: Tooltip(
              message: 'Projects',
              child: leadingIcon,
            ),
            title: _buildChips(
              context: context,
              tags: state.todo.projects,
              selectedTags: state.todo.projects,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add project tag',
              onPressed: () => _openDialog(context),
            ),
          ),
        );
      },
    );
  }
}

class TodoContextTags extends TodoTagSection {
  final Set<String> availableTags;

  const TodoContextTags({
    super.leadingIcon = const Icon(Icons.tag),
    this.availableTags = const {},
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoCubit>().addMultipleContexts([value]);
    } else {
      context.read<TodoCubit>().removeContext(value);
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoCubit>(context),
        child: TodoContextTagDialog(
          availableTags: availableTags,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.contexts != state.todo.contexts;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: Tooltip(
              message: 'Contexts',
              child: leadingIcon,
            ),
            title: _buildChips(
              context: context,
              tags: state.todo.contexts,
              selectedTags: state.todo.contexts,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add context tag',
              onPressed: () => _openDialog(context),
            ),
          ),
        );
      },
    );
  }
}

class TodoKeyValueTags extends TodoTagSection {
  final Set<String> availableTags;

  const TodoKeyValueTags({
    super.leadingIcon = const Icon(Icons.join_inner_outlined),
    this.availableTags = const {},
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoCubit>().addMultipleKeyValues([value]);
    } else {
      context.read<TodoCubit>().removeKeyValue(value);
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoCubit>(context),
        child: TodoKeyValueTagDialog(
          availableTags: availableTags,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return mapEquals(previousState.todo.keyValues, state.todo.keyValues) ==
            false;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: Tooltip(
              message: 'Key values',
              child: leadingIcon,
            ),
            title: _buildChips(
              context: context,
              tags: state.todo.fmtKeyValues,
              selectedTags: state.todo.fmtKeyValues,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add key:value tag',
              onPressed: () => _openDialog(context),
            ),
          ),
        );
      },
    );
  }
}

class TodoCompletionDateItem extends StatelessWidget {
  const TodoCompletionDateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.completionDate != state.todo.completionDate;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: const Tooltip(
              message: 'Completion date',
              child: Icon(Icons.event_available),
            ),
            title: Text(
              state.todo.completionDate != null
                  ? state.todo.fmtCompletionDate
                  : 'Incompleted',
            ),
            trailing: Tooltip(
              message: state.todo.completion == true ? 'Undone' : 'Done',
              child: Checkbox(
                value: state.todo.completion,
                onChanged: (bool? completion) =>
                    context.read<TodoCubit>().toggleCompletion(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TodoCreationDateItem extends StatelessWidget {
  const TodoCreationDateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.creationDate != state.todo.creationDate;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: const Tooltip(
              message: 'Creation date',
              child: Icon(Icons.edit_calendar),
            ),
            title: Text(
              state.todo.creationDate != null
                  ? state.todo.fmtCreationDate
                  : Todo.date2Str(DateTime.now())!,
            ),
          ),
        );
      },
    );
  }
}

class TodoDueDateItem extends StatelessWidget {
  const TodoDueDateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return mapEquals(previousState.todo.keyValues, state.todo.keyValues) ==
            false;
      },
      builder: (BuildContext context, TodoState state) {
        final String? dueDate = Todo.date2Str(state.todo.dueDate);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ListTile(
            key: key,
            leading: const Tooltip(
              message: 'Due date',
              child: Icon(Icons.event),
            ),
            title: Text(Todo.date2Str(state.todo.dueDate) ?? 'no due date'),
            trailing: dueDate == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Unset due date',
                    onPressed: () => context
                        .read<TodoCubit>()
                        .removeKeyValue('due:$dueDate'),
                  ),
            onTap: () => _pickDateDialog(context),
          ),
        );
      },
    );
  }

  void _pickDateDialog(BuildContext context) {
    final DateTime now = DateTime.now();
    showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    ).then(
      (date) {
        if (date != null) {
          final String? formattedDate = Todo.date2Str(date);
          if (formattedDate != null) {
            context.read<TodoCubit>().addMultipleKeyValues(
              ['due:$formattedDate'],
            );
          }
        }
      },
    );
  }
}
