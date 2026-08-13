import 'package:flutter/material.dart';
import '../../../shared/ui_kit/chips/severity_badge.dart';

// --- Domain Models ---

class AuditFilterParameters {
  final String? mandalId;
  final String? module;
  final Severity? severity;
  final String? actorId;
  final String? resourceType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int pageSize;

  const AuditFilterParameters({
    this.mandalId,
    this.module,
    this.severity,
    this.actorId,
    this.resourceType,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.pageSize = 50,
  });

  AuditFilterParameters copyWith({
    String? mandalId,
    String? module,
    Severity? severity,
    String? actorId,
    String? resourceType,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int? page,
    int? pageSize,
  }) {
    return AuditFilterParameters(
      mandalId: mandalId ?? this.mandalId,
      module: module ?? this.module,
      severity: severity ?? this.severity,
      actorId: actorId ?? this.actorId,
      resourceType: resourceType ?? this.resourceType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class MockAuditEvent {
  final String id;
  final String? mandalId;
  final String moduleLabel;
  final String action;
  final String actorUserId;
  final String actorUserName;
  final String? actorRole;
  final String? resourceType;
  final String? resourceId;
  final int? amountPaise;
  final DateTime timestamp;
  final Severity severity;
  final String? ipAddress;
  final String? device;
  final String? browser;
  final String? sessionId;
  final String? requestId;
  final String? reason;
  final String? approvalStatus;

  final List<AuditFieldChange> changes;
  final List<RelatedEvent> relatedEvents;

  const MockAuditEvent({
    required this.id,
    this.mandalId,
    required this.moduleLabel,
    required this.action,
    required this.actorUserId,
    required this.actorUserName,
    this.actorRole,
    this.resourceType,
    this.resourceId,
    this.amountPaise,
    required this.timestamp,
    required this.severity,
    this.ipAddress,
    this.device,
    this.browser,
    this.sessionId,
    this.requestId,
    this.reason,
    this.approvalStatus,
    this.changes = const [],
    this.relatedEvents = const [],
  });
}

// --- UI Models (Kept for compatibility with existing views) ---

class AuditSummaryData {
  final int todayEventsCount;
  final int criticalCount;
  final int financialCount;
  final int securityCount;

  const AuditSummaryData({
    required this.todayEventsCount,
    required this.criticalCount,
    required this.financialCount,
    required this.securityCount,
  });
}

class AuditEventData {
  final String id;
  final String timeLabel;
  final String title;
  final String actorName;
  final String moduleLabel;
  final Severity severity;
  final String groupLabel;

  const AuditEventData({
    required this.id,
    required this.timeLabel,
    required this.title,
    required this.actorName,
    required this.moduleLabel,
    required this.severity,
    required this.groupLabel,
  });
}

class AuditFieldChange {
  final String fieldLabel;
  final String oldValueLabel;
  final String newValueLabel;

  const AuditFieldChange({
    required this.fieldLabel,
    required this.oldValueLabel,
    required this.newValueLabel,
  });
}

class RelatedEvent {
  final String title;
  final String timeAgoLabel;
  final IconData icon;

  const RelatedEvent(
      {required this.title, required this.timeAgoLabel, required this.icon});
}

class AuditMetadata {
  final String ipAddress;
  final String device;
  final String browser;
  final String sessionId;
  final String requestId;
  final String executionTimeLabel;

  const AuditMetadata({
    required this.ipAddress,
    required this.device,
    required this.browser,
    required this.sessionId,
    required this.requestId,
    required this.executionTimeLabel,
  });
}

class AuditEventDetail {
  final String id;
  final String moduleLabel;
  final String action;
  final String performedBy;
  final String timeLabel;
  final Severity severity;
  final String approvalStatusLabel;
  final AuditFieldChange? fieldChange;
  final String? reason;
  final List<RelatedEvent> relatedEvents;
  final AuditMetadata metadata;

  const AuditEventDetail({
    required this.id,
    required this.moduleLabel,
    required this.action,
    required this.performedBy,
    required this.timeLabel,
    required this.severity,
    required this.approvalStatusLabel,
    this.fieldChange,
    this.reason,
    required this.relatedEvents,
    required this.metadata,
  });
}

class AuditSearchResult {
  final IconData icon;
  final String beforeMatch;
  final String matchText;
  final String afterMatch;
  final String moduleLabel;
  final String timeLabel;

  const AuditSearchResult({
    required this.icon,
    required this.beforeMatch,
    required this.matchText,
    required this.afterMatch,
    required this.moduleLabel,
    required this.timeLabel,
  });
}
