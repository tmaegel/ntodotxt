import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';
import 'package:ntodotxt/common_widgets/contexts_dialog.dart';
import 'package:ntodotxt/common_widgets/key_values_dialog.dart';
import 'package:ntodotxt/common_widgets/priorities_dialog.dart';
import 'package:ntodotxt/common_widgets/projects_dialog.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';

class TodoCreateEditPage extends StatelessWidget {
  final Todo initTodo;
  final Set<String> projects;
  final Set<String> contexts;
  final Set<String> keyValues;
  final bool newTodo;

  const TodoCreateEditPage({
    required this.initTodo,
    this.projects = const {},
    this.contexts = const {},
    this.keyValues = const {},
    this.newTodo = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => TodoCubit(todo: initTodo),
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: TodoDialogWrapper(
          initTodo: initTodo,
          newTodo: newTodo,
          child: Scaffold(
            appBar: MainAppBar(
              title: newTodo ? 'Create' : 'Edit',
              toolbar: Row(
                children: <Widget>[
                  if (!newTodo) const DeleteTodoIconButton(),
                  SaveTodoIconButton(initTodo: initTodo),
                ],
              ),
            ),
            body: ListView(
              children: [
                const TodoDescriptionTextField(),
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
                if (!newTodo) const TodoCompletionDateItem(),
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
          ),
        ),
      ),
    );
  }
}

class TodoDialogWrapper extends StatelessWidget {
  final Widget child;
  final Todo? initTodo;
  final bool newTodo;

  const TodoDialogWrapper({
    required this.child,
    required this.initTodo,
    required this.newTodo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              return;
            }
            if (state.todo.description.isEmpty) {
              if (!await ConfirmationDialog.dialog(
                context: context,
                title: newTodo ? 'Create todo' : 'Edit todo',
                message: 'Cannot save a todo with an empty name.',
                cancelLabel: 'Cancel',
                actionLabel: 'Continue',
              )) {
                if (context.mounted) {
                  context.pop();
                }
              }
            } else {
              if (initTodo != state.todo) {
                final bool confirm = await ConfirmationDialog.dialog(
                  context: context,
                  title: 'Save todo',
                  message:
                      'Todo contains unsaved changes. These will be irrecoverably lost.',
                  actionLabel: 'Save',
                  cancelLabel: 'Discard',
                );
                if (context.mounted && confirm) {
                  context
                      .read<TodoListBloc>()
                      .add(TodoListTodoSubmitted(todo: state.todo));
                  if (newTodo) {
                    if (context.mounted) {
                      SnackBarHandler.info(context, 'Todo has been created');
                    }
                  } else {
                    if (context.mounted) {
                      SnackBarHandler.info(context, 'Todo has been updated');
                    }
                  }
                }
              }
              if (context.mounted) {
                context.pop();
              }
            }
          },
          child: child,
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
              cancelLabel: 'Cancel',
            );
            if (context.mounted && confirm) {
              context
                  .read<TodoListBloc>()
                  .add(TodoListTodoDeleted(todo: state.todo));
              if (context.mounted) {
                SnackBarHandler.info(context, 'Todo has been deleted');
                context.pop();
              }
            }
          },
        );
      },
    );
  }
}

class TodoDescriptionTextField extends StatefulWidget {
  const TodoDescriptionTextField({super.key});

  @override
  State<TodoDescriptionTextField> createState() =>
      _TodoDescriptionTextFieldState();
}

class _TodoDescriptionTextFieldState extends State<TodoDescriptionTextField> {
  late GlobalKey<FormFieldState> _textFormKey;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _textFormKey = GlobalKey<FormFieldState>();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (BuildContext context, TodoState state) {
        // Setting text and selection together.
        int base = _controller.selection.base.offset;
        _controller.value = _controller.value.copyWith(
          text: state.todo.description,
          selection: TextSelection.fromPosition(
            TextPosition(
              offset: base < 0 || base > state.todo.description.length
                  ? state.todo.description.length
                  : base,
            ),
          ),
        );
        return TextFormField(
          key: _textFormKey,
          controller: _controller,
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\n')),
          ],
          style: Theme.of(context).textTheme.titleMedium,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'todo +project @context key:val',
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
          ),
          onChanged: (String value) =>
              context.read<TodoCubit>().updateDescription(_controller.text),
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
            subtitle: Text(dueDate ?? '-'),
            trailing: state.todo.dueDate == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      context.read<TodoCubit>().removeKeyValue('due:$dueDate');
                    },
                  ),
            onTap: () {
              _pickDateDialog(
                context: context,
                initialDate: state.todo.dueDate,
              );
            },
          ),
        );
      },
    );
  }

  void _pickDateDialog({required BuildContext context, DateTime? initialDate}) {
    final DateTime initial = initialDate ?? DateTime.now();
    showDatePicker(
      useRootNavigator: false,
      context: context,
      firstDate: initial.subtract(const Duration(days: 3650)),
      initialDate: initial,
      lastDate: initial.add(const Duration(days: 3650)),
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
