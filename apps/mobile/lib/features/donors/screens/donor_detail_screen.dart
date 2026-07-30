import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/donor.dart';
import '../providers/donor_providers.dart';
import 'donor_form_screen.dart';

class DonorDetailScreen extends ConsumerWidget {
  const DonorDetailScreen({super.key, required this.donorId});

  final String donorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donorAsync = ref.watch(donorDetailProvider(donorId));

    return donorAsync.when(
      data: (donor) {
        if (donor == null) {
          return const AppScaffold(
              title: 'Donor', body: AppEmptyState(title: 'Donor not found'));
        }
        return AppScaffold(
          title: donor.fullName,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(donor.fullName,
                              style: AppTypography.display(context)),
                          const SizedBox(height: AppSpacing.sm),
                          AppStatusBadge(
                            label: donor.status.name.toUpperCase(),
                            status: donor.status == DonorProfileStatus.active
                                ? AppStatus.success
                                : donor.status == DonorProfileStatus.unclaimed
                                    ? AppStatus.info
                                    : donor.status ==
                                            DonorProfileStatus.deactivated
                                        ? AppStatus.neutral
                                        : AppStatus.neutral,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.call_outlined),
                        onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.email_outlined),
                        onPressed: () {}),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (donor.mobile != null || donor.email != null)
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      if (donor.mobile != null)
                        Text(donor.mobile!, style: AppTypography.body(context)),
                      if (donor.email != null)
                        Text(donor.email!, style: AppTypography.body(context)),
                    ],
                  ),
                if (donor.status == DonorProfileStatus.unclaimed)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      'This donor profile was created offline and has not been claimed yet',
                      style: AppTypography.body(context),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Contributions',
                        value: donor.totalContributionsCount.toString(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Total Confirmed',
                        value: formatPaiseAsRupees(
                            donor.totalConfirmedAmountPaise),
                        valueColor: donor.totalConfirmedAmountPaise > 0
                            ? AppColors.lightSuccess
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  title: 'Contribution history',
                  subtitle: 'Placeholder for future Contributions module',
                  child: Text(
                    'Contribution history will appear here. TODO: connect this to the future Contributions module.',
                    style: AppTypography.body(context),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: RoleGate(
            allowedRoles: const [
              UserRole.trustPresident,
              UserRole.vicePresident,
              UserRole.treasurer,
            ],
            child: AppFab(
                label: 'Edit',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => DonorFormScreen(donorId: donor.id)),
                  );
                }),
          ),
        );
      },
      loading: () => const AppScaffold(
          title: 'Donor',
          body: AppLoadingIndicator(label: 'Loading donor...')),
      error: (error, stackTrace) => AppScaffold(
          title: 'Donor', body: AppErrorView(message: error.toString())),
    );
  }
}
