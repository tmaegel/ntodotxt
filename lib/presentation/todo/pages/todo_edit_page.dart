import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag_section.dart';

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
        todoListRepository: context.read<TodoListRepository>(),
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

  Widget _buildTodoTextField(BuildContext context, TodoState state) {
    return TextFormField(
      key: const Key('editTodoView_textFormField'),
      initialValue: state.todo.description,
      minLines: 1,
      maxLines: 5,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: const InputDecoration(
        hintText: 'Enter your todo description here ...',
        isDense: true,
        filled: false,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      onChanged: (value) {
        context.read<TodoBloc>().add(TodoDescriptionChanged(value));
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, TodoState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => context.read<TodoBloc>().add(const TodoSubmitted()),
    );
  }

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () {
            context.read<TodoBloc>().add(const TodoDeleted());
            context.goNamed("todo-list");
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

  Widget _buildBody({
    required BuildContext context,
    required TodoState state,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 20, bottom: 24),
                child: _buildTodoTextField(context, state),
              ),
              const Divider(),
              const TodoPriorityTags(),
              const TodoProjectTags(),
              const TodoContextTags(),
              const TodoKeyValueTags(),
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
              content: Text(state.error),
            ),
          );
        } else if (state is TodoSuccess) {
          context.goNamed("todo-list");
        }
      },
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          appBar: const MainAppBar(
            title: "Edit",
          ),
          body: _buildBody(
            context: context,
            state: state,
          ),
          floatingActionButton: _buildFloatingActionButton(context, state),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          bottomNavigationBar: PrimaryBottomAppBar(
            children: [
              _buildToolBar(context, state),
            ],
          ),
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
              content: Text(state.error),
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
          body: _buildBody(
            context: context,
            state: state,
          ),
          floatingActionButton: _buildFloatingActionButton(context, state),
        );
      },
    );
  }
}
