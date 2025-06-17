import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final String cancelLabel;

  const ConfirmationDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.cancelLabel,
    super.key,
  });

  static Future<bool> dialog({
    required BuildContext context,
    required String title,
    required String message,
    required String actionLabel,
    required String cancelLabel,
  }) async {
    bool? result = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false, // User must tap button.
      builder: (BuildContext context) => ConfirmationDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        cancelLabel: cancelLabel,
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
          child: Text(cancelLabel),
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
