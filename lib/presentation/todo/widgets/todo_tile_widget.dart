import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_event.dart';

class TodoListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  TodoListSection({
    required this.title,
    required this.children,
    Key? key,
  }) : super(key: PageStorageKey<String>(title));

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: key,
      initiallyExpanded: true,
      shape: const Border(),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: children,
    );
  }
}

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final bool isAnySelected;

  TodoListTile({
    required this.todo,
    this.isAnySelected = false,
    Key? key,
  }) : super(key: PageStorageKey<String>(todo.id));

  @override
  Widget build(BuildContext context) {
    // Allow swiping if no todo is selected only.
    if (isAnySelected) {
      return _buildTile(context);
    } else {
      return Dismissible(
        key: ValueKey<String>(todo.id),
        background: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.done),
              ),
              Text(todo.completion == true ? 'Undone' : 'Done'),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              Text(todo.completion == true ? 'Undone' : 'Done'),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.done),
              ),
            ],
          ),
        ),
        onDismissed: (DismissDirection direction) => context
            .read<TodoListBloc>()
            .add(TodoListTodoCompletionToggled(
                todo: todo, completion: !todo.completion)),
        child: _buildTile(context),
      );
    }
  }

  Widget _buildTile(BuildContext context) {
    return ListTile(
      key: key,
      selected: todo.selected,
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.completion ? TextDecoration.lineThrough : null,
          decorationThickness: 2.0,
        ),
      ),
      subtitle: _buildSubtitle(),
      onTap: () {
        if (isAnySelected) {
          context.read<TodoListBloc>().add(TodoListTodoSelectedToggled(
              todo: todo, selected: !todo.selected));
        } else {
          context.pushNamed('todo-edit', extra: todo);
        }
      },
      onLongPress: () => context.read<TodoListBloc>().add(
          TodoListTodoSelectedToggled(todo: todo, selected: !todo.selected)),
    );
  }

  Widget? _buildSubtitle() {
    if (todo.creationDate == null &&
        todo.priority == Priority.none &&
        todo.projects.isEmpty &&
        todo.contexts.isEmpty &&
        todo.keyValues.isEmpty) {
      return null;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: <Widget>[
        if (todo.priority != Priority.none)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtPriority),
          ),
        if (todo.creationDate != null && todo.completion == false)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(Todo.differenceToToday(todo.creationDate!)),
          ),
        if (todo.completionDate != null && todo.completion == true)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(Todo.differenceToToday(todo.completionDate!)),
          ),
        if (todo.projects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtProjects.join(' ')),
          ),
        if (todo.contexts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.fmtContexts.join(' ')),
          ),
        if (todo.keyValues.isNotEmpty) Text(todo.fmtKeyValues.join(' ')),
      ],
    );
  }
}
