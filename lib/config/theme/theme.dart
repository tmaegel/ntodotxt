// coverage:ignore-file

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntodotxt/misc.dart';

final ThemeData light = CustomTheme.light;
final ThemeData dark = CustomTheme.dark;

/// Customize versions of the theme data.
final ThemeData lightTheme = light.copyWith(
  appBarTheme: light.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  ),
  snackBarTheme: light.snackBarTheme.copyWith(
    elevation: 0.0,
  ),
  splashColor: PlatformInfo.isAppOS ? Colors.transparent : null,
  chipTheme: light.chipTheme.copyWith(),
  expansionTileTheme: light.expansionTileTheme.copyWith(
    shape: const Border(),
    collapsedBackgroundColor: light.appBarTheme.backgroundColor,
    textColor: light.colorScheme.primary,
  ),
  listTileTheme: light.listTileTheme.copyWith(
    selectedColor: light.textTheme.bodySmall?.color,
    selectedTileColor: light.hoverColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  scrollbarTheme: light.scrollbarTheme.copyWith(
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
    isDense: true,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
  ),
  progressIndicatorTheme: light.progressIndicatorTheme.copyWith(
    color: light.colorScheme.primary,
    circularTrackColor: light.colorScheme.primaryContainer,
    refreshBackgroundColor: light.colorScheme.primaryContainer,
  ),
);
final ThemeData darkTheme = dark.copyWith(
  appBarTheme: dark.appBarTheme.copyWith(
    backgroundColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  ),
  snackBarTheme: dark.snackBarTheme.copyWith(
    elevation: 0.0,
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
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
    isDense: true,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
  ),
  progressIndicatorTheme: dark.progressIndicatorTheme.copyWith(
    color: dark.colorScheme.primary,
    circularTrackColor: dark.colorScheme.primaryContainer,
    refreshBackgroundColor: dark.colorScheme.primaryContainer,
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
