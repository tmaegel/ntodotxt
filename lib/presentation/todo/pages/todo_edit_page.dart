import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_detail_items.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_text_field.dart';

class TodoEditPage extends StatelessWidget {
  final Todo _todo;
  final Set<String> availableProjectTags;
  final Set<String> availableContextTags;
  final Set<String> availableKeyValueTags;

  const TodoEditPage({
    required Todo todo,
    this.availableProjectTags = const {},
    this.availableContextTags = const {},
    this.availableKeyValueTags = const {},
    super.key,
  }) : _todo = todo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(
        todo: _todo,
      ),
      child: Builder(
        builder: (BuildContext context) {
          return BlocConsumer<TodoBloc, TodoState>(
            listener: (BuildContext context, TodoState state) {
              if (state is TodoError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: Text(state.message),
                  ),
                );
              } else if (state is TodoSuccess) {
                context.goNamed('todo-list');
              }
            },
            builder: (BuildContext context, TodoState state) {
              return Scaffold(
                appBar: MainAppBar(
                  title: 'Edit',
                  toolbar: _buildToolBar(context, state),
                ),
                floatingActionButton: state.todo.description.isNotEmpty
                    ? _buildFloatingActionButton(context, state)
                    : null,
                body: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          const TodoStringTextField(),
                          const Divider(),
                          const TodoPriorityTags(),
                          const TodoCreationDateItem(),
                          const TodoCompletionDateItem(),
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
                                .where((kv) =>
                                    !state.todo.fmtKeyValues.contains(kv))
                                .toSet(),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, TodoState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () {
        context.goNamed('todo-list');
        context
            .read<TodoListBloc>()
            .add(TodoListTodoSubmitted(todo: state.todo));
      },
    );
  }

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () {
            context.goNamed('todo-list');
            context
                .read<TodoListBloc>()
                .add(TodoListTodoDeleted(todo: state.todo));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                content: const Text('Todo deleted.'),
              ),
            );
          },
        ),
      ],
    );
  }
}
