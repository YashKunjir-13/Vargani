import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Audit's advanced filter sheet -- the richest field set of any module,
/// including device/browser/IP, since forensic investigation sometimes
/// starts from "what came from this device," not from a person's name.
class AuditFiltersSheet extends StatefulWidget {
  const AuditFiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show<void>(context, builder: (_) => const AuditFiltersSheet());
  }

  @override
  State<AuditFiltersSheet> createState() => _AuditFiltersSheetState();
}

class _AuditFiltersSheetState extends State<AuditFiltersSheet> {
  final Set<String> _modules = {'Budget'};
  final Set<String> _categories = {'Financial'};
  final Set<String> _severities = {'Medium'};
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Filters',
      trailing: TextButton(
        onPressed: () => setState(() {
          _modules
            ..clear()
            ..add('Budget');
          _categories
            ..clear()
            ..add('Financial');
          _severities
            ..clear()
            ..add('Medium');
          _ipController.clear();
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
          _MultiChipGroup(
            label: 'Module',
            options: const ['Budget', 'Expenses', 'Receipts', 'Authentication'],
            selected: _modules,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _MultiChipGroup(
            label: 'Category',
            options: const ['Financial', 'Administrative', 'Security', 'System'],
            selected: _categories,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _MultiChipGroup(
            label: 'Severity',
            options: const ['Info', 'Low', 'Medium', 'High', 'Critical'],
            selected: _severities,
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text(
            'IP ADDRESS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              hintText: 'e.g. 103.22.x.x',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiChipGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  const _MultiChipGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

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
        Wrap(
          spacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (isSelected) {
                  if (isSelected) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  onChanged(selected);
                },
              ),
          ],
        ),
      ],
    );
  }
}
