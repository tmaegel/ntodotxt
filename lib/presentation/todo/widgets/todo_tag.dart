import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class TodoPriorityTags extends StatelessWidget {
  final bool readOnly;

  const TodoPriorityTags({
    this.readOnly = false,
    super.key,
  });

  /// Change priority
  void _changePriorityAction(
      BuildContext context, String value, bool selected) {
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
                    ? (bool selected) =>
                        _changePriorityAction(context, p, selected)
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
      leading: const Icon(Icons.outlined_flag),
      title: _buildPriorityChips(priorities),
    );
  }
}

class TodoProjectTags extends StatelessWidget {
  final List<String>? items;
  final bool readOnly;

  const TodoProjectTags({
    this.items,
    this.readOnly = false,
    super.key,
  });

  /// Change projects
  void _changeProjectsAction(
      BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoProjectAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoProjectRemoved(value));
    }
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
                    ? (bool selected) =>
                        _changeProjectsAction(context, p, selected)
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
          leading: const Icon(Icons.rocket_outlined),
          title: _buildProjectChips(items ?? state.projects),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new project tag',
                  onPressed: () {},
                )
              : null,
        );
      },
    );
  }
}

class TodoContextTags extends StatelessWidget {
  final List<String>? items;
  final bool readOnly;

  const TodoContextTags({
    this.items,
    this.readOnly = false,
    super.key,
  });

  /// Change contexts
  void _changeContextsAction(
      BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoContextAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoContextRemoved(value));
    }
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
                    ? (bool selected) =>
                        _changeContextsAction(context, c, selected)
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
          leading: const Icon(Icons.sell_outlined),
          title: _buildContextChips(items ?? state.contexts),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new context tag',
                  onPressed: () {},
                )
              : null,
        );
      },
    );
  }
}

class TodoKeyValueTags extends StatelessWidget {
  final List<String>? items;
  final bool readOnly;

  const TodoKeyValueTags({
    this.items,
    this.readOnly = false,
    super.key,
  });

  /// Delete context
  void _deleteContextAction(BuildContext context, String value) {}

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
                onDeleted:
                    !readOnly ? () => _deleteContextAction(context, kv) : null,
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
          leading: const Icon(Icons.join_inner_outlined),
          title: _buildKeyValueChips(items ?? state.keyValues),
          trailing: !readOnly
              ? IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new key-value pair',
                  onPressed: () {},
                )
              : null,
        );
      },
    );
  }
}
