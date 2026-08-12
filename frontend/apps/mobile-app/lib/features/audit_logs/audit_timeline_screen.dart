import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui_kit/chips/severity_badge.dart';
import 'models/audit_models.dart';
import 'presentation/providers/audit_providers.dart';

/// The Audit Log's dedicated full-screen timeline -- its own screen rather
/// than a tab of Overview, since reconstructing a sequence of events needs
/// the whole day uninterrupted by summary cards above it.
///
/// Groups beyond [collapseThreshold] items collapse behind a "N more" link,
/// so history never overwhelms the list by default.
class AuditTimelineScreen extends ConsumerStatefulWidget {
  final ValueChanged<AuditEventData>? onOpenEvent;
  final int collapseThreshold;

  const AuditTimelineScreen({
    super.key,
    this.onOpenEvent,
    this.collapseThreshold = 4,
  });

  @override
  ConsumerState<AuditTimelineScreen> createState() =>
      _AuditTimelineScreenState();
}

class _AuditTimelineScreenState extends ConsumerState<AuditTimelineScreen> {
  final Set<String> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final state = ref.watch(auditLogsNotifierProvider);
    final events = ref.watch(auditEventListProvider);

    final groups = <String, List<AuditEventData>>{};
    for (final event in events) {
      groups.putIfAbsent(event.groupLabel, () => []).add(event);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: state.isLoading && events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final group in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          group.key.toUpperCase(),
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      () {
                        final isExpanded = _expandedGroups.contains(group.key);
                        final visible = isExpanded ||
                                group.value.length <= widget.collapseThreshold
                            ? group.value
                            : group.value
                                .take(widget.collapseThreshold)
                                .toList();
                        return Column(
                          children: [
                            for (final event in visible)
                              _TimelineRow(
                                  event: event, onTap: widget.onOpenEvent),
                            if (!isExpanded &&
                                group.value.length > widget.collapseThreshold)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () => setState(
                                      () => _expandedGroups.add(group.key)),
                                  child: Text(
                                      '${group.value.length - widget.collapseThreshold} more'),
                                ),
                              ),
                          ],
                        );
                      }(),
                    ],
                  ],
                ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final AuditEventData event;
  final ValueChanged<AuditEventData>? onTap;

  const _TimelineRow({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap == null ? null : () => onTap!(event),
      leading: SeverityBadge(severity: event.severity),
      title: Text(event.title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text('${event.actorName} · ${event.moduleLabel}'),
      trailing: Text(event.timeLabel, style: textTheme.labelSmall),
    );
  }
}
