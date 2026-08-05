import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/charts/app_line_chart.dart';
import 'models/dashboard_models.dart';
import 'widgets/timeline_item.dart';

/// Full-screen KPI investigation view, entered by tapping a [KpiCard] on
/// the Dashboard Home screen.
///
/// A financial figure on this platform carries real accountability weight,
/// so this is a dedicated screen (not a popover): trend, period comparison,
/// breakdown, and the transactions that make up the number all need to be
/// reachable together.
class KpiDetailScreen extends StatefulWidget {
  final KpiDetailData data;

  const KpiDetailScreen({super.key, required this.data});

  @override
  State<KpiDetailScreen> createState() => _KpiDetailScreenState();
}

class _KpiDetailScreenState extends State<KpiDetailScreen> {
  static const _periods = ['Week', 'Month', 'Festival', 'Custom'];
  String _selectedPeriod = _periods.first;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(data.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            data.valueLabel,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.arrow_upward, size: 14, color: colorScheme.primary),
              const SizedBox(width: 2),
              Text(
                data.deltaLabel,
                style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data.comparisonCaption,
            style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: _periods.map((p) => ButtonSegment(value: p, label: Text(p))).toList(),
            selected: {_selectedPeriod},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => setState(() => _selectedPeriod = selection.first),
          ),
          const SizedBox(height: 20),
          AppLineChart(
            values: data.trendValues,
            color: colorScheme.primary,
            highlightIndex: data.highlightIndex,
            highlightLabel: data.highlightLabel,
          ),
          const SizedBox(height: 24),
          Text('This period vs last', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ComparisonTile(label: data.thisPeriodLabel, value: data.thisPeriodValue, emphasize: true)),
              const SizedBox(width: 12),
              Expanded(child: _ComparisonTile(label: data.lastPeriodLabel, value: data.lastPeriodValue, emphasize: false)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Breakdown by type', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final item in data.breakdown) ...[
            _BreakdownRow(item: item),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Related transactions', style: textTheme.titleMedium),
              TextButton(onPressed: () {}, child: const Text('View all')),
            ],
          ),
          for (final activity in data.relatedTransactions) TimelineItem(data: activity),
          const SizedBox(height: 12),
          SecondaryButton(label: 'Export this view', onPressed: () {}, expand: true),
        ],
      ),
    );
  }
}

class _ComparisonTile extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _ComparisonTile({required this.label, required this.value, required this.emphasize});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: emphasize ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final KpiBreakdownItem item;

  const _BreakdownRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.label, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            Text(item.valueLabel, style: textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: item.progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
