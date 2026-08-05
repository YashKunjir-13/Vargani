import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_preferences.dart';

final localePreferencesProvider = Provider<LocalePreferences>(
  (ref) => LocalePreferences(),
);

/// Overridden at bootstrap so the first rendered frame already has the saved
/// language instead of briefly falling back to English.
final initialLocaleProvider = Provider<Locale>((ref) => defaultLocale);

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => ref.watch(initialLocaleProvider);

  Future<void> selectLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }

    state = locale;
    await ref.read(localePreferencesProvider).save(locale);
  }
}
