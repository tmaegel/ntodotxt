import 'package:flutter/material.dart';

class InputDialog extends StatelessWidget {
  final String title;
  final String label;
  final String? value;

  const InputDialog({
    required this.title,
    required this.label,
    this.value,
    super.key,
  });

  static Future<String?> dialog({
    required BuildContext context,
    required String title,
    required String label,
    String? value,
  }) async {
    return await showDialog<String?>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false, // User must tap button.
      builder: (BuildContext context) =>
          InputDialog(title: title, label: label, value: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    controller.text = value ?? '';
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: label),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context, controller.text),
        ),
      ],
    );
  }
}
