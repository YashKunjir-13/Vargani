import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_controller.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_preferences.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class PautiPustakApp extends ConsumerWidget {
  final String environment;

  const PautiPustakApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider(environment));
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Pauti Pustak ($environment)',
      debugShowCheckedModeBanner: environment != 'prod',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      routerConfig: router,
    );
  }
}
