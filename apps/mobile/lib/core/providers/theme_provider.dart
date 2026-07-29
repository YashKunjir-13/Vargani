import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemePreference { system, light, dark }

class ThemeNotifier extends StateNotifier<AppThemePreference> {
  ThemeNotifier() : super(AppThemePreference.system);

  void setTheme(AppThemePreference preference) {
    state = preference;
    // TODO: persist selection via shared_preferences later.
  }

  void toggleTheme() {
    if (state == AppThemePreference.light) {
      state = AppThemePreference.dark;
    } else if (state == AppThemePreference.dark) {
      state = AppThemePreference.light;
    } else {
      state = AppThemePreference.light;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemePreference>(
  (ref) => ThemeNotifier(),
);

ThemeMode themeModeFromPreference(AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.light:
      return ThemeMode.light;
    case AppThemePreference.dark:
      return ThemeMode.dark;
    case AppThemePreference.system:
      return ThemeMode.system;
  }
}
