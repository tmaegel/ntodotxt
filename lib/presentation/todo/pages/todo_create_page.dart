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

class TodoCreatePage extends StatelessWidget {
  const TodoCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoListRepository todoListRepository =
        context.read<TodoListRepository>();
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => TodoBloc(
        todoListRepository: todoListRepository,
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

  /// Save new todo
  void _saveAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoSubmitted(state.todo.id));
    context.goNamed("todo-view", extra: state.todo);
  }

  /// Cancel current create process
  void _cancelAction(BuildContext context) {
    context.pop();
  }

  Widget _buildTodoTextField(BuildContext context, TodoState state) {
    return TextFormField(
      key: const Key('createTodoView_textFormField'),
      initialValue: state.todo.description,
      minLines: 1,
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: 'Enter your todo description here ...',
        contentPadding: EdgeInsets.all(18.0), // 16px + 2px
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        context.read<TodoBloc>().add(TodoDescriptionChanged(value));
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required TodoState state,
    bool transparentDivider = false,
  }) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildTodoTextField(context, state),
                  Divider(
                      color: transparentDivider ? Colors.transparent : null),
                  const TodoPriorityTags(),
                  Divider(
                      color: transparentDivider ? Colors.transparent : null),
                  const TodoProjectTags(),
                  Divider(
                      color: transparentDivider ? Colors.transparent : null),
                  const TodoContextTags(),
                  Divider(
                      color: transparentDivider ? Colors.transparent : null),
                  const TodoKeyValueTags(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TodoCreateNarrowView extends TodoCreateView {
  const TodoCreateNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "Create",
            leadingAction: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelAction(context),
            ),
          ),
          body: _buildBody(
            context: context,
            state: state,
          ),
          floatingActionButton: PrimaryFloatingActionButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            action: () => _saveAction(context, state),
          ),
        );
      },
    );
  }
}

class TodoCreateWideView extends TodoCreateView {
  const TodoCreateWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "Create",
            leadingAction: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelAction(context),
            ),
            toolbar: _buildToolBar(context, state),
          ),
          body: _buildBody(
            context: context,
            state: state,
            transparentDivider: true,
          ),
        );
      },
    );
  }

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Save',
          icon: const Icon(Icons.save),
          onPressed: () => _saveAction(context, state),
        ),
      ],
    );
  }
}
