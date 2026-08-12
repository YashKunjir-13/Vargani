import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_controller.dart';

enum AppLanguage { en, mr, hi }

class LocaleNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final locale = ref.watch(localeControllerProvider);
    switch (locale.languageCode) {
      case 'mr':
        return AppLanguage.mr;
      case 'hi':
        return AppLanguage.hi;
      default:
        return AppLanguage.en;
    }
  }

  void setLanguage(AppLanguage language) {
    ref
        .read(localeControllerProvider.notifier)
        .selectLocale(Locale(language.name));
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLanguage>(
  LocaleNotifier.new,
);
