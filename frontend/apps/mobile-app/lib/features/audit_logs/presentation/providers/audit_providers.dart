import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/ui_kit/chips/severity_badge.dart';
import '../../models/audit_models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../data/repositories/mock_audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return MockAuditRepository();
});

/// A state representing the loaded audit logs
class AuditLogsState {
  final bool isLoading;
  final String? error;
  final List<MockAuditEvent> events;
  final String searchQuery;

  AuditLogsState({
    this.isLoading = false,
    this.error,
    this.events = const [],
    this.searchQuery = '',
  });

  AuditLogsState copyWith({
    bool? isLoading,
    String? error,
    List<MockAuditEvent>? events,
    String? searchQuery,
  }) {
    return AuditLogsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      events: events ?? this.events,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AuditLogsNotifier extends Notifier<AuditLogsState> {
  AuditRepository get _repository => ref.read(auditRepositoryProvider);

  @override
  AuditLogsState build() {
    loadAuditLogs();
    return AuditLogsState(isLoading: true);
  }

  Future<void> loadAuditLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _repository.getAuditLogs();
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchLogs(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true, error: null);
    try {
      final events = await _repository.searchAuditLogs(query);
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final auditLogsNotifierProvider =
    NotifierProvider<AuditLogsNotifier, AuditLogsState>(AuditLogsNotifier.new);

/// Provider for a specific event detail.
final auditEventDetailProvider =
    FutureProvider.family<MockAuditEvent, String>((ref, id) async {
  return ref.watch(auditRepositoryProvider).getAuditLogById(id);
});

/// Derived provider for AuditSummaryData mapping MockAuditEvent to the UI format.
final auditSummaryProvider = Provider<AuditSummaryData>((ref) {
  final state = ref.watch(auditLogsNotifierProvider);
  if (state.isLoading || state.events.isEmpty) {
    return const AuditSummaryData(
        todayEventsCount: 0, criticalCount: 0, financialCount: 0, securityCount: 0);
  }

  final now = DateTime.now();
  int today = 0, critical = 0, financial = 0, security = 0;

  for (final evt in state.events) {
    if (evt.timestamp.year == now.year &&
        evt.timestamp.month == now.month &&
        evt.timestamp.day == now.day) {
      today++;
    }
    if (evt.severity == Severity.critical) {
      critical++;
    }
    if (evt.moduleLabel.toLowerCase().contains('budget') ||
        evt.moduleLabel.toLowerCase().contains('finance')) {
      financial++;
    }
    if (evt.moduleLabel.toLowerCase().contains('security') ||
        evt.moduleLabel.toLowerCase().contains('auth')) {
      security++;
    }
  }

  return AuditSummaryData(
    todayEventsCount: today,
    criticalCount: critical,
    financialCount: financial,
    securityCount: security,
  );
});

/// Derived provider mapping MockAuditEvent to AuditEventData (for Table/Timeline).
final auditEventListProvider = Provider<List<AuditEventData>>((ref) {
  final state = ref.watch(auditLogsNotifierProvider);
  final now = DateTime.now();

  return state.events.map((evt) {
    String groupLabel = 'Earlier';
    if (evt.timestamp.year == now.year &&
        evt.timestamp.month == now.month &&
        evt.timestamp.day == now.day) {
      groupLabel = 'Today';
    } else if (evt.timestamp.isAfter(now.subtract(const Duration(days: 1)))) {
      groupLabel = 'Yesterday';
    } else if (evt.timestamp.isAfter(now.subtract(const Duration(days: 30)))) {
      groupLabel = 'Earlier this month';
    }

    String timeLabel = '${evt.timestamp.hour}:${evt.timestamp.minute.toString().padLeft(2, '0')}';

    return AuditEventData(
      id: evt.id,
      timeLabel: timeLabel,
      title: evt.action,
      actorName: evt.actorUserName,
      moduleLabel: evt.moduleLabel,
      severity: evt.severity,
      groupLabel: groupLabel,
    );
  }).toList();
});
