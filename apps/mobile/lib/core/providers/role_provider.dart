import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user_role.dart';

export '../../shared/models/user_role.dart';

typedef Role = UserRole;

/// Role state for UI-only RBAC previews.
/// Default set to trustPresident (the most privileged role for dev/testing).
class RoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.trustPresident;

  void setRole(UserRole role) {
    state = role;
  }
}

final roleProvider = NotifierProvider<RoleNotifier, UserRole>(
  RoleNotifier.new,
);
