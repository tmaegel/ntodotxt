// coverage:ignore-file

import 'dart:io' show Platform;

import 'package:flutter/material.dart';

class PlatformInfo {
  static bool get isDesktopOS {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  static bool get isAppOS {
    return Platform.isMacOS || Platform.isAndroid;
  }
}

enum MessageType { success, info, error }

class SnackBarHandler {
  static void _call(BuildContext context, MessageType type, String message) {
    Color backgroundColor = Theme.of(context).colorScheme.primary;
    switch (type) {
      case MessageType.success:
        backgroundColor = Colors.green;
        break;
      case MessageType.info:
        backgroundColor = Theme.of(context).colorScheme.primary;
        break;
      case MessageType.error:
        backgroundColor = Theme.of(context).colorScheme.error;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: backgroundColor, content: Text(message)),
    );
  }

  static void success(BuildContext context, String message) =>
      _call(context, MessageType.success, message);

  static void info(BuildContext context, String message) =>
      _call(context, MessageType.info, message);

  static void error(BuildContext context, String message) =>
      _call(context, MessageType.error, message);
}
