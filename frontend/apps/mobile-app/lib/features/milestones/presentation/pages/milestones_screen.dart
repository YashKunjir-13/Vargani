import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../../../rbac/presentation/providers/mock_rbac_provider.dart';
import '../../../rbac/presentation/pages/user_management_screen.dart';
import '../providers/milestone_providers.dart';
import '../../data/models/milestone_model.dart';
import 'milestone_form_screen.dart';
import 'milestone_details_screen.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final rbacState = ref.watch(mockRbacProvider);
    final users = ref.watch(mockUserListProvider);
    final milestones = ref.watch(milestoneListProvider);

    final total = milestones.length;
    final inProgress = milestones.where((m) => m.status == 'In Progress').length;
    final pending = milestones.where((m) => m.status == 'Pending').length;
    final completed = milestones.where((m) => m.status == 'Completed').length;

    final canCreate = rbacState.hasPermission('milestones.create');
    final isVolunteer = !rbacState.hasPermission('milestones.view') && rbacState.hasPermission('milestones.view_assigned');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isVolunteer ? 'My Assigned Work' : 'Milestones & Work',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MilestoneFormScreen()),
                );
              },
              backgroundColor: colors.brandOrange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryCard('Total', '$total', Icons.assignment, colors, Colors.blue),
                  const SizedBox(width: 12),
                  _buildSummaryCard('In Progress', '$inProgress', Icons.sync, colors, Colors.orange),
                  const SizedBox(width: 12),
                  _buildSummaryCard('Pending', '$pending', Icons.hourglass_empty, colors, Colors.grey),
                  const SizedBox(width: 12),
                  _buildSummaryCard('Completed', '$completed', Icons.check_circle, colors, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              isVolunteer ? 'ASSIGNED TASKS' : 'ALL MILESTONES',
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            if (milestones.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No milestones found.',
                    style: TextStyle(color: colors.secondaryText, fontSize: 16),
                  ),
                ),
              )
            else
              ...milestones.map((m) => _buildMilestoneCard(context, m, colors, users)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, AuthColors colors, Color accentColor) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, MockMilestone m, AuthColors colors, List<MockUser> users) {
    Color statusColor;
    switch (m.status) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Pending':
      default:
        statusColor = Colors.grey;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MilestoneDetailsScreen(milestone: m)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    m.title,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    m.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              m.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.person, size: 16, color: colors.secondaryText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              users.where((u) => u.id == m.assignedToUserId).firstOrNull?.name ?? m.assignedToUserName ?? 'Unassigned',
                              style: TextStyle(
                                color: colors.secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (users.any((u) => u.id == m.assignedToUserId))
                              Text(
                                users.firstWhere((u) => u.id == m.assignedToUserId).role.displayName,
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
                Text(
                  '${m.progressPercentage}% Complete',
                  style: TextStyle(
                    color: colors.brandOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: m.progressPercentage / 100.0,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.brandOrange),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
