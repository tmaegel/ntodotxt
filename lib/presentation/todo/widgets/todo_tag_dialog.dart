import 'package:flutter/material.dart';

abstract class TodoTagDialog extends StatelessWidget {
  final Icon leadingIcon;
  final String tagName;
  final Function() onPressed;

  const TodoTagDialog({
    required this.leadingIcon,
    required this.tagName,
    required this.onPressed,
    super.key,
  });

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
            leading: leadingIcon,
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Enter your <$tagName> tag here ...',
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.done),
              tooltip: 'Add new $tagName tag',
              onPressed: () {
                onPressed();
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
    required super.onPressed,
    super.key,
  });
}

class TodoContextTagDialog extends TodoTagDialog {
  const TodoContextTagDialog({
    super.leadingIcon = const Icon(Icons.sell_outlined),
    super.tagName = 'context',
    required super.onPressed,
    super.key,
  });
}

class TodoKeyValueTagDialog extends TodoTagDialog {
  const TodoKeyValueTagDialog({
    super.leadingIcon = const Icon(Icons.join_inner_outlined),
    super.tagName = 'key:value',
    required super.onPressed,
    super.key,
  });
}
