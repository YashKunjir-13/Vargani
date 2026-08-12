import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/chips/status_chip.dart';
import 'models/notification_models.dart';

/// Full-screen notification detail, entered by tapping a notification card
/// -- linked budget context, activity history and the primary action all
/// need room the card itself can't spare.
class NotificationDetailScreen extends StatelessWidget {
  final NotificationDetailData detail;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onOpenLinkedRecord;

  const NotificationDetailScreen({
    super.key,
    required this.detail,
    this.onPrimaryAction,
    this.onOpenLinkedRecord,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(detail.title),
            Text(
              detail.priorityLabel,
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KeyValue(label: 'Notification ID', value: detail.id),
          _KeyValue(label: 'Triggered by', value: detail.triggeredBy),
          _KeyValue(label: 'Created', value: detail.createdLabel),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status',
                  style: textTheme.labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              StatusChip(
                  label: detail.statusLabel, type: StatusChipType.warning),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.contextLabel,
                  style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer
                          .withValues(alpha: 0.85)),
                ),
                Text(
                  detail.contextValue,
                  style: textTheme.headlineMedium
                      ?.copyWith(color: colorScheme.onTertiaryContainer),
                ),
                Text(detail.contextSubtitle,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onTertiaryContainer)),
              ],
            ),
          ),
          if (detail.linkedBudgetName != null) ...[
            const SizedBox(height: 24),
            Text('Linked budget', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(detail.linkedBudgetName!),
                subtitle: const Text('Budget module →'),
                trailing: detail.linkedBudgetStatus == null
                    ? null
                    : StatusChip(
                        label: detail.linkedBudgetStatus!,
                        type: StatusChipType.error),
                onTap: onOpenLinkedRecord,
              ),
            ),
          ],
          if (detail.activityLog.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Activity', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final entry in detail.activityLog)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(entry,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ),
          ],
          if (detail.attachmentName != null) ...[
            const SizedBox(height: 16),
            Chip(
                avatar: const Icon(Icons.attach_file, size: 16),
                label: Text(detail.attachmentName!)),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: SecondaryButton(
                      label: 'Open Vendor Profile',
                      onPressed: onOpenLinkedRecord)),
              const SizedBox(width: 8),
              Expanded(
                  child: PrimaryButton(
                      label: detail.primaryActionLabel,
                      onPressed: onPrimaryAction)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          Text(value,
              style:
                  textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
