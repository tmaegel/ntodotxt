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
        todoListRepository: context.read<TodoListRepository>(),
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

  Widget _buildFloatingActionButton(BuildContext context, TodoState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Edit',
      action: () => context.pushNamed("todo-edit", extra: state.todo),
    );
  }

  Widget _buildToolBar(BuildContext context, TodoState state) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete),
          onPressed: () => context.read<TodoBloc>().add(const TodoDeleted()),
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
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  state.todo.description,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              const TodoPriorityTags(readOnly: true),
              const Divider(),
              const TodoProjectTags(readOnly: true),
              const Divider(),
              const TodoContextTags(readOnly: true),
              const Divider(),
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
          appBar: MainAppBar(
            title: "View ${state.todo.id}",
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

class TodoViewWideView extends TodoViewView {
  const TodoViewWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (BuildContext context, TodoState state) {
        return Scaffold(
          appBar: MainAppBar(
            title: "View",
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
