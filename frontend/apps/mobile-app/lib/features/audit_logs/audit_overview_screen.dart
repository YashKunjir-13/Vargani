import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui_kit/cards/alert_card.dart';
import '../../shared/ui_kit/chips/severity_badge.dart';
import 'models/audit_models.dart';
import 'presentation/providers/audit_providers.dart';

/// The Audit Log hub: summary cards, the critical security banner, then a
/// Timeline<->Table toggle over the identical filtered result set --
/// [IndexedStack] preserves each view's scroll position across switches.
class AuditOverviewScreen extends ConsumerStatefulWidget {
  final ValueChanged<AuditEventData>? onOpenEvent;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenFilters;

  const AuditOverviewScreen({
    super.key,
    this.onOpenEvent,
    this.onOpenSearch,
    this.onOpenFilters,
  });

  @override
  ConsumerState<AuditOverviewScreen> createState() => _AuditOverviewScreenState();
}

class _AuditOverviewScreenState extends ConsumerState<AuditOverviewScreen> {
  int _viewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final state = ref.watch(auditLogsNotifierProvider);
    final summary = ref.watch(auditSummaryProvider);
    final events = ref.watch(auditEventListProvider);

    final groups = <String, List<AuditEventData>>{};
    for (final event in events) {
      groups.putIfAbsent(event.groupLabel, () => []).add(event);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(onPressed: widget.onOpenSearch, icon: const Icon(Icons.search)),
          IconButton(onPressed: widget.onOpenFilters, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: state.isLoading && events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Expanded(child: _SummaryTile(value: '${summary.todayEventsCount}', label: 'Today')),
                          Expanded(
                            child: _SummaryTile(
                              value: '${summary.criticalCount}',
                              label: 'Critical',
                              valueColor: colorScheme.error,
                            ),
                          ),
                          Expanded(child: _SummaryTile(value: '${summary.financialCount}', label: 'Financial')),
                          Expanded(
                            child: _SummaryTile(
                              value: '${summary.securityCount}',
                              label: 'Security',
                              valueColor: colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (summary.criticalCount > 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: AlertCard(
                          icon: Icons.report_problem_rounded,
                          title: '${summary.criticalCount} Critical Events',
                          subtitle: 'Immediate review required for critical security or financial actions.',
                          tone: AlertTone.critical,
                          actionLabel: 'Investigate →',
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Timeline')),
                          ButtonSegment(value: 1, label: Text('Table')),
                        ],
                        selected: {_viewIndex},
                        showSelectedIcon: false,
                        onSelectionChanged: (selection) => setState(() => _viewIndex = selection.first),
                      ),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _viewIndex,
                        children: [
                          ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                for (final event in group.value)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: widget.onOpenEvent == null ? null : () => widget.onOpenEvent!(event),
                                    leading: SeverityBadge(severity: event.severity),
                                    title: Text(event.title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                                    subtitle: Text('${event.actorName} · ${event.moduleLabel}'),
                                    trailing: Text(event.timeLabel, style: textTheme.labelSmall),
                                  ),
                              ],
                            ],
                          ),
                          ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Time')),
                                    DataColumn(label: Text('User')),
                                    DataColumn(label: Text('Action')),
                                    DataColumn(label: Text('Severity')),
                                  ],
                                  rows: [
                                    for (final event in events)
                                      DataRow(
                                        onSelectChanged: widget.onOpenEvent == null
                                            ? null
                                            : (_) => widget.onOpenEvent!(event),
                                        cells: [
                                          DataCell(Text(event.timeLabel)),
                                          DataCell(Text(event.actorName)),
                                          DataCell(Text(event.title)),
                                          DataCell(SeverityBadge(severity: event.severity)),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _SummaryTile({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
