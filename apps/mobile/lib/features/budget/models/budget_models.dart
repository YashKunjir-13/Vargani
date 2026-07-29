import 'package:flutter/material.dart';

/// Executive summary payload for the Budget Overview screen.
class BudgetOverviewData {
  final String totalBudgetLabel;
  final String allocatedLabel;
  final String utilizedLabel;
  final String remainingLabel;
  final double utilizationProgress;
  final String healthLabel;
  final bool isHealthWarning;
  final String ownerName;
  final String version;
  final String daysRemainingCaption;

  const BudgetOverviewData({
    required this.totalBudgetLabel,
    required this.allocatedLabel,
    required this.utilizedLabel,
    required this.remainingLabel,
    required this.utilizationProgress,
    required this.healthLabel,
    required this.isHealthWarning,
    required this.ownerName,
    required this.version,
    required this.daysRemainingCaption,
  });
}

/// One category row/card, shared by the Overview list, the Table screen,
/// and the Details screen header.
class BudgetCategoryData {
  final String id;
  final String name;
  final IconData icon;
  final String allocatedLabel;
  final String spentLabel;
  final double progress;
  final String percentLabel;
  final String ownerName;
  final String? footnote;

  const BudgetCategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.allocatedLabel,
    required this.spentLabel,
    required this.progress,
    required this.percentLabel,
    required this.ownerName,
    this.footnote,
  });
}

/// One linked expense row on the Budget Details screen.
class LinkedExpense {
  final String dateLabel;
  final String vendorName;
  final String amountLabel;
  final String statusLabel;
  final bool isPaid;

  const LinkedExpense({
    required this.dateLabel,
    required this.vendorName,
    required this.amountLabel,
    required this.statusLabel,
    required this.isPaid,
  });
}

/// One entry in the Revision Timeline.
class RevisionEntry {
  final String version;
  final String dateLabel;
  final String title;
  final String? subtitle;
  final bool isPending;
  final bool isApproved;

  const RevisionEntry({
    required this.version,
    required this.dateLabel,
    required this.title,
    this.subtitle,
    required this.isPending,
    required this.isApproved,
  });
}

/// One changed field within a revision -- rendered with the shared `DiffRow`.
class BudgetFieldChange {
  final String fieldLabel;
  final String oldValueLabel;
  final String newValueLabel;

  const BudgetFieldChange({
    required this.fieldLabel,
    required this.oldValueLabel,
    required this.newValueLabel,
  });
}

/// One comment in a revision's approval thread.
class CommentEntry {
  final String authorName;
  final String authorRole;
  final String body;

  const CommentEntry({required this.authorName, required this.authorRole, required this.body});
}

/// Full payload for the Budget Approval screen.
class BudgetApprovalRequest {
  final String revisionVersion;
  final String submittedBy;
  final List<BudgetFieldChange> changes;
  final String reason;
  final List<CommentEntry> comments;

  const BudgetApprovalRequest({
    required this.revisionVersion,
    required this.submittedBy,
    required this.changes,
    required this.reason,
    required this.comments,
  });
}

/// One adjustable allocation row on the Budget Revision (create) screen.
class RevisionAdjustment {
  final String categoryName;
  final String currentAllocationLabel;
  final String proposedAllocationLabel;

  const RevisionAdjustment({
    required this.categoryName,
    required this.currentAllocationLabel,
    required this.proposedAllocationLabel,
  });
}
