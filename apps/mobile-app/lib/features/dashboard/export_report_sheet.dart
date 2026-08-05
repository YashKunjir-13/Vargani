import 'package:flutter/material.dart';

import '../../shared/ui_kit/overlays/export_sheet.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Dashboard's configuration of the shared [ExportSheet] -- always exports
/// exactly what's currently filtered on the Dashboard Home screen.
class ExportReportSheet extends StatelessWidget {
  final String activeScopeLabel;

  const ExportReportSheet({super.key, this.activeScopeLabel = 'This Week'});

  /// Presents this sheet modally.
  static Future<void> show(BuildContext context, {String activeScopeLabel = 'This Week'}) {
    return AppBottomSheet.show<void>(
      context,
      builder: (_) => ExportReportSheet(activeScopeLabel: activeScopeLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExportSheet(
      title: 'Export Dashboard Report',
      activeScopeLabel: activeScopeLabel,
      formats: const [
        ExportFormatOption(label: 'PDF', icon: Icons.picture_as_pdf_outlined),
        ExportFormatOption(label: 'Excel', icon: Icons.table_chart_outlined),
        ExportFormatOption(label: 'CSV', icon: Icons.description_outlined),
        ExportFormatOption(label: 'Print', icon: Icons.print_outlined),
      ],
      sections: const ['Financial KPIs', 'Charts & analytics', 'Recent activity', 'Operational KPIs'],
      initiallyIncludedSections: const {'Financial KPIs', 'Charts & analytics'},
      onGenerate: (format, sections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export ready ($format)')),
        );
      },
    );
  }
}
