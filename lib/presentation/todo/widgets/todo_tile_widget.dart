import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/chip.dart';
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
  }) : super(key: PageStorageKey<int>(todo.id!));

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
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: _buildSubtitle(),
      onTap: () => onTap(),
      onLongPress: () => onLongPress(),
    );
  }

  Widget? _buildSubtitle() {
    if (todo.projects.isEmpty &&
        todo.contexts.isEmpty &&
        todo.keyValues.isEmpty) {
      return null;
    }

    return GenericChipGroup(
      children: <Widget>[
        if (todo.priority != null)
          const Icon(
            Icons.flag,
            size: 15.0,
          ),
        if (todo.priority != null)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.priority!),
          ),
        if (todo.projects.isNotEmpty)
          const Icon(
            Icons.rocket_launch,
            size: 15.0,
          ),
        if (todo.projects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.projects.join(', ')),
          ),
        if (todo.contexts.isNotEmpty)
          const Icon(
            Icons.tag,
            size: 15.0,
          ),
        if (todo.contexts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text(todo.contexts.join(', ')),
          ),
        if (todo.keyValues.isNotEmpty)
          const Icon(
            Icons.join_inner,
            size: 15.0,
          ),
        if (todo.keyValues.isNotEmpty) Text(todo.formattedKeyValues.join(', ')),
      ],
    );
  }
}
