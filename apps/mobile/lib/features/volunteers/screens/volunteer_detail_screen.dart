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
    final assignmentsAsync = ref.watch(volunteerAssignmentsProvider(volunteerId));
    final role = ref.watch(roleProvider);
    final textTheme = Theme.of(context).textTheme;

    // trustPresident, vicePresident, treasurer can manage volunteers
    final canManageVolunteers = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    // sensitive data (full mobile) visible only to trustPresident, vicePresident, treasurer
    final canViewSensitive = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    return AppScaffold(
      title: 'Volunteer Details',
      body: volunteerAsync.when(
        data: (volunteer) {
          if (volunteer == null) {
            return const AppEmptyState(title: 'Volunteer not found');
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.space24),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(volunteer.fullName, style: textTheme.headlineMedium),
                        ),
                        VolunteerStatusBadge(status: volunteer.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    VolunteerTypeBadge(type: volunteer.type),
                    const SizedBox(height: AppSpacing.space16),
                    _infoRow(context, 'Code', volunteer.volunteerCode),
                    _infoRow(context, 'Email', volunteer.email ?? '—'),
                    _infoRow(
                      context,
                      'Mobile',
                      maskMobile(volunteer.mobile, canViewSensitive: canViewSensitive),
                    ),
                    _infoRow(
                      context,
                      'Preferred language',
                      volunteer.preferredLanguage.toUpperCase(),
                    ),
                    _infoRow(
                      context,
                      'Joined on',
                      volunteer.joinedOn?.toLocal().toString().split(' ').first ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Assignments', style: textTheme.titleMedium),
                        const Spacer(),
                        if (canManageVolunteers)
                          AppButton(
                            label: 'Add assignment',
                            variant: AppButtonVariant.secondary,
                            fullWidth: false,
                            onPressed: () async {
                              final newAssignment = await showDialog<VolunteerAssignment>(
                                context: context,
                                builder: (_) => const _AssignmentDialog(),
                              );
                              if (newAssignment != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Assignment added (mock)')),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    assignmentsAsync.when(
                      data: (assignments) {
                        if (assignments.isEmpty) {
                          return const AppEmptyState(title: 'No assignments yet');
                        }
                        return Column(
                          children: assignments
                              .map(
                                (assignment) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSpacing.space16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(assignment.roleCode, style: textTheme.titleMedium),
                                              Text('${assignment.scopeType}: ${assignment.scopeLabel}'),
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
                      loading: () => const AppLoadingIndicator(label: 'Loading assignments...'),
                      error: (error, stackTrace) => AppErrorView(message: error.toString()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              if (canManageVolunteers)
                AppButton(
                  label: 'Edit volunteer',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VolunteerFormScreen(volunteerId: volunteer.id),
                    ),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
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
          TextField(controller: _roleController, decoration: const InputDecoration(labelText: 'Role code')),
          TextField(controller: _scopeController, decoration: const InputDecoration(labelText: 'Scope type')),
          TextField(controller: _scopeLabelController, decoration: const InputDecoration(labelText: 'Scope label')),
          TextField(controller: _statusController, decoration: const InputDecoration(labelText: 'Status')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        AppButton(
          label: 'Save',
          fullWidth: false,
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
