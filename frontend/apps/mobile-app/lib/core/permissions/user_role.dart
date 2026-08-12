import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  volunteer('Volunteer', 'वॉलेंटियर'),
  collector('Collector', 'कलेक्टर'),
  auditor('Auditor', 'ऑडिटर'),
  admin('Admin / Managing Trustee', 'ॲडमिन / ट्रस्टी');

  final String label;
  final String labelMr;
  const UserRole(this.label, this.labelMr);
}

class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.admin;

  void setRole(UserRole role) {
    state = role;
  }
}

final userRoleProvider =
    NotifierProvider<UserRoleNotifier, UserRole>(UserRoleNotifier.new);

class AppPermissions {
  final UserRole role;

  const AppPermissions(this.role);

  bool get canActivateTemplate =>
      role == UserRole.admin || role == UserRole.auditor;
  bool get canConfirmPaymentMatch =>
      role == UserRole.admin ||
      role == UserRole.collector ||
      role == UserRole.auditor;
  bool get canVoidPayment => role == UserRole.admin || role == UserRole.auditor;
  bool get canSubmitBill =>
      role != UserRole.volunteer; // Collector, Auditor, Admin
  bool get canApproveRejectBill =>
      role == UserRole.admin || role == UserRole.auditor;
  bool get canMarkBillPaid => role == UserRole.admin;
  bool get canCreateContribution => true; // All roles
  bool get canIssueContributionReceipt =>
      role == UserRole.admin ||
      role == UserRole.collector ||
      role == UserRole.auditor;
}

final permissionsProvider = Provider<AppPermissions>((ref) {
  final role = ref.watch(userRoleProvider);
  return AppPermissions(role);
});
