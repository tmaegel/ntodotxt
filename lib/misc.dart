import 'dart:io' show Platform;

class PlatformInfo {
  static bool get isDesktopOS {
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  static bool get isAppOS {
    return Platform.isMacOS || Platform.isAndroid;
  }
}
