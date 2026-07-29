import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
      cardColor: AppColors.lightCard,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        surface: AppColors.lightSurface,
        onSurface: const Color(0xFF1F2937),
        onSurfaceVariant: AppColors.lightMutedText,
        outline: AppColors.lightBorder,
        error: AppColors.lightError,
        tertiary: AppColors.lightInfo,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightScaffoldBackground,
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightCard,
        elevation: AppSpacing.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          side: const BorderSide(color: AppColors.lightBorder),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          borderSide: BorderSide(color: AppColors.lightBorder),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
      cardColor: AppColors.darkCard,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        surface: AppColors.darkSurface,
        onSurface: const Color(0xFFF8FAFC),
        onSurfaceVariant: AppColors.darkMutedText,
        outline: AppColors.darkBorder,
        error: AppColors.darkError,
        tertiary: AppColors.darkInfo,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkScaffoldBackground,
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: AppSpacing.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }
}
