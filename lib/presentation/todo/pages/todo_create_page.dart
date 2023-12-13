import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/misc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_detail_items.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_text_field.dart';

class TodoCreatePage extends StatelessWidget {
  final Todo? _todo;
  final Set<String> availableProjectTags;
  final Set<String> availableContextTags;
  final Set<String> availableKeyValueTags;

  const TodoCreatePage({
    Todo? todo,
    this.availableProjectTags = const {},
    this.availableContextTags = const {},
    this.availableKeyValueTags = const {},
    super.key,
  }) : _todo = todo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoBloc(
        todo: _todo ?? Todo(),
      ),
      child: Builder(
        builder: (BuildContext context) {
          return BlocConsumer<TodoBloc, TodoState>(
            listener: (BuildContext context, TodoState state) {
              if (state is TodoError) {
                SnackBarHandler.error(context, state.message);
              } else if (state is TodoSuccess) {
                context.pushNamed('todo-list');
              }
            },
            builder: (BuildContext context, TodoState state) {
              return Scaffold(
                appBar: const MainAppBar(
                  title: 'Add',
                ),
                floatingActionButton: state.todo.description.isNotEmpty
                    ? _buildFloatingActionButton(context, state)
                    : null,
                body: ListView(
                  children: [
                    const TodoStringTextField(),
                    const Divider(),
                    const TodoPriorityTags(),
                    const TodoCreationDateItem(),
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
}
