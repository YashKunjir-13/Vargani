import 'package:flutter/material.dart';

import '../../shared/ui_kit/overlays/export_sheet.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Notifications' configuration of the shared [ExportSheet].
class ExportNotificationsSheet extends StatelessWidget {
  final String activeScopeLabel;

  const ExportNotificationsSheet({super.key, this.activeScopeLabel = 'Unread filter active'});

  static Future<void> show(BuildContext context, {String activeScopeLabel = 'Unread filter active'}) {
    return AppBottomSheet.show<void>(
      context,
      builder: (_) => ExportNotificationsSheet(activeScopeLabel: activeScopeLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExportSheet(
      title: 'Export Notifications',
      activeScopeLabel: activeScopeLabel,
      formats: const [
        ExportFormatOption(label: 'PDF', icon: Icons.picture_as_pdf_outlined),
        ExportFormatOption(label: 'Excel', icon: Icons.table_chart_outlined),
        ExportFormatOption(label: 'CSV', icon: Icons.description_outlined),
        ExportFormatOption(label: 'Print', icon: Icons.print_outlined),
      ],
      sections: const ['Priority alerts', 'Full feed (filtered)'],
      initiallyIncludedSections: const {'Priority alerts', 'Full feed (filtered)'},
      onGenerate: (format, sections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export ready ($format)')),
        );
      },
    );
  }
}
