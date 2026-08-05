import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// The Dashboard's advanced filter sheet: date range, financial category,
/// donation type and expense category, all applying simultaneously.
class DashboardFiltersSheet extends StatefulWidget {
  const DashboardFiltersSheet({super.key});

  /// Presents this sheet modally.
  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show<void>(context, builder: (_) => const DashboardFiltersSheet());
  }

  @override
  State<DashboardFiltersSheet> createState() => _DashboardFiltersSheetState();
}

class _DashboardFiltersSheetState extends State<DashboardFiltersSheet> {
  static const _defaultDateRange = 'This Week';
  static const _defaultCategories = {'Donations', 'Expenses'};

  String _dateRange = _defaultDateRange;
  final Set<String> _categories = {..._defaultCategories};

  void _reset() {
    setState(() {
      _dateRange = _defaultDateRange;
      _categories
        ..clear()
        ..addAll(_defaultCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Filters',
      trailing: TextButton(onPressed: _reset, child: const Text('Reset')),
      actions: [
        SecondaryButton(label: 'Clear all', onPressed: () => Navigator.of(context).pop()),
        PrimaryButton(
          label: 'Apply (${_categories.length})',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterGroup(
            label: 'Date range',
            child: Wrap(
              spacing: 8,
              children: [
                for (final range in ['Today', 'This Week', 'This Month', 'Festival Duration', 'Custom'])
                  ChoiceChip(
                    label: Text(range),
                    selected: _dateRange == range,
                    onSelected: (_) => setState(() => _dateRange = range),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _FilterGroup(
            label: 'Financial category',
            child: Wrap(
              spacing: 8,
              children: [
                for (final category in ['Donations', 'Expenses', 'Sponsorships'])
                  FilterChip(
                    label: Text(category),
                    selected: _categories.contains(category),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _categories.add(category);
                      } else {
                        _categories.remove(category);
                      }
                    }),
                  ),
              ],
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
