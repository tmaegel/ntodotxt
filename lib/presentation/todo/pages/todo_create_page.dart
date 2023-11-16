import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_detail_items.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_text_field.dart';

class TodoCreatePage extends StatelessWidget {
  const TodoCreatePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => TodoBloc(
        todoListRepository: context.read<TodoListRepository>(),
        todo: const Todo.empty(),
      ),
      child: screenWidth < maxScreenWidthCompact
          ? const TodoCreateNarrowView()
          : const TodoCreateWideView(),
    );
  }
}

abstract class TodoCreateView extends StatelessWidget {
  const TodoCreateView({super.key});

  Widget _buildFloatingActionButton(BuildContext context, TodoState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => context.read<TodoBloc>().add(const TodoSubmitted()),
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

class TodoCreateNarrowView extends TodoCreateView {
  const TodoCreateNarrowView({super.key});

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
          context.pushNamed("todo-list");
        }
      },
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          appBar: const MainAppBar(
            title: "Create",
          ),
          body: _buildBody(),
          floatingActionButton: !state.todo.isDescriptionEmpty
              ? _buildFloatingActionButton(context, state)
              : null,
        );
      },
    );
  }
}

class TodoCreateWideView extends TodoCreateView {
  const TodoCreateWideView({super.key});

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
          context.pushNamed("todo-list");
        }
      },
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          appBar: const MainAppBar(
            title: "Create",
          ),
          body: _buildBody(),
          floatingActionButton: !state.todo.isDescriptionEmpty
              ? _buildFloatingActionButton(context, state)
              : null,
        );
      },
    );
  }
}
