import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/header.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class TodoCreatePage extends StatelessWidget {
  const TodoCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < maxScreenWidthCompact) {
      return const TodoCreateNarrowView();
    } else {
      return const TodoCreateWideView();
    }
  }
}

abstract class TodoCreateView extends StatelessWidget {
  const TodoCreateView({super.key});

  List<Widget> priorityChips() {
    return [
      for (var p in priorities)
        GenericChoiceChip(
          label: p,
          color: priorityChipColor,
        ),
    ];
  }

  List<Widget> projectChips(TodoListState state) {
    return [
      for (var p in state.projects)
        GenericChoiceChip(
          label: p,
          color: projectChipColor,
        ),
    ];
  }

  List<Widget> contextChips(TodoListState state) {
    return [
      for (var c in state.contexts)
        GenericChoiceChip(
          label: c,
          color: contextChipColor,
        ),
    ];
  }

  /// Save new todo
  void _saveAction(BuildContext context) {
    context.go(context.namedLocation('todo-list'));
  }

  /// Cancel current create process
  void _cancelAction(BuildContext context) {
    context.go(context.namedLocation('todo-list'));
  }
}

class TodoCreateNarrowView extends TodoCreateView {
  const TodoCreateNarrowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MainAppBar(
        title: "Create",
        leadingAction: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _cancelAction(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<TodoListBloc, TodoListState>(
          builder: (BuildContext context, TodoListState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Subheader(title: "Todo"),
                TextField(
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
                ),
                const Subheader(title: "Priority"),
                GenericChipGroup(children: priorityChips()),
                const Subheader(title: "Projects"),
                GenericChipGroup(children: projectChips(state)),
                const Subheader(title: "Contexts"),
                GenericChipGroup(children: contextChips(state)),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: PrimaryFloatingActionButton(
        icon: const Icon(Icons.save),
        tooltip: 'Save',
        action: () => _saveAction(context),
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
  }
}

class TodoCreateWideView extends TodoCreateView {
  const TodoCreateWideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: MainAppBar(
        title: "Create",
        leadingAction: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _cancelAction(context),
        ),
        toolbar: _buildToolBar(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<TodoListBloc, TodoListState>(
          builder: (BuildContext context, TodoListState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Subheader(title: "Todo"),
                TextField(
                  minLines: 3,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const Subheader(title: "Priority"),
                GenericChipGroup(
                  children: [
                    ...priorityChips(),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
                const Subheader(title: "Projects"),
                GenericChipGroup(
                  children: [
                    ...projectChips(state),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
                const Subheader(title: "Contexts"),
                GenericChipGroup(
                  children: [
                    ...contextChips(state),
                    GenericActionChip(
                      label: "+",
                      onPressed: () {},
                    )
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Save',
          icon: const Icon(Icons.save),
          onPressed: () => _saveAction(context),
        ),
      ],
    );
  }
}
