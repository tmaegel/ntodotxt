// coverage:ignore-file

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:ntodotxt/misc.dart';

final ThemeData light = CustomTheme.light;
final ThemeData dark = CustomTheme.dark;

/// Customize versions of the theme data.
final ThemeData lightTheme = light.copyWith(
  appBarTheme: light.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
  ),
  snackBarTheme: light.snackBarTheme.copyWith(
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(16),
  ),
  splashColor: PlatformInfo.isAppOS ? Colors.transparent : null,
  chipTheme: light.chipTheme.copyWith(),
  expansionTileTheme: light.expansionTileTheme.copyWith(
    shape: const Border(),
    collapsedBackgroundColor: light.appBarTheme.backgroundColor,
    textColor: dark.colorScheme.primary,
  ),
  listTileTheme: light.listTileTheme.copyWith(
    selectedColor: light.textTheme.bodySmall?.color,
    selectedTileColor: light.hoverColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  scrollbarTheme: dark.scrollbarTheme.copyWith(
    thickness: MaterialStateProperty.all(5.0),
  ),
  bottomAppBarTheme: light.bottomAppBarTheme.copyWith(),
  floatingActionButtonTheme: light.floatingActionButtonTheme.copyWith(
    elevation: 0.0,
    focusElevation: 0.0,
    hoverElevation: 0.0,
  ),
  inputDecorationTheme: light.inputDecorationTheme.copyWith(
    filled: false,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: light.primaryColor),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: light.dividerColor),
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: light.dividerColor),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: light.disabledColor),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.colorScheme.error),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.colorScheme.error),
    ),
  ),
);
final ThemeData darkTheme = dark.copyWith(
  appBarTheme: dark.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
  ),
  snackBarTheme: light.snackBarTheme.copyWith(
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(16),
  ),
  splashColor: PlatformInfo.isAppOS ? Colors.transparent : null,
  chipTheme: dark.chipTheme.copyWith(),
  expansionTileTheme: dark.expansionTileTheme.copyWith(
    shape: const Border(),
    collapsedBackgroundColor: dark.appBarTheme.backgroundColor,
    textColor: dark.colorScheme.primary,
  ),
  listTileTheme: dark.listTileTheme.copyWith(
    selectedColor: dark.textTheme.bodySmall?.color,
    selectedTileColor: dark.hoverColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  scrollbarTheme: dark.scrollbarTheme.copyWith(
    thickness: MaterialStateProperty.all(5.0),
  ),
  bottomAppBarTheme: dark.bottomAppBarTheme.copyWith(),
  floatingActionButtonTheme: dark.floatingActionButtonTheme.copyWith(
    elevation: 0.0,
    focusElevation: 0.0,
    hoverElevation: 0.0,
  ),
  inputDecorationTheme: dark.inputDecorationTheme.copyWith(
    filled: false,
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.primaryColor),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.dividerColor),
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.dividerColor),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.disabledColor),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.colorScheme.error),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: dark.colorScheme.error),
    ),
  ),
);

// Theme config for FlexColorScheme version 7.3.x. Make sure you use
// same or higher package version, but still same major version. If you
// use a lower package version, some properties may not be supported.
// In that case remove them after copying this theme to your app.
class CustomTheme {
  static ThemeData get light {
    return FlexThemeData.light(
      scheme: FlexScheme.bahamaBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: 'OpenSans',
    );
  }

  static ThemeData get dark {
    return FlexThemeData.dark(
      scheme: FlexScheme.bahamaBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: 'OpenSans',
    );
  }
}
