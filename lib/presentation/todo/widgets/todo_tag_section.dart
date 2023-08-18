import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag_dialog.dart';

abstract class TodoTagSection extends StatelessWidget {
  final Icon leadingIcon;
  final List<String>? items;
  final bool readOnly;

  const TodoTagSection({
    required this.leadingIcon,
    this.items,
    this.readOnly = false,
    super.key,
  });

  void _showDialog({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) => child,
    );
  }
}

class TodoPriorityTags extends TodoTagSection {
  const TodoPriorityTags({
    super.leadingIcon = const Icon(Icons.outlined_flag),
    super.items,
    super.readOnly,
    super.key,
  });

  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoPriorityAdded(value));
    } else {
      context.read<TodoBloc>().add(const TodoPriorityRemoved());
    }
  }

  Widget _buildPriorityChips(List<String> priorities) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (previousState.todo.priority == state.todo.priority) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return GenericChipGroup(
          children: [
            for (var p in priorities)
              GenericChoiceChip(
                label: p,
                selected: p == state.todo.priority,
                color: priorityChipColor,
                onSelected: !readOnly
                    ? (bool selected) => _onSelected(context, p, selected)
                    : null,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      minLeadingWidth: 40.0,
      leading: leadingIcon,
      title: _buildPriorityChips(priorities),
    );
  }
}

class TodoProjectTags extends TodoTagSection {
  const TodoProjectTags({
    super.leadingIcon = const Icon(Icons.rocket_launch_outlined),
    super.items,
    super.readOnly,
    super.key,
  });

  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoProjectAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoProjectRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: TodoProjectTagDialog(
        onPressed: () {},
      ),
    );
  }

  Widget _buildProjectChips(List<String> projects) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (const IterableEquality()
            .equals(previousState.todo.projects, state.todo.projects)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return GenericChipGroup(
          children: [
            for (var p in projects)
              GenericChoiceChip(
                label: p,
                selected: state.todo.projects.contains(p),
                color: projectChipColor,
                onSelected: !readOnly
                    ? (bool selected) => _onSelected(context, p, selected)
                    : null,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        if (const IterableEquality()
            .equals(previousState.projects, state.projects)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoListState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildProjectChips(items ?? state.projects),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new project tag',
                  onPressed: () => _openDialog(context),
                )
              : null,
        );
      },
    );
  }
}

class TodoContextTags extends TodoTagSection {
  const TodoContextTags({
    super.leadingIcon = const Icon(Icons.sell_outlined),
    super.items,
    super.readOnly,
    super.key,
  });

  void _onSelected(BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoContextAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoContextRemoved(value));
    }
  }

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: TodoContextTagDialog(
        onPressed: () {},
      ),
    );
  }

  Widget _buildContextChips(List<String> contexts) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (const IterableEquality()
            .equals(previousState.todo.contexts, state.todo.contexts)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return GenericChipGroup(
          children: [
            for (var c in contexts)
              GenericChoiceChip(
                label: c,
                selected: state.todo.contexts.contains(c),
                color: contextChipColor,
                onSelected: !readOnly
                    ? (bool selected) => _onSelected(context, c, selected)
                    : null,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        if (const IterableEquality()
            .equals(previousState.contexts, state.contexts)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoListState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildContextChips(items ?? state.contexts),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new context tag',
                  onPressed: () => _openDialog(context),
                )
              : null,
        );
      },
    );
  }
}

class TodoKeyValueTags extends TodoTagSection {
  const TodoKeyValueTags({
    super.leadingIcon = const Icon(Icons.join_inner_outlined),
    super.items,
    super.readOnly,
    super.key,
  });

  void _onDeleted(BuildContext context, String value) {}

  void _openDialog(BuildContext context) {
    _showDialog(
      context: context,
      child: TodoKeyValueTagDialog(
        onPressed: () {},
      ),
    );
  }

  Widget _buildKeyValueChips(List<String> keyValues) {
    return BlocBuilder<TodoBloc, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        if (const IterableEquality()
            .equals(previousState.todo.contexts, state.todo.contexts)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoState state) {
        return GenericChipGroup(
          children: [
            for (var kv in keyValues)
              GenericInputChip(
                label: kv,
                color: keyValueChipColor,
                onSelected: null,
                onDeleted: !readOnly ? () => _onDeleted(context, kv) : null,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      buildWhen: (TodoListState previousState, TodoListState state) {
        if (const IterableEquality()
            .equals(previousState.contexts, state.contexts)) {
          return false;
        } else {
          return true;
        }
      },
      builder: (BuildContext context, TodoListState state) {
        return ListTile(
          key: key,
          minLeadingWidth: 40.0,
          leading: leadingIcon,
          title: _buildKeyValueChips(items ?? state.keyValues),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new key:value tag',
                  onPressed: () => _openDialog(context),
                )
              : null,
        );
      },
    );
  }
}
