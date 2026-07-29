import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_controller.dart';
import 'package:pauti_pustak_mobile/core/theme/theme_controller.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class PautiPustakApp extends ConsumerWidget {
  final String environment;

  const PautiPustakApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'Pauti Pustak ($environment)',
      debugShowCheckedModeBanner: environment != 'prod',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
    );
  }
}
