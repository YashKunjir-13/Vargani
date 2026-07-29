import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../models/vendor.dart';
import '../providers/vendor_providers.dart';
import '../widgets/vendor_contract_status_badge.dart';
import 'vendor_form_screen.dart';

class VendorDetailScreen extends ConsumerWidget {
  const VendorDetailScreen({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorDetailProvider(vendorId));
    final textTheme = Theme.of(context).textTheme;

    return vendorAsync.when(
      data: (vendor) {
        if (vendor == null) {
          return const AppScaffold(
            title: 'Vendor',
            body: AppEmptyState(title: 'Vendor not found'),
          );
        }
        return AppScaffold(
          title: vendor.name,
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
                          Text(vendor.name, style: textTheme.headlineMedium),
                          const SizedBox(height: AppSpacing.space4),
                          Text(
                            vendor.category ?? 'Uncategorized',
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedTextFor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    VendorContractStatusBadge(status: vendor.contractStatus),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                if (vendor.contactPerson != null ||
                    vendor.mobile != null ||
                    vendor.email != null)
                  Wrap(
                    spacing: AppSpacing.space8,
                    runSpacing: AppSpacing.space8,
                    children: [
                      if (vendor.contactPerson != null)
                        Text(vendor.contactPerson!, style: textTheme.bodyLarge),
                      if (vendor.mobile != null)
                        Text(vendor.mobile!, style: textTheme.bodyLarge),
                      if (vendor.email != null)
                        Text(vendor.email!, style: textTheme.bodyLarge),
                    ],
                  ),
                if (vendor.status == VendorStatus.inactive)
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
                      'This vendor is deactivated and cannot be assigned to new expenses',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                const SizedBox(height: AppSpacing.space32),
                Row(
                  children: [
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Contract',
                        value: formatPaiseAsRupees(vendor.contractAmountPaise),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Paid',
                        value: formatPaiseAsRupees(vendor.paidAmountPaise),
                        valueColor: AppColors.lightSuccess,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Balance',
                        value:
                            formatPaiseAsRupees(vendor.outstandingAmountPaise),
                        valueColor: vendor.outstandingAmountPaise > 0
                            ? AppColors.lightError
                            : AppColors.lightSuccess,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space32),
                Row(
                  children: [
                    Expanded(
                      child: RoleGate(
                        allowedRoles: const [
                          UserRole.trustPresident,
                          UserRole.vicePresident,
                          UserRole.treasurer,
                        ],
                        child: AppButton(
                          label: 'Edit Vendor',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    VendorFormScreen(vendorId: vendor.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (vendor.status == VendorStatus.active) ...[
                      const SizedBox(width: AppSpacing.space8),
                      Expanded(
                        child: RoleGate(
                          allowedRoles: const [
                            UserRole.trustPresident,
                            UserRole.vicePresident,
                            UserRole.treasurer,
                          ],
                          child: AppButton(
                            label: 'Deactivate Vendor',
                            variant: AppButtonVariant.secondary,
                            onPressed: () async {
                              final shouldDeactivate = await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Deactivate vendor?'),
                                      content: const Text(
                                          'This vendor will become inactive and will not be assigned to new expenses.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(dialogContext)
                                                    .pop(false),
                                            child: const Text('Cancel')),
                                        AppButton(
                                            label: 'Deactivate',
                                            onPressed: () =>
                                                Navigator.of(dialogContext)
                                                    .pop(true)),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (!shouldDeactivate) {
                                return;
                              }
                              final repository =
                                  ref.read(vendorRepositoryProvider);
                              await repository.updateVendor(
                                  id: vendor.id, status: VendorStatus.inactive);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Vendor deactivated')));
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Vendor',
        body: AppLoadingIndicator(label: 'Loading vendor...'),
      ),
      error: (error, stackTrace) => AppScaffold(
        title: 'Vendor',
        body: AppErrorView(message: error.toString()),
      ),
    );
  }
}
