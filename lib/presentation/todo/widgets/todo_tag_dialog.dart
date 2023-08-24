import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/constants/todo.dart';
import 'package:ntodotxt/presentation/todo/states/todo_bloc.dart';
import 'package:ntodotxt/presentation/todo/states/todo_event.dart';

class TodoTagDialog extends StatefulWidget {
  final Icon leadingIcon;
  final String tagName;

  const TodoTagDialog({
    required this.leadingIcon,
    required this.tagName,
    super.key,
  });

  void onSubmit(BuildContext context, String value) {}

  @override
  State<TodoTagDialog> createState() => _TodoTagDialogState();
}

class _TodoTagDialogState<T extends TodoTagDialog> extends State<T> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            minLeadingWidth: 40.0,
            leading: widget.leadingIcon,
            title: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your <${widget.tagName}> tag here ...',
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            trailing: IconButton.filledTonal(
              icon: const Icon(Icons.done),
              tooltip: 'Add new ${widget.tagName} tag',
              onPressed: () {
                widget.onSubmit(context, _controller.text);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}

class TodoProjectTagDialog extends TodoTagDialog {
  const TodoProjectTagDialog({
    super.leadingIcon = const Icon(Icons.rocket_launch_outlined),
    super.tagName = 'project',
    super.key,
  });

  @override
  void onSubmit(BuildContext context, String value) {
    // @todo: Check validity
    context.read<TodoBloc>().add(TodoProjectAdded(value));
  }

  @override
  State<TodoProjectTagDialog> createState() => _TodoProjectTagDialogState();
}

class _TodoProjectTagDialogState
    extends _TodoTagDialogState<TodoProjectTagDialog> {}

class TodoContextTagDialog extends TodoTagDialog {
  const TodoContextTagDialog({
    super.leadingIcon = const Icon(Icons.sell_outlined),
    super.tagName = 'context',
    super.key,
  });

  @override
  void onSubmit(BuildContext context, String value) {
    // @todo: Check validity
    context.read<TodoBloc>().add(TodoContextAdded(value));
  }

  @override
  State<TodoContextTagDialog> createState() => _TodoContextTagDialogState();
}

class _TodoContextTagDialogState
    extends _TodoTagDialogState<TodoContextTagDialog> {}

class TodoKeyValueTagDialog extends TodoTagDialog {
  const TodoKeyValueTagDialog({
    super.leadingIcon = const Icon(Icons.join_inner_outlined),
    super.tagName = 'key:value',
    super.key,
  });

  @override
  void onSubmit(BuildContext context, String value) {
    // @todo: Check validity
    context.read<TodoBloc>().add(TodoKeyValueAdded(value));
  }

  @override
  State<TodoKeyValueTagDialog> createState() => _TodoKeyValueTagDialogState();
}

class _TodoKeyValueTagDialogState
    extends _TodoTagDialogState<TodoKeyValueTagDialog> {}
