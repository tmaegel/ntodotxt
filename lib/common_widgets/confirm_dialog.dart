import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;

  const ConfirmationDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    super.key,
  });

  static Future<bool> dialog({
    required BuildContext context,
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button.
      builder: (BuildContext context) => ConfirmationDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text(actionLabel),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
