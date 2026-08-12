import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';
import '../surfaces/app_bottom_sheet.dart';

/// One selectable export format, e.g. PDF, Excel, CSV, JSON, Print.
@immutable
class ExportFormatOption {
  final String label;
  final IconData icon;

  const ExportFormatOption({required this.label, required this.icon});
}

/// The export sheet shared by all four modules: a format picker, a
/// checklist of sections to include, and a Cancel/Generate footer.
///
/// Every module's export screen in the approved design follows this exact
/// shape (only the format list and section labels differ), so this is the
/// one implementation each module's export sheet configures rather than
/// rebuilds.
class ExportSheet extends StatefulWidget {
  final String title;

  /// Shown in the header trailing slot, e.g. "This Week" -- communicates
  /// that the export always respects the currently active filter.
  final String activeScopeLabel;

  final List<ExportFormatOption> formats;
  final List<String> sections;
  final Set<String> initiallyIncludedSections;

  /// Extra content appended after the checklist (e.g. Audit's schedule
  /// toggle) -- optional, so most modules don't need to supply anything.
  final Widget? extra;

  final void Function(String format, Set<String> includedSections) onGenerate;

  const ExportSheet({
    super.key,
    required this.title,
    required this.activeScopeLabel,
    required this.formats,
    required this.sections,
    this.initiallyIncludedSections = const {},
    this.extra,
    required this.onGenerate,
  });

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  late String _selectedFormat;
  late Set<String> _included;

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.formats.first.label;
    _included = {...widget.initiallyIncludedSections};
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBottomSheet(
      title: widget.title,
      trailing: Text(
        widget.activeScopeLabel,
        style: textTheme.labelMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      actions: [
        SecondaryButton(
            label: 'Cancel', onPressed: () => Navigator.of(context).pop()),
        PrimaryButton(
          label: 'Generate Export',
          onPressed: () {
            widget.onGenerate(_selectedFormat, _included);
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GroupLabel('Format'),
          const SizedBox(height: AppSpacing.space8),
          Wrap(
            spacing: AppSpacing.space8,
            runSpacing: AppSpacing.space8,
            children: [
              for (final format in widget.formats)
                _FormatTile(
                  option: format,
                  selected: format.label == _selectedFormat,
                  onTap: () => setState(() => _selectedFormat = format.label),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.space20),
          const _GroupLabel('Include'),
          for (final section in widget.sections)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(section, style: textTheme.bodyLarge),
              value: _included.contains(section),
              onChanged: (checked) => setState(() {
                if (checked ?? false) {
                  _included.add(section);
                } else {
                  _included.remove(section);
                }
              }),
            ),
          if (widget.extra != null) ...[
            const SizedBox(height: AppSpacing.space12),
            widget.extra!,
          ],
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;

  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: Theme.of(context)
          .textTheme
          .labelMedium
          ?.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }
}

class _FormatTile extends StatelessWidget {
  final ExportFormatOption option;
  final bool selected;
  final VoidCallback onTap;

  const _FormatTile(
      {required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surface,
          border: Border.all(
              color: selected ? Colors.transparent : colorScheme.outline),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Column(
          children: [
            Icon(
              option.icon,
              size: AppIconSize.medium,
              color: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              option.label,
              style: textTheme.labelSmall?.copyWith(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
