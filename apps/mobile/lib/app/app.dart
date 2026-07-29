import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_controller.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_preferences.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

import 'package:pauti_pustak_mobile/core/theme/theme_controller.dart';

import '../core/core.dart';
import 'home_screen.dart';

class PautiPustakApp extends ConsumerWidget {
  final String environment;

  const PautiPustakApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider(environment));
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Pauti Pustak ($environment)',
      debugShowCheckedModeBanner: environment != 'prod',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57400),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57400),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      routerConfig: router,
    );
  }
}
