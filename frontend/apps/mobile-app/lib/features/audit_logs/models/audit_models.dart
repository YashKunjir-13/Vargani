import 'package:flutter/material.dart';

import '../../../shared/ui_kit/chips/severity_badge.dart';

/// Executive summary payload for the Audit Overview screen.
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

/// One row shown in both the Timeline and Table views -- the two are
/// different presentations of the identical filtered result set.
class AuditEventData {
  final String id;
  final String timeLabel;
  final String title;
  final String actorName;
  final String moduleLabel;
  final Severity severity;

  /// "Today" / "Yesterday" / "Earlier this month" -- drives timeline
  /// grouping; ignored by the table view.
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

/// A single changed field, rendered with the shared `DiffRow` -- the exact
/// component Budget's revisions use, since a budget revision is
/// structurally an audited change.
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

/// One entry in an audit event's "Related events" chain (e.g. Budget
/// revision approved -> Vendor quote updated -> Notification sent).
class RelatedEvent {
  final String title;
  final String timeAgoLabel;
  final IconData icon;

  const RelatedEvent({required this.title, required this.timeAgoLabel, required this.icon});
}

/// System metadata grouped for the Audit Detail screen.
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

/// Full payload for the Audit Detail screen.
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

/// One search result row, pre-split around the matched substring so the
/// widget layer never needs its own fuzzy-matching logic -- the match
/// span is expected to come from the server (see the API blueprint).
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
