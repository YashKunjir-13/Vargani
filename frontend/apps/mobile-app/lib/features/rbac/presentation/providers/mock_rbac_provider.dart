import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';

import '../pages/user_management_screen.dart';

enum MockRole {
  president('Trust President (Adhyaksha)'),
  vicePresident('Vice President (Upadhyaksh)'),
  secretary('Secretary (Sachiv)'),
  treasurer('Treasurer (Khajindar)'),
  volunteer('Volunteer (Karyakarta)'),
  donor('Donor'),
  custom('Custom Role');

  const MockRole(this.displayName);
  final String displayName;
}

class MockRbacState {
  final MockRole activeRole;
  final bool isSuperAdmin;
  final List<String> permissions;
  final String? customRoleName;
  final String? testingUserName;
  final String? testingUserId;

  const MockRbacState({
    required this.activeRole,
    this.isSuperAdmin = false,
    required this.permissions,
    this.customRoleName,
    this.testingUserName,
    this.testingUserId,
  });

  /// Check if current user has permission or is Super Admin
  bool hasPermission(String permission) {
    if (isSuperAdmin) return true;
    if (permissions.contains(permission)) return true;

    // Standardized permission alias mappings for backward compatibility & frontend-backend bridge:
    switch (permission) {
      case 'contribution.view':
        return permissions.contains('collections.create') ||
            permissions.contains('contribution.view');
      case 'donation_collection.view':
        return permissions.contains('collections.create') ||
            permissions.contains('donation_collection.view');
      case 'receipt.view':
        return permissions.contains('receipts.create') ||
            permissions.contains('receipt.view');
      case 'bill.view':
        return permissions.contains('bills.create') ||
            permissions.contains('bills.approve') ||
            permissions.contains('bill.view');
      case 'vendor_payment.view':
        return permissions.contains('bills.approve') ||
            permissions.contains('expenses.create') ||
            permissions.contains('vendor_payment.view');
      case 'donation_box.view':
        return permissions.contains('kunda.manage') ||
            permissions.contains('donation_box.view');
      case 'sponsor.view':
        return permissions.contains('sponsors.manage') ||
            permissions.contains('sponsor.view');
      case 'advertisement.view':
        return permissions.contains('sponsors.manage') ||
            permissions.contains('advertisement.view');
      case 'volunteer.view':
        return permissions.contains('volunteers.manage') ||
            permissions.contains('volunteer.view');
      case 'member.view':
        return permissions.contains('members.view') ||
            permissions.contains('member.view');
      case 'reports.view':
        return permissions.contains('reports.view') ||
            permissions.contains('analytics.view');
      case 'audit_logs.view':
        return permissions.contains('audit.view') ||
            permissions.contains('audit_logs.view');
      case 'budget.view':
        return permissions.contains('budget.view') ||
            permissions.contains('budget.manage');
      case 'milestones.view':
        return permissions.contains('milestones.view') ||
            permissions.contains('milestones.view_assigned');
      case 'user.manage':
        return permissions.contains('users.manage') ||
            permissions.contains('user.manage');
      case 'records.view':
        return permissions.contains('records.view');
      default:
        return false;
    }
  }
}

class MockRbacNotifier extends Notifier<MockRbacState> {
  // Official Pauti Pustak Role Permissions Matrix
  static const Map<MockRole, List<String>> _rolePermissions = {
    MockRole.president: [
      'user.manage',
      'users.manage',
      'contribution.view',
      'collections.create',
      'donation_collection.view',
      'receipt.view',
      'receipts.create',
      'expenses.create',
      'bill.view',
      'bills.create',
      'bills.approve',
      'vendor_payment.view',
      'budget.view',
      'budget.manage',
      'donation_box.view',
      'kunda.manage',
      'sponsor.view',
      'sponsors.manage',
      'advertisement.view',
      'volunteer.view',
      'volunteers.manage',
      'member.view',
      'members.view',
      'reports.view',
      'audit_logs.view',
      'audit.view',
      'analytics.view',
      'records.view',
      'milestones.view',
      'milestones.view_assigned',
      'milestones.create',
      'milestones.assign',
      'milestones.update',
      'milestones.update_assigned',
      'milestones.manage_financials',
      'milestones.delete',
    ],
    MockRole.vicePresident: [
      'volunteer.view',
      'volunteers.manage',
      'member.view',
      'members.view',
      'sponsor.view',
      'sponsors.manage',
      'reports.view',
      'analytics.view',
      'records.view',
      'milestones.view',
      'milestones.view_assigned',
      'milestones.assign',
      'milestones.update',
      'milestones.update_assigned',
    ],
    MockRole.secretary: [
      'volunteer.view',
      'volunteers.manage',
      'member.view',
      'members.view',
      'sponsor.view',
      'sponsors.manage',
      'reports.view',
      'records.view',
      'milestones.view',
      'milestones.view_assigned',
      'milestones.update_assigned',
    ],
    MockRole.treasurer: [
      'contribution.view',
      'collections.create',
      'receipt.view',
      'receipts.create',
      'expenses.create',
      'bill.view',
      'bills.create',
      'bills.approve',
      'vendor_payment.view',
      'budget.view',
      'budget.manage',
      'donation_box.view',
      'kunda.manage',
      'reports.view',
      'analytics.view',
      'records.view',
      'milestones.view',
      'milestones.view_assigned',
      'milestones.update',
      'milestones.manage_financials',
    ],
    MockRole.volunteer: [
      'contribution.view',
      'collections.create',
      'receipt.view',
      'receipts.create',
      'milestones.view_assigned',
      'milestones.update_assigned',
    ],
    MockRole.donor: [
      'reports.view',
    ],
    MockRole.custom: [],
  };

  @override
  MockRbacState build() {
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;

    const defaultRole = MockRole.president;
    return MockRbacState(
      activeRole: defaultRole,
      isSuperAdmin: true,
      permissions: _rolePermissions[defaultRole] ?? [],
      testingUserName: 'Trust President',
      testingUserId: 'USR-PRESIDENT',
    );
  }

  static List<String> getDefaultPermissions(MockRole role) {
    return _rolePermissions[role] ?? [];
  }

  static List<String> getEffectivePermissions(
      MockRole role, List<String>? customPermissions) {
    return customPermissions ?? getDefaultPermissions(role);
  }

  void switchRole(MockRole newRole,
      {List<String>? customPermissions, String? customRoleName}) {
    final isSuper = newRole == MockRole.president;
    state = MockRbacState(
      activeRole: newRole,
      isSuperAdmin: isSuper,
      permissions: newRole == MockRole.custom
          ? (customPermissions ?? [])
          : (customPermissions ?? getDefaultPermissions(newRole)),
      customRoleName: customRoleName,
      testingUserName: newRole.displayName,
      testingUserId: 'USR-${newRole.name}',
    );
  }

  void simulateUserAccess(MockUser user) {
    state = MockRbacState(
      activeRole: user.role,
      isSuperAdmin: user.isSuperAdmin || user.role == MockRole.president,
      permissions: user.effectivePermissions,
      customRoleName: user.customRoleName,
      testingUserName: user.name,
      testingUserId: user.id,
    );
  }
}

final mockRbacProvider = NotifierProvider<MockRbacNotifier, MockRbacState>(
  MockRbacNotifier.new,
);
