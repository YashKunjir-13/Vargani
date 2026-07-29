import 'package:flutter/material.dart';

class AppColors {
  static const Color lightScaffoldBackground = Color(0xFFFDF6EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFFE8792D);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFF4A261);
  static const Color lightOnSecondary = Color(0xFF3B2716);
  static const Color lightMutedText = Color(0xFF7A7169);
  static const Color lightBorder = Color(0xFFE8DFD2);
  static const Color lightShadow = Color(0x1F000000);
  static const Color lightSuccess = Color(0xFF2E8B57);
  static const Color lightPending = Color(0xFFDAA520);
  static const Color lightWarning = Color(0xFFD97706);
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightInfo = Color(0xFF2563EB);
  static const Color lightNeutral = Color(0xFF64748B);

  static const Color darkScaffoldBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E2530);
  static const Color darkCard = Color(0xFF232B39);
  static const Color darkPrimary = Color(0xFFE8792D);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkSecondary = Color(0xFFF4A261);
  static const Color darkOnSecondary = Color(0xFF3B2716);
  static const Color darkMutedText = Color(0xFF9AA4B2);
  static const Color darkBorder = Color(0xFF314155);
  static const Color darkShadow = Color(0x33000000);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkPending = Color(0xFFFBBF24);
  static const Color darkWarning = Color(0xFFF59E0B);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkNeutral = Color(0xFF94A3B8);

  static Color surfaceFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : lightSurface;
  static Color cardFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  static Color borderFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : lightBorder;
  static Color mutedTextFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkMutedText
          : lightMutedText;
  static Color shadowFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkShadow
          : lightShadow;

  static Color statusColor(BuildContext context,
      {bool isSurface = false, required Color fallback}) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? fallback.withValues(alpha: 0.2)
        : fallback.withValues(alpha: 0.12);
  }
}
