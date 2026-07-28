import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../shared/widgets/formatters.dart';
import '../providers/vendor_providers.dart';
import '../widgets/vendor_list_item.dart';
import 'vendor_detail_screen.dart';
import 'vendor_form_screen.dart';

class VendorListScreen extends ConsumerWidget {
  const VendorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorListProvider);
    final totalOutstanding = vendorsAsync.when(
      data: (vendors) => vendors.fold<int>(
          0, (sum, vendor) => sum + vendor.outstandingAmountPaise),
      loading: () => 0,
      error: (_, __) => 0,
    );

    return AppScaffold(
      title: 'Vendors',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSummaryStatCard(
                    label: 'Total Vendors',
                    value: vendorsAsync.when(
                      data: (vendors) => vendors.length.toString(),
                      loading: () => '—',
                      error: (_, __) => '—',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppSummaryStatCard(
                    label: 'Outstanding',
                    value: formatPaiseAsRupees(totalOutstanding),
                    valueColor: AppColors.lightError,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppSearchBar(
              hint: 'Search vendors',
              onChanged: (value) => ref
                  .read(vendorListControllerProvider.notifier)
                  .updateSearch(value),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: vendorsAsync.when(
                data: (vendors) {
                  if (vendors.isEmpty) {
                    return AppEmptyState(
                        title: 'No vendors found',
                        message: 'Try a different search.');
                  }
                  return ListView.separated(
                    itemCount: vendors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return VendorListItem(
                        vendor: vendor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  VendorDetailScreen(vendorId: vendor.id)),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const AppLoadingIndicator(label: 'Loading vendors...'),
                error: (error, stackTrace) =>
                    AppErrorView(message: error.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleGate(
        allowedRoles: const [Role.owner, Role.treasurer, Role.expenseApprover],
        child: AppFab(
          label: '+ Bill',
          onPressed: () {
            // TODO: this is intentionally scoped to vendor create/edit UI until the
            // future expenses/bills module exists in the backend contract.
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VendorFormScreen()));
          },
        ),
      ),
    );
  }
}
