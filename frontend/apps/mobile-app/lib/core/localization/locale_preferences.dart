import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the non-sensitive language preference independently of auth data.
class LocalePreferences {
  LocalePreferences({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _localeKey = 'app.locale';

  final SharedPreferencesAsync _preferences;

  Future<Locale> load() async {
    final languageCode = await _preferences.getString(_localeKey);
    return supportedLocales
            .where((locale) => locale.languageCode == languageCode)
            .firstOrNull ??
        defaultLocale;
  }

  Future<void> save(Locale locale) =>
      _preferences.setString(_localeKey, locale.languageCode);
}

const supportedLocales = [Locale('en'), Locale('hi'), Locale('mr')];
const defaultLocale = Locale('en');
