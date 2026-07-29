import 'package:flutter/material.dart';

import '../core/core.dart';
import '../shared/shared.dart';
import '../features/donors/screens/donor_list_screen.dart';
import '../features/vendors/screens/vendor_list_screen.dart';
import '../features/volunteers/screens/volunteer_list_screen.dart';
import '../features/sponsorship_advertisement/screens/sponsorship_list_screen.dart';
import '../features/sponsorship_advertisement/screens/advertisement_list_screen.dart';

class AllRecordsScreen extends StatelessWidget {
  const AllRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: 'All Records',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        children: [
          Text(
            'Browse by category',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.mutedTextFor(context),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          _RecordCategoryCard(
            icon: Icons.handshake_outlined,
            label: 'Sponsors',
            description: 'Tiered sponsorship records with pledge & confirmation lifecycle',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SponsorshipListScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          _RecordCategoryCard(
            icon: Icons.campaign_outlined,
            label: 'Advertisements',
            description: 'Placement bookings and space advertisement records',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdvertisementListScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          _RecordCategoryCard(
            icon: Icons.people_alt_outlined,
            label: 'Donors',
            description: 'Contributor accounts with contribution history',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DonorListScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          _RecordCategoryCard(
            icon: Icons.volunteer_activism_outlined,
            label: 'Volunteers',
            description: 'Volunteer assignments and field worker records',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VolunteerListScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          _RecordCategoryCard(
            icon: Icons.store_outlined,
            label: 'Vendors',
            description: 'Vendor bills, expense tracking, and contract records',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VendorListScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCategoryCard extends StatelessWidget {
  const _RecordCategoryCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? primary.withValues(alpha: 0.12)
        : primary.withValues(alpha: 0.06);
    final borderColor = primary.withValues(alpha: isDark ? 0.3 : 0.18);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedTextFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedTextFor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
