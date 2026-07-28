import 'package:flutter/material.dart';

import '../core/core.dart';
import '../shared/shared.dart';
import 'all_records_screen.dart';

/// Home landing screen for Pauti Pustak.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pauti Pustak',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + All Records button (top-right of body) ───────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pauti Pustak',
                        style: AppTypography.display(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Multi-tenant event financial management platform',
                        style: AppTypography.caption(
                          context,
                          color: AppColors.mutedTextFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // ── All Records button in top-right of body ────────────
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AllRecordsScreen()),
                  ),
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: const Text('All Records'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    elevation: 0,
                    textStyle: AppTypography.label(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
