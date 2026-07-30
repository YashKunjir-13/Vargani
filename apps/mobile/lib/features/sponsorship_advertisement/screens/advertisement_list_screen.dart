import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../shared/shared.dart';
import '../providers/advertisement_providers.dart';
import '../widgets/advertisement_list_item.dart';
import 'advertisement_detail_screen.dart';
import 'advertisement_form_screen.dart';

class AdvertisementListScreen extends ConsumerWidget {
  const AdvertisementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeControllerProvider);
    final adsAsync = ref.watch(advertisementListProvider);
    final role = ref.watch(roleProvider);

    final canManage = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    return AppScaffold(
      title: context.advertisements,
      body: adsAsync.when(
        data: (ads) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(advertisementListProvider),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.space24),
              children: [
                AppSearchBar(
                  hint: context.searchAdsHint,
                  onChanged: (value) => ref
                      .read(advertisementListControllerProvider.notifier)
                      .updateSearch(value),
                ),
                const SizedBox(height: AppSpacing.space16),
                if (canManage)
                  AppButton(
                    label: context.bookAdBtn,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AdvertisementFormScreen()),
                    ),
                  ),
                if (canManage) const SizedBox(height: AppSpacing.space16),
                if (ads.isEmpty)
                  const AppEmptyState(
                    title: 'No advertisements booked',
                    message: 'Try a different search or book a new placement.',
                  )
                else
                  ...ads.map(
                    (ad) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                      child: AdvertisementListItem(
                        advertisement: ad,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AdvertisementDetailScreen(advertisementId: ad.id),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () =>
            const AppLoadingIndicator(label: 'Loading advertisements...'),
        error: (e, _) => AppErrorView(message: e.toString()),
      ),
    );
  }
}
