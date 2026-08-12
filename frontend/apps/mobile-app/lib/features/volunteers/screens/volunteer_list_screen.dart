import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../models/volunteer.dart';
import '../providers/volunteer_providers.dart';
import '../widgets/volunteer_status_badge.dart';
import '../widgets/volunteer_type_badge.dart';
import 'volunteer_detail_screen.dart';
import 'volunteer_form_screen.dart';

class VolunteerListScreen extends ConsumerWidget {
  const VolunteerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeControllerProvider);
    final listState = ref.watch(volunteerListControllerProvider);
    final volunteersAsync = ref.watch(volunteerListProvider);
    final role = ref.watch(roleProvider);
    final textTheme = Theme.of(context).textTheme;

    final canManageVolunteers = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    return AppScaffold(
      title: context.volunteers,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space24,
              AppSpacing.space16,
              AppSpacing.space24,
              AppSpacing.space8,
            ),
            child: AppSearchBar(
              hint: context.searchVolunteersHint,
              onChanged: (value) => ref
                  .read(volunteerListControllerProvider.notifier)
                  .updateSearch(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<VolunteerStatus?>(
                    isExpanded: true,
                    initialValue: listState.status,
                    decoration: InputDecoration(labelText: context.statusLabel),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(context.allLabel,
                            overflow: TextOverflow.ellipsis),
                      ),
                      for (final status in VolunteerStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(
                            _statusLabel(status, context.languageCode),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => ref
                        .read(volunteerListControllerProvider.notifier)
                        .updateStatus(value),
                  ),
                ),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: DropdownButtonFormField<VolunteerType?>(
                    isExpanded: true,
                    initialValue: listState.type,
                    decoration: InputDecoration(labelText: context.typeLabel),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(context.allLabel,
                            overflow: TextOverflow.ellipsis),
                      ),
                      for (final type in VolunteerType.values)
                        DropdownMenuItem(
                          value: type,
                          child:
                              Text(type.label, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (value) => ref
                        .read(volunteerListControllerProvider.notifier)
                        .updateType(value),
                  ),
                ),
              ],
            ),
          ),
          if (canManageVolunteers)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space24,
                AppSpacing.space16,
                AppSpacing.space24,
                0,
              ),
              child: AppButton(
                label: context.l10n.addVolunteer,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const VolunteerFormScreen()),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.space8),
          Expanded(
            child: volunteersAsync.when(
              data: (volunteers) {
                if (volunteers.isEmpty) {
                  return const AppEmptyState(title: 'No volunteers found');
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(volunteerListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.space24),
                    itemCount: volunteers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.space16),
                    itemBuilder: (context, index) {
                      final volunteer = volunteers[index];
                      final canViewSensitive =
                          role == UserRole.trustPresident ||
                              role == UserRole.vicePresident ||
                              role == UserRole.treasurer;
                      return AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  volunteer.fullName,
                                  style: textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.space8),
                              VolunteerStatusBadge(status: volunteer.status),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.space8),
                              Wrap(
                                spacing: AppSpacing.space8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  VolunteerTypeBadge(
                                    type: volunteer.type,
                                    customTypeLabel: volunteer.customTypeLabel,
                                  ),
                                  if (volunteer.currentAssignmentSummary !=
                                      null)
                                    Text(
                                      volunteer.currentAssignmentSummary!,
                                      style: textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.space8),
                              Text('Code: ${volunteer.volunteerCode}'),
                              Text(
                                'Mobile: ${maskMobile(volunteer.mobile, canViewSensitive: canViewSensitive)}',
                              ),
                              Text(
                                'Assignments: ${volunteer.activeAssignmentCount} active',
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VolunteerDetailScreen(
                                  volunteerId: volunteer.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading volunteers...'),
              error: (error, stackTrace) =>
                  AppErrorView(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(VolunteerStatus status, String code) {
    return switch (status) {
      VolunteerStatus.active => code == 'hi'
          ? 'सक्रिय'
          : code == 'mr'
              ? 'सक्रिय'
              : 'Active',
      VolunteerStatus.draft => code == 'hi'
          ? 'ड्राफ्ट'
          : code == 'mr'
              ? 'मसुदा'
              : 'Draft',
      VolunteerStatus.suspended => code == 'hi'
          ? 'निलंबित'
          : code == 'mr'
              ? 'निलंबित'
              : 'Suspended',
      VolunteerStatus.inactive => code == 'hi'
          ? 'निष्क्रिय'
          : code == 'mr'
              ? 'निष्क्रिय'
              : 'Inactive',
    };
  }
}
