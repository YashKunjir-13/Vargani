import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_typography.dart';
import 'semantic_colors.dart';

/// Assembles the approved color scheme, typography and semantic colors into
/// the two [ThemeData] instances the app switches between.
///
/// Component-level overrides (button shapes, chip themes, etc.) are
/// deliberately not set here yet -- MD3 defaults already render correctly
/// once [ColorScheme] is right, so those are added only when a specific
/// shared component needs one.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = AppColorScheme.light();
    final textTheme = AppTypography.textTheme(Brightness.light).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [SemanticColors.light],
    );
  }

  static ThemeData dark() {
    final colorScheme = AppColorScheme.dark();
    final textTheme = AppTypography.textTheme(Brightness.dark).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [SemanticColors.dark],
    );
  }
}
