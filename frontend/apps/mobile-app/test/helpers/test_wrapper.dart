import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/session/session_state.dart';
import 'package:pauti_pustak_mobile/core/theme/app_theme.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

/// Wraps a test widget with necessary providers, themes, and localizations.
Widget createTestableWidget({
  required Widget child,
  List<dynamic> overrides = const [],
  SessionState sessionState = SessionState.unauthenticated,
}) {
  return ProviderScope(
    overrides: [
      initialSessionStateProvider.overrideWithValue(sessionState),
      ...overrides,
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
