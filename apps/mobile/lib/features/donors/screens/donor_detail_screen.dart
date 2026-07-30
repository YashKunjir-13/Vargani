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
    final textTheme = Theme.of(context).textTheme;

    return donorAsync.when(
      data: (donor) {
        if (donor == null) {
          return const AppScaffold(
              title: 'Donor', body: AppEmptyState(title: 'Donor not found'));
        }
        return AppScaffold(
          title: donor.fullName,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(donor.fullName, style: textTheme.headlineMedium),
                          const SizedBox(height: AppSpacing.space8),
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
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.email_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                if (donor.mobile != null || donor.email != null)
                  Wrap(
                    spacing: AppSpacing.space8,
                    children: [
                      if (donor.mobile != null)
                        Text(donor.mobile!, style: textTheme.bodyLarge),
                      if (donor.email != null)
                        Text(donor.email!, style: textTheme.bodyLarge),
                    ],
                  ),
                if (donor.status == DonorProfileStatus.unclaimed)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.space16),
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Text(
                      'This donor profile was created offline and has not been claimed yet',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                const SizedBox(height: AppSpacing.space32),
                Row(
                  children: [
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Contributions',
                        value: donor.totalContributionsCount.toString(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
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
                const SizedBox(height: AppSpacing.space32),
                AppCard(
                  title: 'Contribution history',
                  subtitle: 'Placeholder for future Contributions module',
                  child: Text(
                    'Contribution history will appear here. TODO: connect this to the future Contributions module.',
                    style: textTheme.bodyLarge,
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
                    builder: (_) => DonorFormScreen(donorId: donor.id),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
          title: 'Donor', body: AppLoadingIndicator(label: 'Loading donor...')),
      error: (error, stackTrace) => AppScaffold(
        title: 'Donor',
        body: AppErrorView(message: error.toString()),
      ),
    );
  }
}
