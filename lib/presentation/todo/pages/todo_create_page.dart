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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: Text(state.message),
                  ),
                );
              } else if (state is TodoSuccess) {
                context.pushNamed("todo-list");
              }
            },
            builder: (BuildContext context, TodoState state) {
              return Scaffold(
                appBar: const MainAppBar(
                  title: "Add",
                ),
                body: _buildBody(),
                floatingActionButton: state.todo.description.isNotEmpty
                    ? _buildFloatingActionButton(context, state)
                    : null,
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
        context.goNamed("todo-list");
        context
            .read<TodoListBloc>()
            .add(TodoListTodoSubmitted(todo: state.todo));
      },
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              const TodoStringTextField(),
              const Divider(),
              const TodoPriorityTags(),
              const TodoCreationDateItem(),
              const TodoDueDateItem(),
              TodoProjectTags(availableTags: availableProjectTags),
              TodoContextTags(availableTags: availableContextTags),
              TodoKeyValueTags(availableTags: availableKeyValueTags),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}
