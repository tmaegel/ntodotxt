import 'package:flutter/material.dart';
import 'package:ntodotxt/domain/todo/todo_model.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final Function onTap;
  final Function(bool?) onChange;
  final Function onLongPress;
  final bool selected;

  TodoTile({
    required this.todo,
    required this.onTap,
    required this.onChange,
    required this.onLongPress,
    this.selected = false,
    Key? key,
  }) : super(key: PageStorageKey<String>(todo.id));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      selected: selected,
      leading: Checkbox(
        value: todo.completion,
        onChanged: (bool? completion) => onChange(completion),
      ),
      title: Text(
        todo.description,
        style: TextStyle(
          decoration: todo.completion ? TextDecoration.lineThrough : null,
          decorationThickness: 2.0,
        ),
      ),
      subtitle: _buildSubtitle(),
      onTap: () => onTap(),
      onLongPress: () => onLongPress(),
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
