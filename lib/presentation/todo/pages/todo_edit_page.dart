import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/screen.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => TodoBloc(
        todoListRepository: todoListRepository,
        index: index,
        todo: todoListRepository.getTodo(index),
      ),
      child: screenWidth < maxScreenWidthCompact
          ? TodoEditNarrowView(todoListRepository: todoListRepository)
          : TodoEditWideView(todoListRepository: todoListRepository),
    );
  }
}

abstract class TodoEditView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoEditView({
    required this.todoListRepository,
    super.key,
  });

  List<Widget> priorityChips(BuildContext context, TodoState state) {
    return [
      for (var p in priorities)
        GenericChoiceChip(
          label: p,
          selected: p == state.todo.priority,
          color: priorityChipColor,
          onSelected: (bool selected) =>
              _changePriorityAction(context, p, selected),
        ),
    ];
  }

  List<Widget> projectChips(BuildContext context, TodoState state) {
    return [
      for (var p in state.todo.projects)
        GenericChoiceChip(
          label: p,
          selected: state.todo.projects.contains(p),
          color: projectChipColor,
          onSelected: (bool selected) =>
              _changeProjectsAction(context, p, selected),
        ),
    ];
  }

  List<Widget> contextChips(BuildContext context, TodoState state) {
    return [
      for (var c in state.todo.contexts)
        GenericChoiceChip(
          label: c,
          selected: state.todo.contexts.contains(c),
          color: contextChipColor,
          onSelected: (bool selected) =>
              _changeContextsAction(context, c, selected),
        ),
    ];
  }

  List<Widget> keyValueChips(BuildContext context, TodoState state) {
    return [
      for (var kv in state.todo.formattedKeyValues)
        GenericInputChip(
          label: kv,
          selected: true,
          color: keyValueChipColor,
          onDeleted: () {},
        ),
    ];
  }

  /// Save current todo
  void _saveAction(BuildContext context, TodoState state) {
    context.read<TodoBloc>().add(TodoSubmitted(state.index));
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

  /// Change priority
  void _changePriorityAction(
      BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoPriorityAdded(value));
    } else {
      context.read<TodoBloc>().add(const TodoPriorityRemoved());
    }
  }

  /// Change projects
  void _changeProjectsAction(
      BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoProjectAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoProjectRemoved(value));
    }
  }

  /// Change contexts
  void _changeContextsAction(
      BuildContext context, String value, bool selected) {
    if (selected) {
      context.read<TodoBloc>().add(TodoContextAdded(value));
    } else {
      context.read<TodoBloc>().add(TodoContextRemoved(value));
    }
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
}

class TodoEditNarrowView extends TodoEditView {
  const TodoEditNarrowView({
    required super.todoListRepository,
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
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Subheader(title: "Todo"),
                _buildTodoTextField(context, state),
                const Subheader(title: "Priority"),
                GenericChipGroup(children: priorityChips(context, state)),
                const Subheader(title: "Projects"),
                GenericChipGroup(children: projectChips(context, state)),
                const Subheader(title: "Contexts"),
                GenericChipGroup(children: contextChips(context, state)),
                const Subheader(title: "Key-Values"),
                GenericChipGroup(children: keyValueChips(context, state)),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
          floatingActionButton: PrimaryFloatingActionButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            action: () => _saveAction(context, state),
          ),
          bottomNavigationBar: PrimaryBottomAppBar(
            children: [
              IconButton(
                tooltip: 'Add key value tag',
                icon: const Icon(Icons.join_inner_outlined),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Add context tag',
                icon: const Icon(Icons.sell_outlined),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Add project tag',
                icon: const Icon(Icons.rocket_launch_outlined),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class TodoEditWideView extends TodoEditView {
  const TodoEditWideView({
    required super.todoListRepository,
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
                _buildTodoTextField(context, state),
                const Subheader(title: "Priority"),
                GenericChipGroup(
                  children: [
                    ...priorityChips(context, state),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
                const Subheader(title: "Projects"),
                GenericChipGroup(
                  children: [
                    ...projectChips(context, state),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
                const Subheader(title: "Contexts"),
                GenericChipGroup(
                  children: [
                    ...contextChips(context, state),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
                const Subheader(title: "Key-Values"),
                GenericChipGroup(
                  children: [
                    ...keyValueChips(context, state),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
              ],
            ),
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
