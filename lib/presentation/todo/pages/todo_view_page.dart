import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';
import 'package:ntodotxt/presentation/todo/widgets/todo_tag_section.dart';

class TodoViewPage extends StatelessWidget {
  final Todo _todo;

  const TodoViewPage({
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
          ? const TodoViewNarrowView()
          : const TodoViewWideView(),
    );
  }
}

abstract class TodoViewView extends StatelessWidget {
  const TodoViewView({super.key});

  /// Edit current todo
  void _editAction(BuildContext context, TodoState state) {
    context.pushNamed("todo-edit", extra: state.todo);
  }

  /// Cancel current view process
  void _cancelAction(BuildContext context) {
    context.goNamed("todo-list");
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
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  state.todo.description,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoPriorityTags(readOnly: true),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoProjectTags(readOnly: true),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoContextTags(readOnly: true),
              Divider(color: transparentDivider ? Colors.transparent : null),
              const TodoKeyValueTags(readOnly: true),
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
            title: "View ${state.todo.id}",
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
