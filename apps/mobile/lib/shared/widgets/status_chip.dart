import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Standardized pill component showing workflow status across all modules.
class StatusChip extends StatelessWidget {
  final String label;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    this.showDot = true,
  });

  static Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
      case 'active':
      case 'sent':
        return AppColors.statusConfirmed;
      case 'receipted':
      case 'approved':
      case 'paid':
        return AppColors.statusReceipted;
      case 'pending match':
      case 'pending approval':
      case 'pending':
        return AppColors.statusPending;
      case 'rejected':
      case 'failed':
        return AppColors.statusRejected;
      case 'voided':
      case 'draft':
      case 'cancelled':
        return AppColors.statusVoided;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
