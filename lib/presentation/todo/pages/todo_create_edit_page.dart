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
  final Set<String> projects;
  final Set<String> contexts;
  final Set<String> keyValues;

  const TodoCreateEditPage({
    this.initTodo,
    this.projects = const {},
    this.contexts = const {},
    this.keyValues = const {},
    super.key,
  });

  bool get createMode => initTodo == null;

  @override
  Widget build(BuildContext context) {
    final bool narrowView =
        MediaQuery.of(context).size.width < maxScreenWidthCompact;
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return BlocProvider(
      create: (BuildContext context) => TodoCubit(
        todo: initTodo ?? Todo(),
      ),
      child: BlocListener<TodoCubit, TodoState>(
        listener: (BuildContext context, TodoState state) {
          if (state is TodoError) {
            SnackBarHandler.error(context, state.message);
          }
        },
        child: Scaffold(
          appBar: MainAppBar(
            title: createMode ? 'Create' : 'Edit',
            toolbar: Row(
              children: <Widget>[
                if (!createMode) const DeleteTodoIconButton(),
                if (!narrowView) SaveTodoIconButton(initTodo: initTodo),
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
              TodoProjectTagsItem(availableTags: projects),
              TodoContextTagsItem(availableTags: contexts),
              TodoKeyValueTagsItem(availableTags: keyValues),
              const SizedBox(height: 16),
            ],
          ),
          floatingActionButton: keyboardIsOpen || !narrowView
              ? null
              : SaveTodoFABButton(initTodo: initTodo),
        ),
      ),
    );
  }
}

class DeleteTodoIconButton extends StatelessWidget {
  const DeleteTodoIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (BuildContext context, TodoState state) {
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
              context
                  .read<TodoListBloc>()
                  .add(TodoListTodoDeleted(todo: state.todo));
              if (context.mounted) {
                SnackBarHandler.info(context, 'Todo deleted');
                context.pop();
              }
            }
          },
        );
      },
    );
  }
}

class SaveTodoIconButton extends StatelessWidget {
  final Todo? initTodo;

  const SaveTodoIconButton({
    required this.initTodo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Visibility(
          visible: initTodo != state.todo && state.todo.description.isNotEmpty,
          child: IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save),
            onPressed: () async {
              context
                  .read<TodoListBloc>()
                  .add(TodoListTodoSubmitted(todo: state.todo));
              if (context.mounted) {
                SnackBarHandler.info(context, 'Todo saved');
                context.pop();
              }
            },
          ),
        );
      },
    );
  }
}

class SaveTodoFABButton extends StatelessWidget {
  final Todo? initTodo;

  const SaveTodoFABButton({
    required this.initTodo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Visibility(
          visible: initTodo != state.todo && state.todo.description.isNotEmpty,
          child: FloatingActionButton(
            tooltip: 'Save',
            child: const Icon(Icons.save),
            onPressed: () async {
              context
                  .read<TodoListBloc>()
                  .add(TodoListTodoSubmitted(todo: state.todo));
              if (context.mounted) {
                SnackBarHandler.info(context, 'Todo saved');
                context.pop();
              }
            },
          ),
        );
      },
    );
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
              availableTags: availableTags
                  .where((p) => !state.todo.projects.contains(p))
                  .toSet(),
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
              availableTags: availableTags
                  .where((c) => !state.todo.contexts.contains(c))
                  .toSet(),
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
        return previousState.todo.keyValues != state.todo.keyValues;
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
              availableTags: availableTags
                  .where((kv) => !state.todo.fmtKeyValues.contains(kv))
                  .toSet(),
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
        return previousState.todo.keyValues != state.todo.keyValues;
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
