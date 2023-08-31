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
      title: Text(todo.description),
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
        for (var p in todo.formattedProjects) Text(p),
        for (var c in todo.formattedContexts) Text(c),
        for (var kv in todo.formattedKeyValues) Text(kv),
      ],
    );
  }
}
