import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../providers/donor_providers.dart';
import '../widgets/donor_list_item.dart';
import '../widgets/donor_status_filter_chips.dart';
import 'donor_detail_screen.dart';
import 'donor_form_screen.dart';

class DonorListScreen extends ConsumerWidget {
  const DonorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donorListControllerProvider);
    final donorsAsync = ref.watch(donorListProvider);

    return AppScaffold(
      title: 'Donors',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppSearchBar(
              hint: 'Search donors',
              onChanged: (value) => ref
                  .read(donorListControllerProvider.notifier)
                  .updateSearch(value),
            ),
            const SizedBox(height: AppSpacing.md),
            DonorStatusFilterChips(
              selectedStatus: state.status,
              onChanged: (status) => ref
                  .read(donorListControllerProvider.notifier)
                  .updateStatus(status),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: donorsAsync.when(
                data: (donors) {
                  if (donors.isEmpty) {
                    return AppEmptyState(
                        title: 'No donors found',
                        message: 'Try a different search or filter.');
                  }
                  return ListView.separated(
                    itemCount: donors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final donor = donors[index];
                      return DonorListItem(
                        donor: donor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  DonorDetailScreen(donorId: donor.id)),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const AppLoadingIndicator(label: 'Loading donors...'),
                error: (error, stackTrace) =>
                    AppErrorView(message: error.toString()),
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
          UserRole.volunteer,
        ],
        child: AppFab(
            label: 'Add',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DonorFormScreen()),
              );
            }),
      ),
    );
  }
}
