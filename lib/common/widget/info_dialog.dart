import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;

  const InfoDialog({
    required this.title,
    required this.message,
    super.key,
  });

  static Future<void> dialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    return await showDialog<void>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => InfoDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: Text(message),
    );
  }
}
