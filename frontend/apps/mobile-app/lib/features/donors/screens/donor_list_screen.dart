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
    ref.watch(localeControllerProvider);
    final state = ref.watch(donorListControllerProvider);
    final donorsAsync = ref.watch(donorListProvider);
    final role = ref.watch(roleProvider);

    final canManageDonors = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer ||
        role == UserRole.volunteer;

    return AppScaffold(
      title: context.donors,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          children: [
            AppSearchBar(
              hint: context.searchDonorsHint,
              onChanged: (value) => ref
                  .read(donorListControllerProvider.notifier)
                  .updateSearch(value),
            ),
            const SizedBox(height: AppSpacing.space16),
            DonorStatusFilterChips(
              selectedStatus: state.status,
              onChanged: (status) => ref
                  .read(donorListControllerProvider.notifier)
                  .updateStatus(status),
            ),
            if (canManageDonors) ...[
              const SizedBox(height: AppSpacing.space16),
              AppButton(
                label: context.addDonorBtn,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DonorFormScreen()),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.space16),
            Expanded(
              child: donorsAsync.when(
                data: (donors) {
                  if (donors.isEmpty) {
                    return const AppEmptyState(
                      title: 'No donors found',
                      message: 'Try a different search or filter.',
                    );
                  }
                  return ListView.separated(
                    itemCount: donors.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.space8),
                    itemBuilder: (context, index) {
                      final donor = donors[index];
                      return DonorListItem(
                        donor: donor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DonorDetailScreen(donorId: donor.id),
                          ),
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
    );
  }
}
