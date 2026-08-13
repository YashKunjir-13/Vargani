import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../models/vendor.dart';
import '../providers/vendor_providers.dart';
import '../widgets/vendor_contract_status_badge.dart';
import 'vendor_form_screen.dart';

class VendorDetailScreen extends ConsumerWidget {
  const VendorDetailScreen({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeControllerProvider);
    final vendorAsync = ref.watch(vendorDetailProvider(vendorId));
    final role = ref.watch(roleProvider);
    final textTheme = Theme.of(context).textTheme;
    final colors = context.authColors;

    final canManageVendors = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

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
                // ── 1. Vendor Header Card ───────────────────────────────────
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vendor.name,
                                    style: textTheme.headlineMedium),
                                const SizedBox(height: AppSpacing.space4),
                                Text(
                                  vendor.category ?? 'Uncategorized Vendor',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colors.secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VendorContractStatusBadge(
                              status: vendor.contractStatus),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space16),
                      _infoRow(context, 'Contact Person',
                          vendor.contactPerson ?? '—'),
                      _infoRow(
                        context,
                        'Mobile',
                        vendor.mobile != null
                            ? maskMobile(vendor.mobile!,
                                canViewSensitive: canManageVendors)
                            : '—',
                      ),
                      _infoRow(context, 'Email', vendor.email ?? '—'),
                      if (vendor.address != null)
                        _infoRow(context, 'Address', vendor.address!),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),

                // ── 2. Tax & Bank Details Card (Requirements 110 & 114) ────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_rounded,
                              color: colors.brandOrange, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Tax & Bank Information (Masked Encrypted)',
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _infoRow(context, 'GSTIN', vendor.maskedGstin),
                      _infoRow(context, 'PAN Tax ID', vendor.maskedPan),
                      _infoRow(
                          context, 'Bank Account', vendor.maskedBankAccount),
                      _infoRow(context, 'Bank IFSC', vendor.maskedBankIfsc),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),

                // ── 3. Expense Freeze Snapshot Notice (Requirement 113) ────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_clock_rounded,
                          color: colors.secondaryText, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Approved expenses freeze a vendor snapshot so master edits do not alter historical ledgers.',
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),

                if (vendor.status == VendorStatus.inactive)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.block_rounded,
                            color: Colors.amber, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This vendor is inactive (soft-deactivated). Historical expense records remain intact, but new expenses cannot be assigned.',
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (vendor.status == VendorStatus.inactive)
                  const SizedBox(height: AppSpacing.space16),

                // ── 4. Financial Summary Cards ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Contract Total',
                        value: formatPaiseAsRupees(vendor.contractAmountPaise),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Paid Amount',
                        value: formatPaiseAsRupees(vendor.paidAmountPaise),
                        valueColor: AppColors.lightSuccess,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space8),
                    Expanded(
                      child: AppSummaryStatCard(
                        label: 'Outstanding',
                        value:
                            formatPaiseAsRupees(vendor.outstandingAmountPaise),
                        valueColor: vendor.outstandingAmountPaise > 0
                            ? AppColors.lightError
                            : AppColors.lightSuccess,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space24),

                // ── 5. Action Buttons (Role Gated) ──────────────────────────
                if (canManageVendors)
                  Row(
                    children: [
                      Expanded(
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
                      const SizedBox(width: AppSpacing.space12),
                      if (vendor.status == VendorStatus.active)
                        Expanded(
                          child: AppButton(
                            label: 'Deactivate',
                            variant: AppButtonVariant.secondary,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Deactivate Vendor?'),
                                  content: const Text(
                                    'Soft-deactivating blocks future expense creation while preserving immutable history.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    AppButton(
                                      label: 'Deactivate',
                                      fullWidth: false,
                                      onPressed: () => Navigator.pop(ctx, true),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref
                                    .read(vendorRepositoryProvider)
                                    .deactivateVendor(id: vendor.id);
                                ref.invalidate(vendorDetailProvider(vendor.id));
                                ref.invalidate(vendorListProvider);
                              }
                            },
                          ),
                        ),
                      if (vendor.status == VendorStatus.inactive)
                        Expanded(
                          child: AppButton(
                            label: 'Reactivate',
                            variant: AppButtonVariant.secondary,
                            onPressed: () async {
                              await ref
                                  .read(vendorRepositoryProvider)
                                  .reactivateVendor(id: vendor.id);
                              ref.invalidate(vendorDetailProvider(vendor.id));
                              ref.invalidate(vendorListProvider);
                            },
                          ),
                        ),
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

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
