import 'package:pauti_pustak_mobile/features/authentication/data/models/auth_models.dart';

enum SessionStatus { authenticated, unauthenticated }

class SessionState {
  const SessionState({required this.status, this.user, this.activeRole});

  static const unauthenticated = SessionState(status: SessionStatus.unauthenticated);

  final SessionStatus status;
  final AuthUser? user;
  final LoginRole? activeRole;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}
