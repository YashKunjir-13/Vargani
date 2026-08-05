import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Budget's advanced filter sheet: version, approval status, health, owner
/// and a utilization-percentage range -- grouped identity filters above
/// ownership filters, above the range slider.
class BudgetFiltersSheet extends StatefulWidget {
  const BudgetFiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show<void>(context, builder: (_) => const BudgetFiltersSheet());
  }

  @override
  State<BudgetFiltersSheet> createState() => _BudgetFiltersSheetState();
}

class _BudgetFiltersSheetState extends State<BudgetFiltersSheet> {
  String _version = 'v4 (Active)';
  String _health = 'Over Budget';
  RangeValues _utilization = const RangeValues(60, 100);

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Filters',
      trailing: TextButton(
        onPressed: () => setState(() {
          _version = 'v4 (Active)';
          _health = 'Over Budget';
          _utilization = const RangeValues(60, 100);
        }),
        child: const Text('Reset'),
      ),
      actions: [
        SecondaryButton(label: 'Clear all', onPressed: () => Navigator.of(context).pop()),
        PrimaryButton(label: 'Apply (3)', onPressed: () => Navigator.of(context).pop()),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterGroup(
            label: 'Budget version',
            child: Wrap(
              spacing: 8,
              children: [
                for (final version in ['v4 (Active)', 'v3', 'v2'])
                  ChoiceChip(
                    label: Text(version),
                    selected: _version == version,
                    onSelected: (_) => setState(() => _version = version),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _FilterGroup(
            label: 'Budget health',
            child: Wrap(
              spacing: 8,
              children: [
                for (final health in ['Over Budget', 'Warning', 'Healthy', 'Under-utilized'])
                  ChoiceChip(
                    label: Text(health),
                    selected: _health == health,
                    onSelected: (_) => setState(() => _health = health),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _FilterGroup(
            label: 'Utilization % — ${_utilization.start.round()} to ${_utilization.end.round()}',
            child: RangeSlider(
              values: _utilization,
              min: 0,
              max: 150,
              divisions: 30,
              labels: RangeLabels('${_utilization.start.round()}', '${_utilization.end.round()}'),
              onChanged: (values) => setState(() => _utilization = values),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
