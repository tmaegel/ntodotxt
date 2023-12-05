import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';
import 'package:ntodotxt/presentation/todo/states/todo_state.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_detail_items.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_text_field.dart';

class TodoEditPage extends StatelessWidget {
  final Todo _todo;

  const TodoEditPage({
    required Todo todo,
    super.key,
  }) : _todo = todo;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => TodoBloc(
        todo: _todo,
      ),
      child: screenWidth < maxScreenWidthCompact
          ? const TodoEditNarrowView()
          : const TodoEditWideView(),
    );
  }
}

abstract class TodoEditView extends StatelessWidget {
  const TodoEditView({super.key});

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

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () {
            context.goNamed("todo-list");
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

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: const [
              TodoFullStringTextField(),
              Divider(),
              TodoPriorityTags(),
              TodoCompletionItem(),
              TodoCompletionDateItem(),
              TodoCreationDateItem(),
              TodoDueDateItem(),
              TodoProjectTags(),
              TodoContextTags(),
              TodoKeyValueTags(),
            ],
          ),
        ),
      ],
    );
  }
}

class TodoEditNarrowView extends TodoEditView {
  const TodoEditNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
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
          context.goNamed("todo-list");
        }
      },
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          appBar: MainAppBar(
            title: "Edit",
            toolbar: _buildToolBar(context, state),
          ),
          body: _buildBody(),
          floatingActionButton: state.todo.description.isNotEmpty
              ? _buildFloatingActionButton(context, state)
              : null,
        );
      },
    );
  }
}

class TodoEditWideView extends TodoEditView {
  const TodoEditWideView({super.key});

  @override
  Widget build(BuildContext context) {
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
          context.goNamed("todo-list");
        }
      },
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          appBar: MainAppBar(
            title: "Edit",
            toolbar: _buildToolBar(context, state),
          ),
          body: _buildBody(),
          floatingActionButton: state.todo.description.isNotEmpty
              ? _buildFloatingActionButton(context, state)
              : null,
        );
      },
    );
  }
}
