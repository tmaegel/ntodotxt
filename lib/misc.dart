// coverage:ignore-file

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';

class PlatformInfo {
  static bool get isDesktopOS {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  static bool get isAppOS {
    return Platform.isIOS || Platform.isAndroid;
  }
}

enum MessageType { success, info, error }

class SnackBarHandler {
  static void _call(BuildContext context, MessageType type, String message) {
    Color backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    Color foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
    switch (type) {
      case MessageType.success:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
        break;
      case MessageType.info:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
        break;
      case MessageType.error:
        backgroundColor = Theme.of(context).colorScheme.error;
        foregroundColor = Theme.of(context).colorScheme.onError;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        duration: type == MessageType.error
            ? const Duration(seconds: 10)
            : const Duration(seconds: 4),
        content: Text(
          message,
          style: TextStyle(color: foregroundColor),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      _call(context, MessageType.success, message);

  static void info(BuildContext context, String message) =>
      _call(context, MessageType.info, message);

  static void error(BuildContext context, String message) =>
      _call(context, MessageType.error, message);
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class Debouncer {
  Timer? _timer;
  final int milliseconds;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class PopScopeDrawer extends StatelessWidget {
  final Widget child;

  const PopScopeDrawer({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: <T>(bool didPop, T? result) {
        if (didPop) {
          return;
        }
        context.read<DrawerCubit>().back();
        Navigator.of(context).pop();
      },
      child: child,
    );
  }
}
