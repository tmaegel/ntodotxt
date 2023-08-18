import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag.dart';

class TodoViewPage extends StatelessWidget {
  final Todo todo;

  const TodoViewPage({
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
          ? const TodoViewNarrowView()
          : const TodoViewWideView(),
    );
  }
}

abstract class TodoViewView extends StatelessWidget {
  const TodoViewView({super.key});

  /// Edit current todo
  void _editAction(BuildContext context, TodoState state) {
    context.goNamed("todo-edit", extra: state.todo);
  }

  /// Cancel current view process
  void _cancelAction(BuildContext context) {
    context.pop();
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
                title: Text(state.todo.description),
                trailing: const SizedBox(),
              ),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoPriorityTags(readOnly: true),
              Divider(color: transparentDivider ? Colors.transparent : null),
              TodoProjectTags(items: state.todo.projects, readOnly: true),
              Divider(color: transparentDivider ? Colors.transparent : null),
              TodoContextTags(items: state.todo.contexts, readOnly: true),
              Divider(color: transparentDivider ? Colors.transparent : null),
              TodoKeyValueTags(
                  items: state.todo.formattedKeyValues, readOnly: true),
            ],
          ),
        ),
      ],
    );
  }
}

class TodoViewNarrowView extends TodoViewView {
  const TodoViewNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "View",
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
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            action: () => _editAction(context, state),
          ),
        );
      },
    );
  }
}

class TodoViewWideView extends TodoViewView {
  const TodoViewWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: MainAppBar(
            title: "View",
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
          tooltip: 'Edit',
          icon: const Icon(Icons.edit),
          onPressed: () => _editAction(context, state),
        ),
      ],
    );
  }
}
