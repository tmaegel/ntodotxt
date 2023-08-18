import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag.dart';

class TodoEditPage extends StatelessWidget {
  final Todo todo;

  const TodoEditPage({
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TodoListRepository todoListRepository =
        context.read<TodoListRepository>();
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => TodoBloc(
        todoListRepository: todoListRepository,
        todo: todo,
      ),
      child: screenWidth < maxScreenWidthCompact
          ? const TodoEditNarrowView()
          : const TodoEditWideView(),
    );
  }
}

abstract class TodoEditView extends StatelessWidget {
  const TodoEditView({super.key});

  /// Save current todo
  void _saveAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoSubmitted(state.todo.id));
    context.goNamed("todo-view", extra: state.todo);
  }

  /// Delete current todo
  void _deleteAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoDeleted(state.todo.id));
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current edit process
  void _cancelAction(BuildContext context, TodoState state) {
    context.pop();
  }

  Widget _buildTodoTextField(BuildContext context, TodoState state) {
    return TextFormField(
      key: const Key('editTodoView_textFormField'),
      initialValue: state.todo.description,
      minLines: 3,
      maxLines: 3,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorLightGrey,
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
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                key: key,
                minLeadingWidth: 40.0,
                leading: const Icon(Icons.edit_outlined),
                title: _buildTodoTextField(context, state),
                trailing: const SizedBox(),
              ),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoPriorityTags(),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoProjectTags(),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoContextTags(),
              Divider(color: transparentDivider ? Colors.transparent : null),
              TodoKeyValueTags(items: state.todo.formattedKeyValues),
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
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "Edit",
            leadingAction: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelAction(context, state),
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

class TodoEditWideView extends TodoEditView {
  const TodoEditWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "Edit",
            leadingAction: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _cancelAction(context, state),
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
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteAction(context, state),
        ),
        IconButton(
          tooltip: 'Save',
          icon: const Icon(Icons.save),
          onPressed: () => _saveAction(context, state),
        ),
      ],
    );
  }
}
