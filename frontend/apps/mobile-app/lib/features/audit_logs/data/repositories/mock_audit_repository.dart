import '../../../../shared/ui_kit/chips/severity_badge.dart';
import '../../models/audit_models.dart';
import 'audit_repository.dart';

class MockAuditRepository implements AuditRepository {
  static final List<MockAuditEvent> _logs = [
    MockAuditEvent(
      id: 'evt-1001',
      mandalId: 'mandal-001',
      moduleLabel: 'Budgeting',
      action: 'Budget Revision Approved',
      actorUserId: 'usr-admin-01',
      actorUserName: 'Rahul Sharma',
      actorRole: 'Trust President',
      resourceType: 'BudgetRevision',
      resourceId: 'rev-05',
      amountPaise: 5000000,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      severity: Severity.medium,
      ipAddress: '192.168.1.45',
      device: 'Android',
      browser: 'Chrome 126',
      sessionId: 'sess-9812',
      requestId: 'req-0041',
      reason: 'Additional lighting requirements for Ganeshotsav festival stage.',
      approvalStatus: 'APPROVED',
    ),
    MockAuditEvent(
      id: 'evt-1002',
      mandalId: 'mandal-001',
      moduleLabel: 'Security',
      action: 'Failed Logins Detected',
      actorUserId: 'usr-anonymous',
      actorUserName: 'Unknown User',
      actorRole: 'Guest',
      resourceType: 'UserSession',
      resourceId: 'sess-0000',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      severity: Severity.critical,
      ipAddress: '103.22.18.4',
      device: 'Linux',
      browser: 'Unrecognized Bot',
      sessionId: 'sess-0000',
      requestId: 'req-0012',
      reason: 'Multiple invalid password attempts.',
      approvalStatus: 'FLAGGED',
    ),
    MockAuditEvent(
      id: 'evt-1003',
      mandalId: 'mandal-001',
      moduleLabel: 'RBAC',
      action: 'Role Permissions Modified',
      actorUserId: 'usr-admin-01',
      actorUserName: 'Rahul Sharma',
      actorRole: 'Trust President',
      resourceType: 'OrganizationRole',
      resourceId: 'role-treasurer',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      severity: Severity.high,
      ipAddress: '192.168.1.45',
      device: 'Android',
      browser: 'Chrome 126',
      sessionId: 'sess-9812',
      requestId: 'req-0089',
      reason: 'Updated expense approval thresholds.',
      approvalStatus: 'COMPLETED',
    ),
  ];

  @override
  Future<List<MockAuditEvent>> getAuditLogs({AuditFilterParameters? filters}) async {
    if (filters == null) return _logs;

    return _logs.where((event) {
      if (filters.module != null && filters.module!.isNotEmpty && !event.moduleLabel.contains(filters.module!)) {
        return false;
      }
      if (filters.severity != null && event.severity != filters.severity) {
        return false;
      }
      if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
        final q = filters.searchQuery!.toLowerCase();
        final match = event.action.toLowerCase().contains(q) ||
            event.actorUserName.toLowerCase().contains(q) ||
            event.moduleLabel.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<MockAuditEvent> getAuditLogById(String id) async {
    return _logs.firstWhere(
      (e) => e.id == id,
      orElse: () => _logs.first,
    );
  }

  @override
  Future<List<MockAuditEvent>> searchAuditLogs(String query) async {
    return getAuditLogs(filters: AuditFilterParameters(searchQuery: query));
  }
}
