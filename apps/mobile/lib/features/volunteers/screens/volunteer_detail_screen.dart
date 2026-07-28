import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../models/volunteer_assignment.dart';
import '../providers/volunteer_providers.dart';
import '../widgets/volunteer_status_badge.dart';
import '../widgets/volunteer_type_badge.dart';
import 'volunteer_form_screen.dart';

class VolunteerDetailScreen extends ConsumerWidget {
  const VolunteerDetailScreen({super.key, required this.volunteerId});

  final String volunteerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteerAsync = ref.watch(volunteerDetailProvider(volunteerId));
    final assignmentsAsync =
        ref.watch(volunteerAssignmentsProvider(volunteerId));
    final role = ref.watch(roleProvider);
    final canManageVolunteers = role == Role.secretary ||
        role == Role.treasurer ||
        role == Role.president ||
        role == Role.owner;
    final canViewSensitive =
        role == Role.owner || role == Role.president || role == Role.secretary;

    return AppScaffold(
      title: 'Volunteer Details',
      body: volunteerAsync.when(
        data: (volunteer) {
          if (volunteer == null) {
            return const AppEmptyState(title: 'Volunteer not found');
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(volunteer.fullName,
                                style: AppTypography.display(context))),
                        VolunteerStatusBadge(status: volunteer.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    VolunteerTypeBadge(type: volunteer.type),
                    const SizedBox(height: AppSpacing.md),
                    _infoRow(context, 'Code', volunteer.volunteerCode),
                    _infoRow(context, 'Email', volunteer.email ?? '—'),
                    _infoRow(
                        context,
                        'Mobile',
                        maskMobile(volunteer.mobile,
                            canViewSensitive: canViewSensitive)),
                    _infoRow(context, 'Preferred language',
                        volunteer.preferredLanguage.toUpperCase()),
                    _infoRow(
                        context,
                        'Joined on',
                        volunteer.joinedOn
                                ?.toLocal()
                                .toString()
                                .split(' ')
                                .first ??
                            '—'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Assignments',
                            style: AppTypography.titleMedium(context)),
                        const Spacer(),
                        if (canManageVolunteers)
                          AppButton(
                            label: 'Add assignment',
                            variant: AppButtonVariant.secondary,
                            onPressed: () async {
                              final newAssignment =
                                  await showDialog<VolunteerAssignment>(
                                context: context,
                                builder: (_) => const _AssignmentDialog(),
                              );
                              if (newAssignment != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Assignment added (mock)')),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    assignmentsAsync.when(
                      data: (assignments) {
                        if (assignments.isEmpty) {
                          return const AppEmptyState(
                              title: 'No assignments yet');
                        }
                        return Column(
                          children: assignments
                              .map(
                                (assignment) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(assignment.roleCode,
                                                  style:
                                                      AppTypography.titleMedium(
                                                          context)),
                                              Text(
                                                  '${assignment.scopeType}: ${assignment.scopeLabel}'),
                                            ],
                                          ),
                                        ),
                                        Text(assignment.assignmentStatus),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const AppLoadingIndicator(
                          label: 'Loading assignments...'),
                      error: (error, stackTrace) =>
                          AppErrorView(message: error.toString()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (canManageVolunteers)
                AppButton(
                  label: 'Edit volunteer',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            VolunteerFormScreen(volunteerId: volunteer.id)),
                  ),
                ),
            ],
          );
        },
        loading: () => const AppLoadingIndicator(label: 'Loading volunteer...'),
        error: (error, stackTrace) => AppErrorView(message: error.toString()),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label, style: AppTypography.label(context))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _AssignmentDialog extends StatefulWidget {
  const _AssignmentDialog();

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  final _roleController = TextEditingController();
  final _scopeController = TextEditingController();
  final _scopeLabelController = TextEditingController();
  final _statusController = TextEditingController(text: 'active');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Assignment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role code')),
          TextField(
              controller: _scopeController,
              decoration: const InputDecoration(labelText: 'Scope type')),
          TextField(
              controller: _scopeLabelController,
              decoration: const InputDecoration(labelText: 'Scope label')),
          TextField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Status')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        AppButton(
          label: 'Save',
          onPressed: () {
            Navigator.pop(
              context,
              VolunteerAssignment(
                id: '',
                volunteerId: '',
                roleCode: _roleController.text,
                scopeType: _scopeController.text,
                scopeLabel: _scopeLabelController.text,
                startsAt: DateTime.now(),
                assignmentStatus: _statusController.text,
              ),
            );
          },
        ),
      ],
    );
  }
}
