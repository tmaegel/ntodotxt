import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
import 'package:ntodotxt/common_widgets/fab.dart';
import 'package:ntodotxt/common_widgets/header.dart';
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

class TodoListNarrowView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoListNarrowView({
    required this.todoListRepository,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TodoList(todoListRepository: todoListRepository),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return PrimaryFloatingActionButton(
      icon: const Icon(Icons.add),
      tooltip: 'Add',
      action: () => _createAction(context),
    );
  }

  /// Add new todo
  void _createAction(BuildContext context) {
    context.push(context.namedLocation('todo-create'));
  }
}

class TodoListWideView extends StatelessWidget {
  final TodoListRepository todoListRepository;

  const TodoListWideView({
    required this.todoListRepository,
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
            _buildListViewSortedByPriority(state),
          ],
        );
      },
    );
  }

  Widget _buildListViewSortedByPriority(TodoListState state) {
    List<Widget> items = [];
    for (var p in todoListRepository.getAllPriorities()) {
      items.add(ListSection(title: p ?? ""));
      for (var i = 0; i < state.todoList.length; i++) {
        if (state.todoList[i].priority == p) {
          items.add(TodoTile(index: i, todo: state.todoList[i]));
        }
      }
    }

    return Expanded(
      child: ListView(
        children: items,
      ),
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
