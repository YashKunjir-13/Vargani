import '../../models/audit_models.dart';

abstract class AuditRepository {
  Future<List<MockAuditEvent>> getAuditLogs({AuditFilterParameters? filters});
  Future<MockAuditEvent> getAuditLogById(String id);
  Future<List<MockAuditEvent>> searchAuditLogs(String query);
}
