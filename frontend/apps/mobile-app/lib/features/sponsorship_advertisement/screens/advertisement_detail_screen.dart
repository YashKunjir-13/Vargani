import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/advertisement.dart';
import '../providers/advertisement_providers.dart';
import '../widgets/advertisement_status_badge.dart';
import 'advertisement_form_screen.dart';

class AdvertisementDetailScreen extends ConsumerWidget {
  const AdvertisementDetailScreen({super.key, required this.advertisementId});

  final String advertisementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adAsync = ref.watch(advertisementDetailProvider(advertisementId));
    final textTheme = Theme.of(context).textTheme;

    return adAsync.when(
      data: (ad) {
        if (ad == null) {
          return const AppScaffold(
            title: 'Advertisement Detail',
            body: AppEmptyState(title: 'Advertisement not found'),
          );
        }

        return AppScaffold(
          title: ad.advertiserName,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(
                        ad.type.label,
                        style: textTheme.labelLarge,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    AdvertisementStatusBadge(status: ad.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Text(
                  ad.advertiserName,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.space16),
                AppCard(
                  title: 'Placement Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: AppSpacing.space8),
                          Expanded(
                            child: Text(
                              ad.placementDetail != null &&
                                      ad.placementDetail!.isNotEmpty
                                  ? ad.placementDetail!
                                  : 'No specific placement details specified.',
                              style: textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                AppSummaryStatCard(
                  label: 'Booking Amount',
                  value: formatPaiseAsRupees(ad.amountPaise),
                  valueColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.space32),
                if (ad.status != AdvertisementStatus.active)
                  RoleGate(
                    allowedRoles: const [
                      UserRole.trustPresident,
                      UserRole.vicePresident,
                      UserRole.treasurer,
                    ],
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.space16),
                      child: AppButton(
                        label: 'Mark as Active',
                        icon: Icons.check_circle_outline,
                        onPressed: () => _markAsActive(context, ref, ad),
                      ),
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
                    builder: (_) => AdvertisementFormScreen(
                      advertisementId: ad.id,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Advertisement Detail',
        body: AppLoadingIndicator(label: 'Loading advertisement...'),
      ),
      error: (error, stack) => AppScaffold(
        title: 'Advertisement Detail',
        body: AppErrorView(message: error.toString()),
      ),
    );
  }

  void _markAsActive(
    BuildContext context,
    WidgetRef ref,
    Advertisement ad,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mark Advertisement Active'),
          content: Text(
            'Are you sure you want to mark ${ad.advertiserName} advertisement as Active?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref
                    .read(advertisementRepositoryProvider)
                    .markAsActive(ad.id);
                ref.invalidate(advertisementListProvider);
                ref.invalidate(advertisementDetailProvider(ad.id));
              },
              child: const Text('Mark Active'),
            ),
          ],
        );
      },
    );
  }
}
