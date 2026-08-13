import 'package:flutter/material.dart';

import '../../shared/ui_kit/overlays/export_sheet.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Audit's configuration of the shared [ExportSheet] -- adds JSON (for
/// downstream compliance tooling) and a recurring schedule, since audit
/// exports are often routine rather than one-off.
class ExportAuditSheet extends StatefulWidget {
  final String activeScopeLabel;

  const ExportAuditSheet({super.key, this.activeScopeLabel = 'This week'});

  static Future<void> show(BuildContext context,
      {String activeScopeLabel = 'This week'}) {
    return AppBottomSheet.show<void>(
      context,
      builder: (_) => ExportAuditSheet(activeScopeLabel: activeScopeLabel),
    );
  }

  @override
  State<ExportAuditSheet> createState() => _ExportAuditSheetState();
}

class _ExportAuditSheetState extends State<ExportAuditSheet> {
  bool _scheduled = false;
  final Set<int> _days = {0, 4}; // Mon, Fri

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExportSheet(
      title: 'Export Audit Log',
      activeScopeLabel: widget.activeScopeLabel,
      formats: const [
        ExportFormatOption(label: 'PDF', icon: Icons.picture_as_pdf_outlined),
        ExportFormatOption(label: 'Excel', icon: Icons.table_chart_outlined),
        ExportFormatOption(label: 'CSV', icon: Icons.description_outlined),
        ExportFormatOption(label: 'JSON', icon: Icons.data_object),
        ExportFormatOption(label: 'Print', icon: Icons.print_outlined),
      ],
      sections: const ['Event list', 'Field comparisons', 'System metadata'],
      initiallyIncludedSections: const {'Event list', 'Field comparisons'},
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCHEDULE',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Repeat weekly'),
            value: _scheduled,
            onChanged: (value) => setState(() => _scheduled = value),
          ),
          if (_scheduled)
            Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < _dayLabels.length; i++)
                  ChoiceChip(
                    label: Text(_dayLabels[i]),
                    selected: _days.contains(i),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _days.add(i);
                      } else {
                        _days.remove(i);
                      }
                    }),
                  ),
              ],
            ),
        ],
      ),
      onGenerate: (format, sections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export ready ($format)')),
        );
      },
    );
  }
}
