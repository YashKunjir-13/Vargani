import 'package:flutter/material.dart';

/// Builds the approved compact MD3 type scale on top of Flutter's default
/// [TextTheme], overriding only the roles the design spec defines. Every
/// other role keeps Flutter's Material 3 default rather than being left null.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true).textTheme
        : ThemeData.dark(useMaterial3: true).textTheme;

    return base.copyWith(
      // Display -> page titles
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      // Headline -> section titles
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      // Title -> card titles
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      // Body Large -> primary content
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      // Body Medium -> secondary content
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      // Label Large -> buttons
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      // Label Medium -> metadata / eyebrows
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.66,
      ),
    );
  }

  // Backward compatibility methods for feature screens
  static TextStyle display(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.headlineMedium!;
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle titleLarge(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.titleLarge!;
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle titleMedium(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.titleMedium!;
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle body(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.bodyLarge!;
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle label(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.labelLarge!;
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.labelMedium!;
    return color != null ? style.copyWith(color: color) : style;
  }

  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    final style = Theme.of(context).textTheme.bodySmall!;
    return color != null ? style.copyWith(color: color) : style;
  }
}
