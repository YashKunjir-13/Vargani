import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../../../rbac/presentation/providers/mock_rbac_provider.dart';
import '../../../rbac/presentation/pages/user_management_screen.dart';
import '../../data/models/milestone_model.dart';
import '../providers/milestone_providers.dart';
import 'milestone_form_screen.dart';

class MilestoneDetailsScreen extends ConsumerStatefulWidget {
  final MockMilestone milestone;

  const MilestoneDetailsScreen({super.key, required this.milestone});

  @override
  ConsumerState<MilestoneDetailsScreen> createState() =>
      _MilestoneDetailsScreenState();
}

class _MilestoneDetailsScreenState
    extends ConsumerState<MilestoneDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final rbacState = ref.watch(mockRbacProvider);
    final users = ref.watch(mockUserListProvider);
    final allMilestones = ref.watch(milestoneListProvider);

    // Find the latest instance of this milestone from the provider
    final currentMilestone =
        allMilestones.where((m) => m.id == widget.milestone.id).firstOrNull ??
            widget.milestone;

    final canUpdate = rbacState.hasPermission('milestones.update');
    final canUpdateAssigned =
        rbacState.hasPermission('milestones.update_assigned') &&
            (currentMilestone.assignedToUserName == rbacState.testingUserName ||
                rbacState.activeRole == MockRole.volunteer);

    final canEditMilestone = canUpdate ||
        (canUpdateAssigned &&
            currentMilestone.assignedToUserName == rbacState.testingUserName);

    final canManageFinancials =
        rbacState.hasPermission('milestones.manage_financials');

    Color statusColor;
    switch (currentMilestone.status) {
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Milestone Details',
          style: TextStyle(
              color: colors.text, fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          if (canEditMilestone)
            IconButton(
              icon: Icon(Icons.edit, color: colors.brandOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MilestoneFormScreen(
                          existingMilestone: currentMilestone)),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentMilestone.title,
                    style: TextStyle(
                        color: colors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentMilestone.status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${currentMilestone.calculatedProgress}% Complete',
                        style: TextStyle(
                            color: colors.brandOrange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: currentMilestone.calculatedProgress / 100.0,
                    backgroundColor: colors.border,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colors.brandOrange),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('WORK DETAILS', colors),
            _buildCardContainer(
              colors,
              Column(
                children: [
                  _buildInfoRow(
                      'Description', currentMilestone.description, colors),
                  _buildInfoRow('Category', currentMilestone.category, colors),
                  _buildInfoRow('Priority', currentMilestone.priority, colors),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('TIMELINE', colors),
            _buildCardContainer(
              colors,
              Column(
                children: [
                  _buildInfoRow('Start Date',
                      _formatDate(currentMilestone.startDate), colors),
                  _buildInfoRow('Due Date',
                      _formatDate(currentMilestone.dueDate), colors),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('RESPONSIBILITY', colors),
            _buildCardContainer(
              colors,
              Column(
                children: [
                  _buildUserDetailRow(
                      'Assigned Coordinator',
                      currentMilestone.assignedToUserId,
                      currentMilestone.assignedToUserName ?? 'Unassigned',
                      users,
                      colors),
                  _buildUserDetailRow(
                      'Assigned By',
                      currentMilestone.assignedByUserId,
                      currentMilestone.assignedByUserName ?? 'System',
                      users,
                      colors),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (currentMilestone.workItems.isNotEmpty) ...[
              _buildSectionHeader('WORK ITEMS', colors),
              _buildCardContainer(
                colors,
                Column(
                  children: currentMilestone.workItems.map((wi) {
                    final assignedUser = users
                        .where((u) => u.id == wi.assignedToUserId)
                        .firstOrNull;

                    bool canUpdateThisWorkItem = canUpdate ||
                        (rbacState
                                .hasPermission('milestones.update_assigned') &&
                            (assignedUser?.id == rbacState.testingUserId));
                    // Check volunteer filtering: volunteer should only see their own work items, UNLESS they are assigned the whole milestone.
                    // Actually, the provider already filters milestones. Here we should filter out work items they aren't assigned to IF they are a volunteer and NOT the milestone coordinator.
                    bool isCoordinator = currentMilestone.assignedToUserId ==
                        rbacState.testingUserId;
                    bool isGlobalView =
                        rbacState.hasPermission('milestones.view');

                    if (!isGlobalView &&
                        !isCoordinator &&
                        assignedUser?.id != rbacState.testingUserId) {
                      return const SizedBox
                          .shrink(); // Hide work items they don't own
                    }

                    IconData statusIcon = Icons.radio_button_unchecked;
                    Color wiStatusColor = colors.secondaryText;
                    if (wi.status == 'Completed') {
                      statusIcon = Icons.check_circle;
                      wiStatusColor = Colors.green;
                    } else if (wi.status == 'In Progress') {
                      statusIcon = Icons.refresh;
                      wiStatusColor = colors.brandOrange;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(statusIcon, color: wiStatusColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(wi.title,
                                    style: TextStyle(
                                        color: colors.text,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(assignedUser?.name ?? 'Unassigned',
                                    style: TextStyle(
                                        color: colors.secondaryText,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: wi.progress / 100,
                                        backgroundColor: colors.border,
                                        color: wiStatusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${wi.progress}%',
                                        style: TextStyle(
                                            color: colors.secondaryText,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (canUpdateThisWorkItem)
                            IconButton(
                              icon: Icon(Icons.edit,
                                  color: colors.brandOrange, size: 20),
                              onPressed: () => _showUpdateProgressSheet(
                                  wi, currentMilestone, colors),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Financial Data Security Gating
            if (canManageFinancials) ...[
              _buildSectionHeader('FINANCIAL DETAILS', colors),
              _buildCardContainer(
                colors,
                Column(
                  children: [
                    _buildInfoRow(
                        'Estimated Budget',
                        _formatCurrency(currentMilestone.estimatedCostPaise),
                        colors),
                    _buildInfoRow(
                        'Actual Cost',
                        _formatCurrency(currentMilestone.actualCostPaise),
                        colors),
                    _buildUserDetailRow(
                        'Payment Responsible',
                        currentMilestone.paymentResponsibleUserId,
                        currentMilestone.paymentResponsibleUserName ??
                            'Unassigned',
                        users,
                        colors),
                    _buildInfoRow('Payment Status',
                        currentMilestone.paymentRequestStatus, colors),
                    if (currentMilestone.paymentReference != null)
                      _buildInfoRow('Payment Reference',
                          currentMilestone.paymentReference!, colors),
                    if (currentMilestone.paymentDate != null)
                      _buildInfoRow('Payment Date',
                          _formatDate(currentMilestone.paymentDate), colors),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('PAYMENT WORKFLOW', colors),
              _buildCardContainer(
                colors,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoRow('Current State',
                        currentMilestone.paymentRequestStatus, colors),
                    if (currentMilestone.paymentRequestedByUserId != null)
                      _buildInfoRow(
                          'Requested By',
                          users
                                  .where((u) =>
                                      u.id ==
                                      currentMilestone.paymentRequestedByUserId)
                                  .firstOrNull
                                  ?.name ??
                              'Unknown',
                          colors),
                    const SizedBox(height: 12),
                    if (currentMilestone.paymentRequestStatus ==
                            'Not Required' ||
                        currentMilestone.paymentRequestStatus == 'Pending')
                      ElevatedButton(
                        onPressed: () {
                          final currentUser = users
                                  .where((u) => u.id == rbacState.testingUserId)
                                  .firstOrNull ??
                              users.first;
                          ref
                              .read(milestoneListProvider.notifier)
                              .updateMilestone(currentMilestone.copyWith(
                                paymentRequestStatus: 'Requested',
                                paymentRequestedByUserId: currentUser.id,
                                paymentRequestedAt: DateTime.now(),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Payment Requested')));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colors.brandOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Request Payment',
                            style: TextStyle(color: Colors.white)),
                      ),
                    if (currentMilestone.paymentRequestStatus == 'Requested')
                      ElevatedButton(
                        onPressed: () {
                          final currentUser = users
                                  .where((u) => u.id == rbacState.testingUserId)
                                  .firstOrNull ??
                              users.first;
                          final financialUsers = users
                              .where((u) =>
                                  MockRbacNotifier.getEffectivePermissions(
                                          u.role, u.customPermissions)
                                      .contains('milestones.manage_financials'))
                              .toList();
                          final hasOtherFinancialUsers =
                              financialUsers.any((u) => u.id != currentUser.id);

                          if (currentMilestone.paymentRequestedByUserId ==
                                  currentUser.id &&
                              hasOtherFinancialUsers) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Self-approval blocked. Another authorized user must approve.')));
                            return;
                          }

                          ref
                              .read(milestoneListProvider.notifier)
                              .updateMilestone(currentMilestone.copyWith(
                                paymentRequestStatus: 'Approved',
                                paymentApprovedByUserId: currentUser.id,
                                paymentApprovedAt: DateTime.now(),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Payment Approved')));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colors.brandOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Approve Payment',
                            style: TextStyle(color: Colors.white)),
                      ),
                    if (currentMilestone.paymentRequestStatus == 'Approved')
                      ElevatedButton(
                        onPressed: () {
                          final currentUser = users
                                  .where((u) => u.id == rbacState.testingUserId)
                                  .firstOrNull ??
                              users.first;
                          ref
                              .read(milestoneListProvider.notifier)
                              .updateMilestone(currentMilestone.copyWith(
                                paymentRequestStatus: 'Initiated',
                                paymentInitiatedByUserId: currentUser.id,
                                paymentInitiatedAt: DateTime.now(),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Payment Initiated')));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colors.brandOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Initiate Payment',
                            style: TextStyle(color: Colors.white)),
                      ),
                    if (currentMilestone.paymentRequestStatus == 'Initiated')
                      ElevatedButton(
                        onPressed: () =>
                            _showMarkPaidSheet(currentMilestone, colors),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Mark as Paid',
                            style: TextStyle(color: Colors.white)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (currentMilestone.vendorName.isNotEmpty) ...[
              _buildSectionHeader('VENDOR', colors),
              _buildCardContainer(
                colors,
                _buildInfoRow(
                    'Vendor Name', currentMilestone.vendorName, colors),
              ),
              const SizedBox(height: 24),
            ],

            _buildSectionHeader('PROGRESS UPDATE', colors),
            _buildCardContainer(
              colors,
              Column(
                children: [
                  _buildInfoRow(
                      'Latest Note',
                      currentMilestone.latestUpdate ?? 'No updates yet',
                      colors),
                  _buildInfoRow(
                      'Last Updated',
                      _formatDate(currentMilestone.lastUpdatedAt, true),
                      colors),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showUpdateProgressSheet(
      MockWorkItem wi, MockMilestone milestone, AuthColors colors) {
    int currentProgress = wi.progress;
    String currentStatus = wi.status;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Update Progress: ${wi.title}',
                      style: TextStyle(
                          color: colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Text('Status',
                      style:
                          TextStyle(color: colors.secondaryText, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: currentStatus,
                    dropdownColor: colors.background,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Pending', 'In Progress', 'Completed', 'Blocked']
                        .map((s) {
                      return DropdownMenuItem(
                          value: s,
                          child: Text(s, style: TextStyle(color: colors.text)));
                    }).toList(),
                    onChanged: (val) {
                      setSheetState(() {
                        if (val != null) {
                          currentStatus = val;
                          if (val == 'Completed') currentProgress = 100;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Progress: $currentProgress%',
                      style:
                          TextStyle(color: colors.secondaryText, fontSize: 14)),
                  Slider(
                    value: currentProgress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: colors.brandOrange,
                    label: '$currentProgress%',
                    onChanged: (val) {
                      setSheetState(() {
                        currentProgress = val.toInt();
                        if (currentProgress == 100) {
                          currentStatus = 'Completed';
                        } else if (currentProgress > 0 &&
                            currentStatus == 'Pending') {
                          currentStatus = 'In Progress';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final updatedWi = wi.copyWith(
                        progress: currentProgress,
                        status: currentStatus,
                        completedAt: currentStatus == 'Completed'
                            ? DateTime.now()
                            : wi.completedAt,
                      );

                      ref
                          .read(mockMilestoneRepositoryProvider)
                          .updateWorkItem(updatedWi);

                      // We must also update the overall milestone to trigger providers
                      final index =
                          milestone.workItems.indexWhere((w) => w.id == wi.id);
                      final newItems =
                          List<MockWorkItem>.from(milestone.workItems);
                      if (index != -1) {
                        newItems[index] = updatedWi;

                        // Recalculate milestone overall progress and status based on work items
                        int totalProgress = newItems.fold(
                            0, (sum, item) => sum + item.progress);
                        int newMilestoneProgress =
                            (totalProgress / newItems.length).round();
                        String newMilestoneStatus = milestone.status;

                        if (newMilestoneProgress == 100) {
                          newMilestoneStatus = 'Completed';
                        } else if (newMilestoneProgress > 0) {
                          newMilestoneStatus = 'In Progress';
                        }

                        final updatedMilestone = milestone.copyWith(
                          workItems: newItems,
                          progressPercentage: newMilestoneProgress,
                          status: newMilestoneStatus,
                        );
                        ref
                            .read(milestoneListProvider.notifier)
                            .updateMilestone(updatedMilestone);
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Progress updated successfully')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.brandOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Progress',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          });
        });
  }

  void _showMarkPaidSheet(MockMilestone milestone, AuthColors colors) {
    final refCtrl = TextEditingController();
    DateTime? pDate = DateTime.now();
    int? amount = milestone.estimatedCostPaise != null
        ? (milestone.estimatedCostPaise! ~/ 100)
        : null;
    final amountCtrl = TextEditingController(text: amount?.toString() ?? '');

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Mark as Paid',
                      style: TextStyle(
                          color: colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: refCtrl,
                    style: TextStyle(color: colors.text),
                    decoration: InputDecoration(
                      labelText: 'Payment Reference / UTR *',
                      labelStyle: TextStyle(color: colors.secondaryText),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.brandOrange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: colors.text),
                    decoration: InputDecoration(
                      labelText: 'Paid Amount (₹)',
                      labelStyle: TextStyle(color: colors.secondaryText),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.brandOrange)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: pDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: colors.brandOrange,
                                onPrimary: Colors.white,
                                surface: colors.card,
                                onSurface: colors.text,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) setSheetState(() => pDate = date);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Payment Date *',
                        labelStyle: TextStyle(color: colors.secondaryText),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colors.border)),
                      ),
                      child: Text(
                        pDate != null ? _formatDate(pDate) : 'Select Date',
                        style: TextStyle(
                            color: pDate != null
                                ? colors.text
                                : colors.secondaryText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (refCtrl.text.isEmpty || pDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Please provide Payment Reference and Date')));
                        return;
                      }
                      final parsedAmount = int.tryParse(amountCtrl.text);

                      final rbacState = ref.read(mockRbacProvider);
                      final users = ref.read(mockUserListProvider);
                      final currentUser = users
                              .where((u) => u.id == rbacState.testingUserId)
                              .firstOrNull ??
                          users.first;

                      ref
                          .read(milestoneListProvider.notifier)
                          .updateMilestone(milestone.copyWith(
                            paymentRequestStatus: 'Paid',
                            paymentReference: refCtrl.text,
                            paymentDate: pDate,
                            actualCostPaise: parsedAmount != null
                                ? (parsedAmount * 100)
                                : milestone.actualCostPaise,
                            paymentPaidByUserId: currentUser.id,
                            paymentPaidAt: DateTime.now(),
                          ));

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Marked as Paid successfully')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Payment',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          });
        });
  }

  Widget _buildSectionHeader(String title, AuthColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: colors.secondaryText,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardContainer(AuthColors colors, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, AuthColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: colors.secondaryText, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String? userId, String fallbackName,
      List<MockUser> users, AuthColors colors) {
    final user = users.where((u) => u.id == userId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: colors.secondaryText, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? fallbackName,
                  style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                if (user != null)
                  Text(
                    user.role.displayName,
                    style: TextStyle(color: colors.secondaryText, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date, [bool includeTime = false]) {
    if (date == null) return 'Not set';
    final m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    var str = '${date.day} ${m[date.month - 1]} ${date.year}';
    if (includeTime) {
      str +=
          ' at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return str;
  }

  String _formatCurrency(int? paise) {
    if (paise == null) return 'Not set';
    final rupees = paise / 100;
    return '₹${rupees.toStringAsFixed(2)}';
  }
}
