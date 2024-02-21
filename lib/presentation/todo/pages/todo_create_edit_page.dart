import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/key_values_dialog.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/constants/app.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_text_field.dart';

class TodoCreateEditPage extends StatelessWidget {
  final Todo? initTodo;
  final Set<String> availableProjectTags;
  final Set<String> availableContextTags;
  final Set<String> availableKeyValueTags;

  const TodoCreateEditPage({
    this.initTodo,
    this.availableProjectTags = const {},
    this.availableContextTags = const {},
    this.availableKeyValueTags = const {},
    super.key,
  });

  bool get createMode => initTodo == null;

  @override
  Widget build(BuildContext context) {
    final bool narrowView =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;

    return BlocProvider(
      create: (context) => TodoCubit(
        todo: initTodo ?? Todo(),
      ),
      child: BlocConsumer<TodoCubit, TodoState>(
        listener: (BuildContext context, TodoState state) {
          if (state is TodoError) {
            SnackBarHandler.error(context, state.message);
          }
        },
        builder: (BuildContext context, TodoState state) {
          return Scaffold(
            appBar: MainAppBar(
              title: createMode ? 'Create' : 'Edit',
              toolbar: Row(
                children: <Widget>[
                  if (!createMode) DeleteTodoButton(todo: state.todo),
                  if (!narrowView && initTodo != state.todo)
                    SaveTodoButton(
                      todo: state.todo,
                      narrowView: narrowView,
                    ),
                ],
              ),
            ),
            body: ListView(
              children: [
                const TodoStringTextField(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'General',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                const TodoPriorityItem(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'Dates',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                const TodoCreationDateItem(),
                if (!createMode) const TodoCompletionDateItem(),
                const TodoDueDateItem(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListTile(
                    title: Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                TodoProjectTagsItem(
                  availableTags: availableProjectTags
                      .where((p) => !state.todo.projects.contains(p))
                      .toSet(),
                ),
                TodoContextTagsItem(
                  availableTags: availableContextTags
                      .where((c) => !state.todo.contexts.contains(c))
                      .toSet(),
                ),
                TodoKeyValueTagsItem(
                  availableTags: availableKeyValueTags
                      .where((kv) => !state.todo.fmtKeyValues.contains(kv))
                      .toSet(),
                ),
                const SizedBox(height: 16),
              ],
            ),
            floatingActionButton: narrowView && initTodo != state.todo
                ? SaveTodoButton(
                    todo: state.todo,
                    narrowView: narrowView,
                  )
                : null,
          );
        },
      ),
    );
  }
}

class DeleteTodoButton extends StatelessWidget {
  final Todo todo;

  const DeleteTodoButton({
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Delete',
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final bool confirm = await ConfirmationDialog.dialog(
          context: context,
          title: 'Delete todo',
          message: 'Do you want to delete the todo?',
          actionLabel: 'Delete',
        );
        if (context.mounted && confirm) {
          context.read<TodoListBloc>().add(TodoListTodoDeleted(todo: todo));
          if (context.mounted) {
            SnackBarHandler.info(context, 'Todo deleted');
            context.pop();
          }
        }
      },
    );
  }
}

class SaveTodoButton extends StatelessWidget {
  final Todo todo;
  final bool narrowView;

  const SaveTodoButton({
    required this.todo,
    required this.narrowView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (narrowView) {
      return FloatingActionButton(
        tooltip: 'Save',
        child: const Icon(Icons.save),
        onPressed: () async {
          context.read<TodoListBloc>().add(TodoListTodoSubmitted(todo: todo));
          if (context.mounted) {
            SnackBarHandler.info(context, 'Todo saved');
            context.pop();
          }
        },
      );
    } else {
      return IconButton(
        tooltip: 'Save',
        icon: const Icon(Icons.save),
        onPressed: () async {
          context.read<TodoListBloc>().add(TodoListTodoSubmitted(todo: todo));
          if (context.mounted) {
            SnackBarHandler.info(context, 'Todo saved');
            context.pop();
          }
        },
      );
    }
  }
}

class TodoPriorityItem extends StatelessWidget {
  const TodoPriorityItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.priority != state.todo.priority;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            key: key,
            leading: const Icon(Icons.outlined_flag),
            title: const Text('Priority'),
            subtitle: Text(state.todo.priority.name),
            onTap: () => TodoPriorityTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<TodoCubit>(context),
              availableTags: Priorities.priorities,
            ),
          ),
        );
      },
    );
  }
}

class TodoProjectTagsItem extends StatelessWidget {
  final Set<String> availableTags;

  const TodoProjectTagsItem({
    this.availableTags = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.projects != state.todo.projects;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            key: key,
            leading: const Icon(Icons.rocket_launch_outlined),
            title: const Text('Projects'),
            subtitle: state.todo.projects.isEmpty
                ? const Text('-')
                : GenericChipGroup(
                    children: [
                      for (var t in state.todo.projects) BasicChip(label: t),
                    ],
                  ),
            onTap: () => TodoProjectTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<TodoCubit>(context),
              availableTags: availableTags,
            ),
          ),
        );
      },
    );
  }
}

class TodoContextTagsItem extends StatelessWidget {
  final Set<String> availableTags;

  const TodoContextTagsItem({
    this.availableTags = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return previousState.todo.contexts != state.todo.contexts;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            key: key,
            leading: const Icon(Icons.tag),
            title: const Text('Contexts'),
            subtitle: state.todo.contexts.isEmpty
                ? const Text('-')
                : GenericChipGroup(
                    children: [
                      for (var t in state.todo.contexts) BasicChip(label: t),
                    ],
                  ),
            onTap: () => TodoContextTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<TodoCubit>(context),
              availableTags: availableTags,
            ),
          ),
        );
      },
    );
  }
}

class TodoKeyValueTagsItem extends StatelessWidget {
  final Set<String> availableTags;

  const TodoKeyValueTagsItem({
    this.availableTags = const {},
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      buildWhen: (TodoState previousState, TodoState state) {
        return mapEquals(previousState.todo.keyValues, state.todo.keyValues) ==
            false;
      },
      builder: (BuildContext context, TodoState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            key: key,
            leading: const Icon(Icons.join_inner_outlined),
            title: const Text('Key values'),
            subtitle: state.todo.fmtKeyValues.isEmpty
                ? const Text('-')
                : GenericChipGroup(
                    children: [
                      for (var t in state.todo.fmtKeyValues)
                        BasicChip(label: t),
                    ],
                  ),
            onTap: () => TodoKeyValueTagDialog.dialog(
              context: context,
              cubit: BlocProvider.of<TodoCubit>(context),
              availableTags: availableTags,
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            key: key,
            leading: const Icon(Icons.event_available),
            title: const Text('Completion date'),
            subtitle: Text(
              state.todo.completionDate != null
                  ? state.todo.fmtCompletionDate
                  : '-',
            ),
            onTap: () => context.read<TodoCubit>().toggleCompletion(),
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
            key: key,
            leading: const Icon(Icons.edit_calendar),
            title: const Text('Creation date'),
            subtitle: Text(
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListTile(
              key: key,
              leading: const Icon(Icons.event),
              title: const Text('Due date'),
              subtitle: Text(Todo.date2Str(state.todo.dueDate) ?? '-'),
              onTap: () {
                if (state.todo.dueDate == null) {
                  _pickDateDialog(context);
                } else {
                  context.read<TodoCubit>().removeKeyValue('due:$dueDate');
                }
              }),
        );
      },
    );
  }

  void _pickDateDialog(BuildContext context) {
    final DateTime now = DateTime.now();
    showDatePicker(
      useRootNavigator: false,
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    ).then(
      (date) {
        if (date != null) {
          final String? formattedDate = Todo.date2Str(date);
          if (formattedDate != null) {
            context.read<TodoCubit>().addKeyValue(
                  'due:$formattedDate',
                );
          }
        }
      },
    );
  }
}
