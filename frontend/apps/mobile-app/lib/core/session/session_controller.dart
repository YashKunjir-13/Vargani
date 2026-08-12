import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/features/authentication/data/auth_remote_datasource.dart';
import 'package:pauti_pustak_mobile/features/authentication/data/auth_repository.dart';
import 'package:pauti_pustak_mobile/features/authentication/data/models/auth_models.dart';

import '../network/api_client.dart';
import '../storage/token_storage.dart';
import 'session_state.dart';

final environmentProvider = Provider<String>((ref) => 'dev');

/// Pre-computed at bootstrap by attempting to restore a persisted session,
/// so the router never has to guess or show a flash of the wrong screen.
final initialSessionStateProvider = Provider<SessionState>((ref) => SessionState.unauthenticated);

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  return buildApiClient(
    environment: ref.watch(environmentProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: AuthRemoteDataSource(ref.watch(dioProvider)),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => ref.watch(initialSessionStateProvider);

  void setAuthenticated(AuthUser user, LoginRole activeRole) {
    state = SessionState(status: SessionStatus.authenticated, user: user, activeRole: activeRole);
  }

  void updateUserProfile({required String displayName, required String primaryMobile, String? primaryEmail}) {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        displayName: displayName,
        primaryMobile: primaryMobile,
        primaryEmail: primaryEmail,
        donorProfile: state.user!.donorProfile?.copyWith(fullName: displayName),
      );
      state = SessionState(
        status: state.status,
        user: updatedUser,
        activeRole: state.activeRole,
      );
    }
  }

  /// Always ends the local session, even if revoking it on the server
  /// fails (e.g. offline) -- the user's intent to sign out of this device
  /// takes priority over that network call succeeding.
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = SessionState.unauthenticated;
    }
  }
}
