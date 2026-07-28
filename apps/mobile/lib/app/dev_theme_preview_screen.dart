import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core.dart';
import '../shared/shared.dart';

class DevThemePreviewScreen extends ConsumerWidget {
  const DevThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themeProvider);
    final language = ref.watch(localeProvider);
    final currentRole = ref.watch(roleProvider);

    return AppScaffold(
      title: 'Design System Preview',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme & Shared UI Foundation',
                style: AppTypography.display(context)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Previewing the foundation in ${themePreference.name} mode and active locale ${language.name.toUpperCase()} with role ${currentRole.name}',
              style: AppTypography.caption(context,
                  color: AppColors.mutedTextFor(context)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                const AppButton(
                    label: '+ Add Sponsor', icon: Icons.add_circle_outline),
                const AppButton(
                    label: 'Secondary',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.info_outline),
                const AppButton(label: 'Text', variant: AppButtonVariant.text),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                    child: AppSummaryStatCard(
                        label: 'Total Vendors', value: '12')),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: AppSummaryStatCard(
                        label: 'Outstanding',
                        value: '₹1.53L',
                        valueColor: AppColors.lightError)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                const AppStatusBadge(
                    label: 'Active', status: AppStatus.success),
                const AppStatusBadge(
                    label: 'Pending', status: AppStatus.pending),
                const AppStatusBadge(
                    label: 'Warning', status: AppStatus.warning),
                const AppStatusBadge(label: 'Error', status: AppStatus.error),
                const AppStatusBadge(label: 'Info', status: AppStatus.info),
                const AppStatusBadge(
                    label: 'Neutral', status: AppStatus.neutral),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              title: 'Ganpati Utsav Committee',
              subtitle: 'Donation drive • 4 sponsors pledged',
              trailing: const AppStatusBadge(
                  label: 'Confirmed', status: AppStatus.success),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹18,500', style: AppTypography.titleMedium(context)),
                  Text('Amount',
                      style: AppTypography.caption(context,
                          color: AppColors.mutedTextFor(context))),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppListItemCard(
              title: 'Rajat Sharma',
              subtitle: 'Vendor • Catering',
              amount: '₹12,000',
              status: AppStatus.pending,
            ),
            const SizedBox(height: AppSpacing.lg),
            const AppTextField(
                label: 'Committee Name',
                hint: 'Enter a name',
                prefixIcon: Icons.person_outline),
            const SizedBox(height: AppSpacing.lg),
            const AppSearchBar(hint: 'Search sponsors'),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<Role>(
              initialValue: currentRole,
              decoration: const InputDecoration(labelText: 'Acting as'),
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
            const SizedBox(height: AppSpacing.lg),
            const RoleGate(
              allowedRoles: [Role.treasurer],
              child: AppCard(
                title: 'Treasurer-only panel',
                subtitle: 'Visible only for Treasurer',
                child: Text(
                    'This area is hidden unless the role gate permits it.'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppEmptyState(
              title: 'No advertisements yet',
              message: 'Add a booked placement once the event is ready.',
              action: const AppButton(
                  label: '+ Book Advertisement',
                  icon: Icons.add_circle_outline),
            ),
            const SizedBox(height: AppSpacing.xl),
            const AppLoadingIndicator(label: 'Loading preview...'),
            const SizedBox(height: AppSpacing.xl),
            const AppErrorView(message: 'A preview error occurred.'),
          ],
        ),
      ),
      floatingActionButton: AppFab(label: 'Add', onPressed: () {}),
    );
  }
}
