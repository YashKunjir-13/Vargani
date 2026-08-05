import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/chips/severity_badge.dart';
import '../../shared/ui_kit/rows/diff_row.dart';

import 'presentation/providers/audit_providers.dart';

/// Full-screen audit event detail -- an auditor building a case needs the
/// field comparison, related events, and system metadata all reachable
/// without a shallow drawer cutting anything off.
class AuditDetailScreen extends ConsumerWidget {
  final String eventId;
  final VoidCallback? onOpenLinkedRecord;

  const AuditDetailScreen({super.key, required this.eventId, this.onOpenLinkedRecord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final eventAsync = ref.watch(auditEventDetailProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(eventId),
            if (eventAsync.hasValue)
              Text(
                '${eventAsync.value!.moduleLabel} · Event',
                style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: eventId)),
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (event) {
          final timeLabel = '${event.timestamp.day}/${event.timestamp.month}/${event.timestamp.year} ${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _KeyValueGrid(entries: {
                'Action': event.action,
                'Performed by': event.actorUserName,
                'Timestamp': timeLabel,
                'Approval': event.approvalStatus ?? 'N/A',
              }),
              const SizedBox(height: 8),
              SeverityBadge(severity: event.severity),
              if (event.changes.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Field comparison', style: textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(
                  '${event.changes.first.fieldLabel} — modified',
                  style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                DiffRow(
                  oldValue: event.changes.first.oldValueLabel,
                  newValue: event.changes.first.newValueLabel,
                ),
                if (event.reason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reason logged: "${event.reason}"',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
              if (event.relatedEvents.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Related events', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'reconstructs the workflow',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                for (final related in event.relatedEvents)
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
                      'IP Address': event.ipAddress ?? 'N/A',
                      'Device': event.device ?? 'N/A',
                      'Browser': event.browser ?? 'N/A',
                      'Session ID': event.sessionId ?? 'N/A',
                      'Request ID': event.requestId ?? 'N/A',
                      'Execution time': '12ms',
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
                      onPressed: () => Clipboard.setData(ClipboardData(text: event.id)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Open ${event.moduleLabel}',
                      onPressed: onOpenLinkedRecord,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
