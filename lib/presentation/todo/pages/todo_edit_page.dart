import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/presentation/todo/states/todo.dart';

class TodoEditPage extends StatelessWidget {
  final int index;

  const TodoEditPage({
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TodoListRepository todoListRepository =
        context.read<TodoListRepository>();
    return BlocProvider(
      create: (context) => TodoBloc(
        todoListRepository: todoListRepository,
        index: index,
        todo: todoListRepository.getTodo(index),
      ),
      child: TodoEditView(todoListRepository: todoListRepository),
    );
  }
}

class TodoEditView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoEditView({
    required this.todoListRepository,
    super.key,
  });

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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Subheader(title: "Todo"),
                TextField(
                  minLines: 3,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  controller: TextEditingController()
                    ..text = state.todo.description,
                ),
                const Subheader(title: "Priority"),
                GenericChipGroup(
                  chips: [
                    for (var p in priorities)
                      ChipEntity(label: p, selected: p == state.todo.priority),
                  ],
                ),
                const Subheader(title: "Projects"),
                GenericChipGroup(
                  chips: [
                    for (var p in todoListRepository.getAllProjects())
                      ChipEntity(
                          label: p, selected: state.todo.projects.contains(p)),
                  ],
                ),
                const Subheader(title: "Contexts"),
                GenericChipGroup(
                  chips: [
                    for (var c in todoListRepository.getAllContexts())
                      ChipEntity(
                          label: c, selected: state.todo.contexts.contains(c)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, TodoState state) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.save),
      tooltip: 'Save',
      action: () => _saveAction(context, state),
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

  /// Save current todo
  void _saveAction(BuildContext context, TodoState state) {
    context.pop();
  }

  /// Delete current todo
  void _deleteAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoDeleted(state.index));
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current edit process
  void _cancelAction(BuildContext context, TodoState state) {
    context.pop();
  }
}
