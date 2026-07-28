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
    final listState = ref.watch(volunteerListControllerProvider);
    final volunteersAsync = ref.watch(volunteerListProvider);
    final role = ref.watch(roleProvider);

    final canManageVolunteers = role == Role.secretary || role == Role.treasurer || role == Role.president || role == Role.owner;

    return AppScaffold(
      title: 'Volunteers',
      actions: [
        if (canManageVolunteers)
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VolunteerFormScreen()),
            ),
            icon: const Icon(Icons.add),
          ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: AppSearchBar(
              hint: 'Search volunteers',
              onChanged: (value) => ref.read(volunteerListControllerProvider.notifier).updateSearch(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<VolunteerStatus?>(
                    value: listState.status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      for (final status in VolunteerStatus.values)
                        DropdownMenuItem(value: status, child: Text(_statusLabel(status))),
                    ],
                    onChanged: (value) => ref.read(volunteerListControllerProvider.notifier).updateStatus(value),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<VolunteerType?>(
                    value: listState.type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      for (final type in VolunteerType.values)
                        DropdownMenuItem(value: type, child: Text(type.label)),
                    ],
                    onChanged: (value) => ref.read(volunteerListControllerProvider.notifier).updateType(value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: volunteersAsync.when(
              data: (volunteers) {
                if (volunteers.isEmpty) {
                  return const AppEmptyState(title: 'No volunteers found');
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(volunteerListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: volunteers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final volunteer = volunteers[index];
                      final canViewSensitive = role == Role.owner || role == Role.president || role == Role.secretary;
                      return AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Expanded(child: Text(volunteer.fullName, style: AppTypography.titleMedium(context))),
                              VolunteerStatusBadge(status: volunteer.status),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  VolunteerTypeBadge(type: volunteer.type, customTypeLabel: volunteer.customTypeLabel),
                                  const SizedBox(width: AppSpacing.sm),
                                  if (volunteer.currentAssignmentSummary != null)
                                    Expanded(
                                      child: Text(
                                        volunteer.currentAssignmentSummary!,
                                        style: AppTypography.bodySmall(context),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text('Code: ${volunteer.volunteerCode}'),
                              Text('Mobile: ${maskMobile(volunteer.mobile, canViewSensitive: canViewSensitive)}'),
                              Text('Assignments: ${volunteer.activeAssignmentCount} active'),
                            ],
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => VolunteerDetailScreen(volunteerId: volunteer.id)),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const AppLoadingIndicator(label: 'Loading volunteers...'),
              error: (error, stackTrace) => AppErrorView(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(VolunteerStatus status) {
    return switch (status) {
      VolunteerStatus.active => 'Active',
      VolunteerStatus.draft => 'Draft',
      VolunteerStatus.suspended => 'Suspended',
      VolunteerStatus.inactive => 'Inactive',
    };
  }
}
