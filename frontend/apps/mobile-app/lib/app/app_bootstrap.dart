import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/locale_controller.dart';
import '../core/localization/locale_preferences.dart';
import '../core/network/api_client.dart';
import '../core/session/session_controller.dart';
import '../core/session/session_state.dart';
import '../core/storage/token_storage.dart';
import '../features/authentication/data/auth_remote_datasource.dart';
import '../features/authentication/data/auth_repository.dart';
import 'app.dart';

/// Starts the app only after its persisted, non-sensitive UI preferences are
/// available, preventing a visible locale change after launch. Also attempts
/// to restore a previously-authenticated session so the router can decide
/// the correct first screen without a flash of the wrong one.
Future<void> runPautiPustakApp({required String environment}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final localePreferences = LocalePreferences();
  final initialLocale = await localePreferences.load();

  final tokenStorage = TokenStorage();
  final authRepository = AuthRepository(
    remoteDataSource: AuthRemoteDataSource(
      buildApiClient(environment: environment, tokenStorage: tokenStorage),
    ),
    tokenStorage: tokenStorage,
  );

  SessionState initialSessionState;
  try {
    final result = await authRepository.restoreSession();
    initialSessionState = result == null
        ? SessionState.unauthenticated
        : SessionState(
            status: SessionStatus.authenticated,
            user: result.user,
            activeRole: result.role);
  } catch (_) {
    await tokenStorage.clear();
    initialSessionState = SessionState.unauthenticated;
  }

  runApp(
    ProviderScope(
      overrides: [
        localePreferencesProvider.overrideWithValue(localePreferences),
        initialLocaleProvider.overrideWithValue(initialLocale),
        environmentProvider.overrideWithValue(environment),
        tokenStorageProvider.overrideWithValue(tokenStorage),
        initialSessionStateProvider.overrideWithValue(initialSessionState),
      ],
      child: PautiPustakApp(environment: environment),
    ),
  );
}
