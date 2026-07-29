import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/chips/severity_badge.dart';
import '../../shared/ui_kit/rows/diff_row.dart';
import 'models/audit_models.dart';

/// Full-screen audit event detail -- an auditor building a case needs the
/// field comparison, related events, and system metadata all reachable
/// without a shallow drawer cutting anything off.
class AuditDetailScreen extends StatelessWidget {
  final AuditEventDetail detail;
  final VoidCallback? onOpenLinkedRecord;

  const AuditDetailScreen({super.key, required this.detail, this.onOpenLinkedRecord});

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
            Text(detail.id),
            Text(
              '${detail.moduleLabel} · Financial',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: detail.id)),
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KeyValueGrid(entries: {
            'Action': detail.action,
            'Performed by': detail.performedBy,
            'Timestamp': detail.timeLabel,
            'Approval': detail.approvalStatusLabel,
          }),
          const SizedBox(height: 8),
          SeverityBadge(severity: detail.severity),
          if (detail.fieldChange != null) ...[
            const SizedBox(height: 24),
            Text('Field comparison', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              '${detail.fieldChange!.fieldLabel} — allocated amount',
              style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            DiffRow(oldValue: detail.fieldChange!.oldValueLabel, newValue: detail.fieldChange!.newValueLabel),
            if (detail.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reason logged: "${detail.reason}"',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
          if (detail.relatedEvents.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Related events', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'reconstructs the workflow',
              style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            for (final related in detail.relatedEvents)
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(related.icon, color: colorScheme.onSurfaceVariant),
                  title: Text(related.title),
                  trailing: Text(related.timeAgoLabel, style: textTheme.labelSmall),
                ),
              ),
          ],
          const SizedBox(height: 24),
          Text('System metadata', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _KeyValueGrid(
                columns: 2,
                entries: {
                  'IP Address': detail.metadata.ipAddress,
                  'Device': detail.metadata.device,
                  'Browser': detail.metadata.browser,
                  'Session ID': detail.metadata.sessionId,
                  'Request ID': detail.metadata.requestId,
                  'Execution time': detail.metadata.executionTimeLabel,
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Copy Audit ID',
                  onPressed: () => Clipboard.setData(ClipboardData(text: detail.id)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: PrimaryButton(label: 'Open Budget', onPressed: onOpenLinkedRecord)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyValueGrid extends StatelessWidget {
  final Map<String, String> entries;
  final int columns;

  const _KeyValueGrid({required this.entries, this.columns = 1});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: columns == 1 ? 6 : 3.4,
      children: [
        for (final entry in entries.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.key.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(entry.value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }
}
