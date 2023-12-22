import 'package:flutter/material.dart';

class InputDialog extends StatelessWidget {
  final String title;
  final String label;

  const InputDialog({
    required this.title,
    required this.label,
    super.key,
  });

  static Future<String?> dialog({
    required BuildContext context,
    required String title,
    required String label,
  }) async {
    return await showDialog<String?>(
      context: context,
      barrierDismissible: false, // User must tap button.
      builder: (BuildContext context) =>
          InputDialog(title: title, label: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
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
