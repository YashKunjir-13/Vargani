import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, mr, hi }

class LocaleNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => AppLanguage.en;

  void setLanguage(AppLanguage language) {
    state = language;
    // TODO: wire into real localization later.
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLanguage>(
  LocaleNotifier.new,
);
