import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../models/volunteer.dart';
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
    ref.watch(localeControllerProvider);
    final volunteerAsync = ref.watch(volunteerDetailProvider(volunteerId));
    final assignmentsAsync = ref.watch(volunteerAssignmentsProvider(volunteerId));
    final role = ref.watch(roleProvider);
    final textTheme = Theme.of(context).textTheme;
    final colors = context.authColors;

    final canManageVolunteers = role == UserRole.trustPresident ||
        role == UserRole.vicePresident ||
        role == UserRole.treasurer;

    final canViewSensitive = canManageVolunteers;

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
              // ── 1. Profile Overview Card ─────────────────────────────────
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
                    VolunteerTypeBadge(
                      type: volunteer.type,
                      customTypeLabel: volunteer.customTypeLabel,
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    _infoRow(context, 'Volunteer Code', volunteer.volunteerCode),
                    _infoRow(context, 'Email', volunteer.email ?? '—'),
                    _infoRow(
                      context,
                      'Mobile',
                      maskMobile(volunteer.mobile, canViewSensitive: canViewSensitive),
                    ),
                    if (volunteer.emergencyContact != null)
                      _infoRow(
                        context,
                        'Emergency Contact',
                        maskMobile(volunteer.emergencyContact!, canViewSensitive: canViewSensitive),
                      ),
                    if (volunteer.address != null)
                      _infoRow(context, 'Address', volunteer.address!),
                    _infoRow(
                      context,
                      'Preferred Language',
                      volunteer.preferredLanguage.toUpperCase(),
                    ),
                    _infoRow(
                      context,
                      'Joined On',
                      volunteer.joinedOn?.toLocal().toString().split(' ').first ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // ── 2. Collection Authority Status Card (Rule 224) ────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: volunteer.collectionAuthorityGranted
                      ? Colors.green.withValues(alpha: 0.1)
                      : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: volunteer.collectionAuthorityGranted
                        ? Colors.green.withValues(alpha: 0.4)
                        : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      volunteer.collectionAuthorityGranted
                          ? Icons.verified_user_rounded
                          : Icons.gpp_maybe_rounded,
                      color: volunteer.collectionAuthorityGranted
                          ? Colors.green
                          : colors.secondaryText,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.collectionAuthorityGranted
                                ? 'Collection Authority: GRANTED'
                                : 'Collection Authority: RESTRICTED',
                            style: TextStyle(
                              color: volunteer.collectionAuthorityGranted
                                  ? Colors.green
                                  : colors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            volunteer.collectionAuthorityGranted
                                ? 'Active event assignment & collection role confirmed.'
                                : 'Collection authority requires an active assignment + permissions.',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // ── 3. Identity Linkage Card (Requirement 218) ───────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.space16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      volunteer.hasLinkedUser ? Icons.link_rounded : Icons.link_off_rounded,
                      color: volunteer.hasLinkedUser ? colors.brandOrange : colors.secondaryText,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.hasLinkedUser
                                ? 'Linked Identity Account'
                                : 'No Identity Account Linked',
                            style: TextStyle(
                              color: colors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            volunteer.hasLinkedUser
                                ? 'User ID: ${volunteer.linkedUserId}'
                                : 'Independent volunteer record (optional login linkage).',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canManageVolunteers)
                      TextButton(
                        onPressed: () async {
                          if (volunteer.hasLinkedUser) {
                            await ref
                                .read(volunteerRepositoryProvider)
                                .unlinkUserIdentity(id: volunteer.id);
                          } else {
                            final userId = await _showLinkUserDialog(context);
                            if (userId != null && userId.isNotEmpty) {
                              await ref
                                  .read(volunteerRepositoryProvider)
                                  .linkUserIdentity(id: volunteer.id, userId: userId);
                            }
                          }
                          ref.invalidate(volunteerDetailProvider(volunteer.id));
                        },
                        child: Text(
                          volunteer.hasLinkedUser ? 'Unlink' : 'Link User',
                          style: TextStyle(
                            color: colors.brandOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space16),

              // ── 4. Lifecycle Action Buttons (Requirement 221) ─────────────
              if (canManageVolunteers)
                Row(
                  children: [
                    if (volunteer.status != VolunteerStatus.active)
                      Expanded(
                        child: AppButton(
                          label: volunteer.status == VolunteerStatus.suspended
                              ? 'Reactivate'
                              : 'Activate',
                          variant: AppButtonVariant.primary,
                          onPressed: () async {
                            final reason = volunteer.status == VolunteerStatus.suspended
                                ? await _showReasonDialog(context, title: 'Reactivation Reason')
                                : null;
                            if (volunteer.status == VolunteerStatus.suspended && reason == null) {
                              return;
                            }
                            await ref
                                .read(volunteerRepositoryProvider)
                                .activateVolunteer(id: volunteer.id, auditReason: reason);
                            ref.invalidate(volunteerDetailProvider(volunteer.id));
                          },
                        ),
                      ),
                    if (volunteer.status != VolunteerStatus.active)
                      const SizedBox(width: AppSpacing.space8),
                    if (volunteer.status == VolunteerStatus.active)
                      Expanded(
                        child: AppButton(
                          label: 'Suspend',
                          variant: AppButtonVariant.secondary,
                          onPressed: () async {
                            final reason = await _showReasonDialog(context, title: 'Suspension Reason');
                            if (reason != null && reason.isNotEmpty) {
                              await ref
                                  .read(volunteerRepositoryProvider)
                                  .suspendVolunteer(id: volunteer.id, reason: reason);
                              ref.invalidate(volunteerDetailProvider(volunteer.id));
                            }
                          },
                        ),
                      ),
                    if (volunteer.status == VolunteerStatus.active)
                      const SizedBox(width: AppSpacing.space8),
                    if (volunteer.status == VolunteerStatus.active ||
                        volunteer.status == VolunteerStatus.suspended)
                      Expanded(
                        child: AppButton(
                          label: 'Deactivate',
                          variant: AppButtonVariant.secondary,
                          onPressed: () async {
                            final reason = await _showReasonDialog(context, title: 'Deactivation Reason');
                            if (reason != null && reason.isNotEmpty) {
                              await ref
                                  .read(volunteerRepositoryProvider)
                                  .deactivateVolunteer(id: volunteer.id, reason: reason);
                              ref.invalidate(volunteerDetailProvider(volunteer.id));
                            }
                          },
                        ),
                      ),
                  ],
                ),
              if (canManageVolunteers) const SizedBox(height: AppSpacing.space16),

              // ── 5. Assignments Section ────────────────────────────────────
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
                                builder: (_) => _AssignmentDialog(volunteerId: volunteer.id),
                              );
                              if (newAssignment != null) {
                                await ref.read(volunteerRepositoryProvider).addAssignment(
                                      volunteerId: volunteer.id,
                                      roleCode: newAssignment.roleCode,
                                      scopeType: newAssignment.scopeType,
                                      scopeLabel: newAssignment.scopeLabel,
                                      startsAt: newAssignment.startsAt,
                                      endsAt: newAssignment.endsAt,
                                      status: newAssignment.status,
                                    );
                                ref.invalidate(volunteerAssignmentsProvider(volunteer.id));
                                ref.invalidate(volunteerDetailProvider(volunteer.id));
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
                                      color: colors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                assignment.roleCode,
                                                style: textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Scope: ${assignment.scopeType.label} (${assignment.scopeLabel})',
                                                style: TextStyle(
                                                  color: colors.secondaryText,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: assignment.status ==
                                                    VolunteerAssignmentStatus.active
                                                ? colors.brandOrange.withValues(alpha: 0.15)
                                                : colors.surfaceMuted,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            assignment.status.label,
                                            style: TextStyle(
                                              color: assignment.status ==
                                                      VolunteerAssignmentStatus.active
                                                  ? colors.brandOrange
                                                  : colors.secondaryText,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
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
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showReasonDialog(BuildContext context, {required String title}) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for Audit Log',
            hintText: 'Enter mandatory explanation...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Confirm',
            fullWidth: false,
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
        ],
      ),
    );
  }

  Future<String?> _showLinkUserDialog(BuildContext context) async {
    final controller = TextEditingController(text: 'user-auth-${DateTime.now().millisecondsSinceEpoch % 1000}');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link Identity User Account'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'User UUID / Account ID',
            hintText: 'Enter verified user identity ID...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Link Account',
            fullWidth: false,
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

class _AssignmentDialog extends StatefulWidget {
  const _AssignmentDialog({required this.volunteerId});

  final String volunteerId;

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  final _scopeLabelController = TextEditingController();
  final _scopeRefIdController = TextEditingController();

  String _roleCode = 'Donation Collector';
  AssignmentScopeType _scopeType = AssignmentScopeType.area;
  VolunteerAssignmentStatus _status = VolunteerAssignmentStatus.active;
  DateTime _startsAt = DateTime.now();
  DateTime? _endsAt;

  final List<String> _roleOptions = const [
    'Donation Collector',
    'Event Coordinator',
    'Finance Volunteer',
    'Decoration Lead',
    'Food Distribution',
    'Crowd Control',
    'General Support',
    'Custom Role',
  ];

  @override
  void dispose() {
    _scopeLabelController.dispose();
    _scopeRefIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Volunteer Assignment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _roleCode,
              decoration: const InputDecoration(labelText: 'Role Code / Duty'),
              items: _roleOptions
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (val) => setState(() => _roleCode = val ?? _roleCode),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AssignmentScopeType>(
              initialValue: _scopeType,
              decoration: const InputDecoration(labelText: 'Scope Type'),
              items: AssignmentScopeType.values
                  .map((scope) => DropdownMenuItem(value: scope, child: Text(scope.label)))
                  .toList(),
              onChanged: (val) => setState(() => _scopeType = val ?? _scopeType),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _scopeLabelController,
              decoration: const InputDecoration(
                labelText: 'Scope Label',
                hintText: 'e.g. Area 3, Ward B or Book #2',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VolunteerAssignmentStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: VolunteerAssignmentStatus.values
                  .map((st) => DropdownMenuItem(value: st, child: Text(st.label)))
                  .toList(),
              onChanged: (val) => setState(() => _status = val ?? _status),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Date'),
              subtitle: Text(_startsAt.toLocal().toString().split(' ').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startsAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _startsAt = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: 'Save Assignment',
          fullWidth: false,
          onPressed: () {
            Navigator.pop(
              context,
              VolunteerAssignment(
                id: '',
                volunteerId: widget.volunteerId,
                roleCode: _roleCode,
                scopeType: _scopeType,
                scopeLabel: _scopeLabelController.text.trim().isEmpty
                    ? 'General Scope'
                    : _scopeLabelController.text.trim(),
                startsAt: _startsAt,
                endsAt: _endsAt,
                status: _status,
              ),
            );
          },
        ),
      ],
    );
  }
}
