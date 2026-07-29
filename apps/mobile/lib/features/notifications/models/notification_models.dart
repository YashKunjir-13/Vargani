import 'package:flutter/material.dart';

/// Executive summary payload for the Notification Center screen.
class NotificationSummaryData {
  final int unreadCount;
  final int criticalCount;
  final int approvalsCount;
  final int paymentsDueCount;

  const NotificationSummaryData({
    required this.unreadCount,
    required this.criticalCount,
    required this.approvalsCount,
    required this.paymentsDueCount,
  });
}

/// One feed entry. Every notification either earns a call-to-action or it
/// doesn't need one -- [primaryActionLabel] is optional by design.
class NotificationItemData {
  final String id;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String description;
  final bool isUnread;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;

  /// "Today" / "Yesterday" / "Earlier this week" / "Earlier this month" / "Older".
  final String groupLabel;

  const NotificationItemData({
    required this.id,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isUnread,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    required this.groupLabel,
  });
}

/// Full payload for the Notification Detail screen.
class NotificationDetailData {
  final String id;
  final String title;
  final String priorityLabel;
  final String createdLabel;
  final String triggeredBy;
  final String statusLabel;
  final String contextLabel;
  final String contextValue;
  final String contextSubtitle;
  final String? linkedBudgetName;
  final String? linkedBudgetStatus;
  final List<String> activityLog;
  final String? attachmentName;
  final String primaryActionLabel;

  const NotificationDetailData({
    required this.id,
    required this.title,
    required this.priorityLabel,
    required this.createdLabel,
    required this.triggeredBy,
    required this.statusLabel,
    required this.contextLabel,
    required this.contextValue,
    required this.contextSubtitle,
    this.linkedBudgetName,
    this.linkedBudgetStatus,
    required this.activityLog,
    this.attachmentName,
    required this.primaryActionLabel,
  });
}

/// One category row on the Notification Settings screen, with its three
/// per-channel toggles.
@immutable
class NotificationCategorySetting {
  final String name;
  final String description;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool inAppEnabled;

  /// When true, the channel toggles are organization-managed and disabled
  /// -- shown with an explanatory banner rather than silently ignoring taps.
  final bool isLocked;

  const NotificationCategorySetting({
    required this.name,
    required this.description,
    required this.emailEnabled,
    required this.pushEnabled,
    required this.inAppEnabled,
    this.isLocked = false,
  });

  NotificationCategorySetting copyWith({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? inAppEnabled,
  }) {
    return NotificationCategorySetting(
      name: name,
      description: description,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      isLocked: isLocked,
    );
  }
}
