import 'package:flutter/material.dart';

import '../../shared/ui_kit/overlays/export_sheet.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Budget's configuration of the shared [ExportSheet].
class ExportBudgetSheet extends StatelessWidget {
  final String activeScopeLabel;

  const ExportBudgetSheet({super.key, this.activeScopeLabel = 'v4 · Active'});

  static Future<void> show(BuildContext context,
      {String activeScopeLabel = 'v4 · Active'}) {
    return AppBottomSheet.show<void>(
      context,
      builder: (_) => ExportBudgetSheet(activeScopeLabel: activeScopeLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExportSheet(
      title: 'Export Budget',
      activeScopeLabel: activeScopeLabel,
      formats: const [
        ExportFormatOption(label: 'PDF', icon: Icons.picture_as_pdf_outlined),
        ExportFormatOption(label: 'Excel', icon: Icons.table_chart_outlined),
        ExportFormatOption(label: 'CSV', icon: Icons.description_outlined),
        ExportFormatOption(label: 'Print', icon: Icons.print_outlined),
      ],
      sections: const [
        'Budget summary',
        'Category breakdown',
        'Revision history',
        'Approval trail'
      ],
      initiallyIncludedSections: const {'Budget summary', 'Category breakdown'},
      onGenerate: (format, sections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export ready ($format)')),
        );
      },
    );
  }
}
