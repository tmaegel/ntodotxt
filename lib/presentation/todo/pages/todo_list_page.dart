import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/search_bar.dart';
import 'package:ntodotxt/constants/screen.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/domain/todo/todo_list_repository.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TodoListRepository todoListRepository =
        context.read<TodoListRepository>();
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < maxScreenWidthCompact) {
      return TodoListNarrowView(todoListRepository: todoListRepository);
    } else {
      return TodoListWideView(todoListRepository: todoListRepository);
    }
  }
}

abstract class TodoListView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoListView({
    required this.todoListRepository,
    super.key,
  });

  /// Add new todo
  void _createAction(BuildContext context) {
    context.push(context.namedLocation('todo-create'));
  }
}

class TodoListNarrowView extends TodoListView {
  const TodoListNarrowView({
    required super.todoListRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TodoList(todoListRepository: todoListRepository),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: PrimaryBottomAppBar(
        children: [
          IconButton(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Filter',
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () => _createAction(context),
    );
  }
}

class TodoListWideView extends TodoListView {
  const TodoListWideView({
    required super.todoListRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TodoList(todoListRepository: todoListRepository),
    );
  }
}

class TodoList extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoList({
    required this.todoListRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (BuildContext context, TodoListState state) {
        return Column(
          children: [
            const GenericSearchBar(),
            _buildExpandedListView(state),
          ],
        );
      },
    );
  }

  Widget _buildExpandedListView(TodoListState state) {
    List<TodoListSection> items = [];
    for (var p in todoListRepository.getAllPriorities()) {
      List<Widget> todoItems = [];
      for (var i = 0; i < state.todoList.length; i++) {
        if (state.todoList[i].priority == p) {
          todoItems.add(TodoTile(index: i, todo: state.todoList[i]));
        }
      }
      items.add(
        TodoListSection(
          title: p ?? "",
          children: todoItems,
        ),
      );
    }

    return Expanded(
      child: ListView(
        children: items,
      ),
    );
  }
}

class TodoListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  TodoListSection({
    required String title,
    required this.children,
    super.key,
  }) : title = title.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      shape: const Border.fromBorderSide(BorderSide.none),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: title != "" ? priorityChipColor : noPriorityColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      title: Container(),
      children: children,
    );
  }
}

class TodoTile extends StatelessWidget {
  final int index;
  final Todo todo;

  const TodoTile({
    required this.index,
    required this.todo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.completion,
        onChanged: (bool? completion) {
          context.read<TodoListBloc>().add(
                TodoListTodoCompletionToggled(
                  index: index,
                  completion: completion,
                ),
              );
        },
      ),
      title: _buildDesription(),
      onTap: () => _onTapAction(context),
    );
  }

  Widget _buildDesription() {
    return Wrap(
      spacing: 4.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
          child: Text(todo.description),
        ),
        for (var p in todo.projects)
          InlineChipReadOnly(label: p, color: projectChipColor),
        for (var c in todo.contexts)
          InlineChipReadOnly(label: c, color: contextChipColor),
        for (var kv in todo.formattedKeyValues)
          InlineChipReadOnly(label: kv, color: keyValueChipColor),
      ],
    );
  }

  void _onTapAction(BuildContext context) {
    context.go(
      context.namedLocation(
        'todo-view',
        pathParameters: {
          'index': index.toString(),
        },
      ),
    );
  }
}
