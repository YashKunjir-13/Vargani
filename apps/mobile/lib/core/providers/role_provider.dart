import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder role state for UI-only RBAC previews.
/// Replace with real auth/RBAC resolution once backend identity is wired.
class RoleNotifier extends StateNotifier<Role> {
  RoleNotifier() : super(Role.owner);

  void setRole(Role role) {
    state = role;
  }
}

enum Role {
  owner,
  president,
  secretary,
  treasurer,
  donationCollector,
  expenseApprover,
  auditor,
  member,
}

extension RoleDisplay on Role {
  String get label {
    return switch (this) {
      Role.owner => 'Owner',
      Role.president => 'President',
      Role.secretary => 'Secretary',
      Role.treasurer => 'Treasurer',
      Role.donationCollector => 'Donation Collector',
      Role.expenseApprover => 'Expense Approver',
      Role.auditor => 'Auditor',
      Role.member => 'Member',
    };
  }
}

final roleProvider = StateNotifierProvider<RoleNotifier, Role>(
  (ref) => RoleNotifier(),
);
