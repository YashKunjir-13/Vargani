import 'package:flutter/material.dart';

/// Hand-authored [ColorScheme]s pinned to the approved design tokens.
///
/// Deliberately not [ColorScheme.fromSeed]: seed-based generation would only
/// approximate the audited saffron palette, not reproduce it exactly. Using
/// the `.light()`/`.dark()` factories (rather than the raw constructor) still
/// lets Flutter fill in reasonable defaults (shadow, scrim, inverseSurface,
/// surfaceTint, ...) for slots the approved spec never defined.
class AppColorScheme {
  AppColorScheme._();

  static ColorScheme light() {
    return const ColorScheme.light(
      primary: Color(0xFFB5540A),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFE0B8),
      onPrimaryContainer: Color(0xFF472A00),
      secondary: Color(0xFFC2410C),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFEDD9),
      onSecondaryContainer: Color(0xFF4A1D06),
      // The approved palette has no third brand hue; tertiary mirrors
      // secondary so MD3 widgets that read it don't introduce an
      // unapproved color.
      tertiary: Color(0xFFC2410C),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFEDD9),
      onTertiaryContainer: Color(0xFF4A1D06),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFCE4E1),
      onErrorContainer: Color(0xFF410E0B),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF221A12),
      onSurfaceVariant: Color(0xFF6F6555),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFFBF8F4),
      surfaceContainer: Color(0xFFF4EEE6),
      surfaceContainerHigh: Color(0xFFECE3D6),
      surfaceContainerHighest: Color(0xFFE4D9C8),
      outline: Color(0xFFDED2C0),
      outlineVariant: Color(0xFFEDE5D8),
    );
  }

  static ColorScheme dark() {
    return const ColorScheme.dark(
      primary: Color(0xFFFFB870),
      onPrimary: Color(0xFF4A2800),
      primaryContainer: Color(0xFF6B3D00),
      onPrimaryContainer: Color(0xFFFFDCB2),
      secondary: Color(0xFFFFB185),
      onSecondary: Color(0xFF4A1D06),
      secondaryContainer: Color(0xFF7A3413),
      onSecondaryContainer: Color(0xFFFFE0CC),
      tertiary: Color(0xFFFFB185),
      onTertiary: Color(0xFF4A1D06),
      tertiaryContainer: Color(0xFF7A3413),
      onTertiaryContainer: Color(0xFFFFE0CC),
      error: Color(0xFFF2B4AE),
      onError: Color(0xFF410E0B),
      errorContainer: Color(0xFF5C1B15),
      onErrorContainer: Color(0xFFFBDAD6),
      surface: Color(0xFF1E1911),
      onSurface: Color(0xFFF1E9DC),
      onSurfaceVariant: Color(0xFFC9BEAC),
      surfaceContainerLowest: Color(0xFF110D07),
      surfaceContainerLow: Color(0xFF161209),
      surfaceContainer: Color(0xFF251F16),
      surfaceContainerHigh: Color(0xFF2E271B),
      surfaceContainerHighest: Color(0xFF383024),
      outline: Color(0xFF4A4030),
      outlineVariant: Color(0xFF332C20),
    );
  }
}
