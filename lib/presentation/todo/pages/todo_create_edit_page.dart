import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/misc.dart' show SnackBarHandler;
import 'package:ntodotxt/presentation/todo/states/todo_cubit.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_detail_items.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_text_field.dart';

class TodoCreateEditPage extends StatelessWidget {
  final Todo? todo;
  final Set<String> availableProjectTags;
  final Set<String> availableContextTags;
  final Set<String> availableKeyValueTags;

  const TodoCreateEditPage({
    this.todo,
    this.availableProjectTags = const {},
    this.availableContextTags = const {},
    this.availableKeyValueTags = const {},
    super.key,
  });

  bool get createMode => todo == null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoCubit(
        todo: todo ?? Todo(),
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
                  if (!createMode)
                    IconButton(
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
                    ),
                  IconButton(
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
                ],
              ),
            ),
            body: ListView(
              children: [
                const TodoStringTextField(),
                const Divider(),
                const TodoPriorityTags(),
                const TodoCreationDateItem(),
                if (!createMode) const TodoCompletionDateItem(),
                const TodoDueDateItem(),
                TodoProjectTags(
                  availableTags: availableProjectTags
                      .where((p) => !state.todo.projects.contains(p))
                      .toSet(),
                ),
                TodoContextTags(
                  availableTags: availableContextTags
                      .where((c) => !state.todo.contexts.contains(c))
                      .toSet(),
                ),
                TodoKeyValueTags(
                  availableTags: availableKeyValueTags
                      .where((kv) => !state.todo.fmtKeyValues.contains(kv))
                      .toSet(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
