import 'package:flutter/material.dart';

import 'status_chip.dart';

/// The fixed five-level severity vocabulary shared by the Audit Log and
/// Notification Center modules -- one scale, learned once.
enum Severity { info, low, medium, high, critical }

/// Renders a [Severity] as a [StatusChip] with its fixed color, icon and
/// label, so the same severity always looks identical everywhere it appears.
///
/// Unlike [StatusChip], the icon here is never optional -- severity is a
/// closed vocabulary the design system always pairs with an icon.
class SeverityBadge extends StatelessWidget {
  final Severity severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final (StatusChipType type, IconData icon, String label) =
        switch (severity) {
      Severity.info => (StatusChipType.neutral, Icons.info_outline, 'Info'),
      Severity.low => (
          StatusChipType.success,
          Icons.check_circle_outline,
          'Low'
        ),
      Severity.medium => (StatusChipType.info, Icons.info_outline, 'Medium'),
      Severity.high => (
          StatusChipType.warning,
          Icons.warning_amber_rounded,
          'High'
        ),
      Severity.critical => (
          StatusChipType.error,
          Icons.report_problem_rounded,
          'Critical'
        ),
    };

    return StatusChip(label: label, type: type, icon: icon);
  }
}
