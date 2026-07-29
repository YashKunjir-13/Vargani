import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { en, mr, hi }

class LocaleNotifier extends StateNotifier<AppLanguage> {
  LocaleNotifier() : super(AppLanguage.en);

  void setLanguage(AppLanguage language) {
    state = language;
    // TODO: wire into real localization later.
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLanguage>(
  (ref) => LocaleNotifier(),
);
