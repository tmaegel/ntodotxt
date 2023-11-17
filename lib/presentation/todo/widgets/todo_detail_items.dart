import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
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
      context.read<TodoBloc>().add(TodoPriorityAdded(value));
    } else {
      context.read<TodoBloc>().add(const TodoPriorityRemoved());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.priority != state.todo.priority;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
          leading: Tooltip(
            message: 'Priority',
            child: leadingIcon,
          ),
          title: _buildChips(
            context: context,
            tags: priorities,
            selectedTags: {state.todo.priority},
          ),
        );
      },
    );
  }
}

class TodoProjectTags extends TodoTagSection {
  const TodoProjectTags({
    super.leadingIcon = const Icon(Icons.rocket_launch_outlined),
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoProjectsAdded([value]));
    } else {
      context.read<TodoBloc>().add(TodoProjectRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const TodoProjectTagDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.projects != state.todo.projects;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
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
        );
      },
    );
  }
}

class TodoContextTags extends TodoTagSection {
  const TodoContextTags({
    super.leadingIcon = const Icon(Icons.tag),
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoContextsAdded([value]));
    } else {
      context.read<TodoBloc>().add(TodoContextRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const TodoContextTagDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.contexts != state.todo.contexts;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
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
        );
      },
    );
  }
}

class TodoKeyValueTags extends TodoTagSection {
  const TodoKeyValueTags({
    super.leadingIcon = const Icon(Icons.join_inner_outlined),
    super.key,
  });

  @override
  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoKeyValuesAdded([value]));
    } else {
      context.read<TodoBloc>().add(TodoKeyValueRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const TodoKeyValueTagDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return mapEquals(previousState.todo.keyValues, state.todo.keyValues) ==
            false;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
          leading: Tooltip(
            message: 'Key values',
            child: leadingIcon,
          ),
          title: _buildChips(
            context: context,
            tags: state.todo.formattedKeyValues,
            selectedTags: state.todo.formattedKeyValues,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add key:value tag',
            onPressed: () => _openDialog(context),
          ),
        );
      },
    );
  }
}

class TodoCompletionItem extends StatelessWidget {
  const TodoCompletionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.completion != state.todo.completion;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
          leading: const Tooltip(
            message: 'Completion',
            child: Icon(Icons.check_circle_outline),
          ),
          trailing: Checkbox(
            value: state.todo.completion,
            onChanged: (bool? completion) {
              context.read<TodoBloc>().add(
                    TodoCompletionToggled(completion ?? false),
                  );
            },
          ),
          title: Text(state.todo.completion ? 'Completed' : 'Incompleted'),
        );
      },
    );
  }
}

class TodoCompletionDateItem extends StatelessWidget {
  const TodoCompletionDateItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.completionDate != state.todo.completionDate;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
          leading: const Tooltip(
            message: 'Completion date',
            child: Icon(Icons.event_available),
          ),
          title: Text(
            state.todo.completionDate != null
                ? state.todo.formattedCompletionDate
                : 'no completion date',
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
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.creationDate != state.todo.creationDate;
      },
      builder: (BuildContext context, TodoState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40,
          leading: const Tooltip(
            message: 'Creation date',
            child: Icon(Icons.edit_calendar),
          ),
          title: Text(
            state.todo.creationDate != null
                ? state.todo.formattedCreationDate
                : Todo.date2Str(DateTime.now())!,
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
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return mapEquals(previousState.todo.keyValues, state.todo.keyValues) ==
            false;
      },
      builder: (BuildContext context, TodoState state) {
        final String? dueDate = Todo.date2Str(state.todo.dueDate);
        return ListTile(
          key: key,
          minLeadingWidth: 40,
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
                  onPressed: () {
                    context.read<TodoBloc>().add(
                          TodoKeyValueRemoved('due:$dueDate'),
                        );
                  },
                ),
          onTap: () => _pickDateDialog(context),
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
            context.read<TodoBloc>().add(
                  TodoKeyValuesAdded(['due:$formattedDate']),
                );
          }
        }
      },
    );
  }
}
