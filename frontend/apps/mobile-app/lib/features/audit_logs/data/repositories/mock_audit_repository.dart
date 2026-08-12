
import '../../models/audit_models.dart';
import 'audit_repository.dart';

class MockAuditRepository implements AuditRepository {
  static final List<MockAuditEvent> _logs = [];

  @override
  Future<List<MockAuditEvent>> getAuditLogs(
      {AuditFilterParameters? filters}) async {
    if (filters == null) return _logs;

    return _logs.where((event) {
      if (filters.module != null &&
          filters.module!.isNotEmpty &&
          !event.moduleLabel.contains(filters.module!)) {
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
