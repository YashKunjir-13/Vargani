import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized TextTheme configuration matching design scale.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(dynamic isDarkOrBrightness) {
    final bool isDark = isDarkOrBrightness is bool
        ? isDarkOrBrightness
        : isDarkOrBrightness == Brightness.dark;

    final primaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.6,
        height: 1.2,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.4,
        height: 1.25,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: primaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: mutedColor,
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
