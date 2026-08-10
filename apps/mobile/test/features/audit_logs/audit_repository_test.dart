import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/shared/ui_kit/chips/severity_badge.dart';
import 'package:pauti_pustak_mobile/features/audit_logs/data/repositories/mock_audit_repository.dart';
import 'package:pauti_pustak_mobile/features/audit_logs/models/audit_models.dart';

void main() {
  group('MockAuditRepository Unit Tests', () {
    final repo = MockAuditRepository();

    test('getAuditLogs fetches all seeded audit logs by default', () async {
      final logs = await repo.getAuditLogs();
      expect(logs, isNotEmpty);
      expect(logs.length, greaterThanOrEqualTo(3));
    });

    test('getAuditLogs filters by module correctly', () async {
      final logs = await repo.getAuditLogs(
        filters: const AuditFilterParameters(module: 'Budgeting'),
      );
      expect(logs, isNotEmpty);
      expect(logs.every((l) => l.moduleLabel.contains('Budgeting')), isTrue);
    });

    test('getAuditLogs filters by severity correctly', () async {
      final logs = await repo.getAuditLogs(
        filters: const AuditFilterParameters(severity: Severity.critical),
      );
      expect(logs, isNotEmpty);
      expect(logs.every((l) => l.severity == Severity.critical), isTrue);
    });

    test('getAuditLogById retrieves accurate event details', () async {
      final event = await repo.getAuditLogById('evt-1001');
      expect(event, isNotNull);
      expect(event.id, equals('evt-1001'));
      expect(event.action, equals('Budget Revision Approved'));
    });

    test('searchAuditLogs matches query strings', () async {
      final results = await repo.searchAuditLogs('Failed Logins');
      expect(results, isNotEmpty);
      expect(results.first.id, equals('evt-1002'));
    });
  });
}
