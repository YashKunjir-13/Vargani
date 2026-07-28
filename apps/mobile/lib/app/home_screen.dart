import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core.dart';
import '../features/donors/screens/donor_list_screen.dart';
import '../features/sponsorship_advertisement/screens/sponsorship_advertisement_screen.dart';
import '../features/vendors/screens/vendor_list_screen.dart';
import '../features/volunteers/screens/volunteer_list_screen.dart';
import '../shared/shared.dart';

/// Temporary dashboard landing screen for the module foundation.
/// TODO: replace with the real dashboard once that shell exists.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(roleProvider);

    return AppScaffold(
      title: 'Pauti Pustak',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Multi-tenant Event Financial-Management',
                style: AppTypography.display(context)),
            const SizedBox(height: AppSpacing.sm),
            Text('Enterprise Foundation Ready',
                style: AppTypography.caption(context,
                    color: AppColors.mutedTextFor(context))),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<Role>(
              value: currentRole,
              decoration: const InputDecoration(
                labelText: 'Acting Role (RBAC Simulation)',
                prefixIcon: Icon(Icons.admin_panel_settings_outlined),
              ),
              items: Role.values
                  .map(
                    (role) => DropdownMenuItem<Role>(
                      value: role,
                      child: Text(role.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(roleProvider.notifier).setRole(value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              title: 'Sponsorship & Advertisement',
              subtitle:
                  'Manage tiered sponsors, pledged/confirmed stats, and advertisement placement bookings',
              child: AppButton(
                label: 'Open Sponsorship & Advertisement',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SponsorshipAdvertisementScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              title: 'Donors',
              subtitle: 'Search, filter, create, and review donor profiles',
              child: AppButton(
                label: 'Open Donor Module',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DonorListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              title: 'Vendors',
              subtitle:
                  'Review vendor balances, search, and manage vendor profiles',
              child: AppButton(
                label: 'Open Vendor Module',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VendorListScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              title: 'Volunteers',
              subtitle: 'Manage volunteer profiles, assignments, and masked contact details',
              child: AppButton(
                label: 'Open Volunteer Module',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VolunteerListScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

