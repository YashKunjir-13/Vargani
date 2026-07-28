import 'package:flutter/material.dart';

enum StatusType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
  });

  Color _backgroundColor(ColorScheme scheme) => switch (type) {
        StatusType.success => Colors.green.shade50,
        StatusType.warning => Colors.orange.shade50,
        StatusType.error => scheme.errorContainer,
        StatusType.info => scheme.primaryContainer,
        StatusType.neutral => scheme.surfaceContainerHighest,
      };

  Color _foregroundColor(ColorScheme scheme) => switch (type) {
        StatusType.success => Colors.green.shade700,
        StatusType.warning => Colors.orange.shade800,
        StatusType.error => scheme.onErrorContainer,
        StatusType.info => scheme.onPrimaryContainer,
        StatusType.neutral => scheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor(scheme),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _foregroundColor(scheme),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
