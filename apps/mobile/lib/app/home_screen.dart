import 'package:flutter/material.dart';

import '../core/core.dart';
import '../shared/shared.dart';
import 'all_records_screen.dart';

/// Home landing screen for Pauti Pustak.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'Pauti Pustak',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
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
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        'Multi-tenant event financial management platform',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedTextFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space16),
                // ── All Records button in top-right of body ────────────
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AllRecordsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: const Text('All Records'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    elevation: 0,
                    textStyle: textTheme.labelLarge?.copyWith(
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
