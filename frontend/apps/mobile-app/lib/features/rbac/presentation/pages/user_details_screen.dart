import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';

import 'add_user_screen.dart';
import 'user_management_screen.dart';
import '../providers/mock_rbac_provider.dart';

class UserDetailsScreen extends ConsumerWidget {
  final String userId;

  static const Map<String, String> _permissionLabels = {
    'collections.create': 'Donation Collection',
    'receipts.create': 'Receipt Generation',
    'expenses.create': 'Expense Management',
    'bills.create': 'Bill Management',
    'bills.approve': 'Vendor Payments',
    'kunda.manage': 'Donation Box (Kunda)',
    'sponsors.manage': 'Sponsors',
    'volunteers.manage': 'Volunteer Management',
    'members.view': 'Member Management',
    'reports.view': 'Reports',
    'audit.view': 'Audit Log',
    'analytics.view': 'Analytics',
    'records.view': 'All Records',
    'users.manage': 'User Management',
    'milestones.view': 'View Milestones',
    'milestones.view_assigned': 'View Assigned Milestones',
    'milestones.create': 'Create Milestones',
    'milestones.assign': 'Assign Milestones',
    'milestones.update': 'Update Milestones',
    'milestones.update_assigned': 'Update Assigned Milestones',
    'milestones.manage_financials': 'Manage Financials',
    'milestones.delete': 'Delete Milestones',
  };

  const UserDetailsScreen({super.key, required this.userId});

  Widget _buildSectionHeader(String title, AuthColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: colors.text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: colors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final users = ref.watch(mockUserListProvider);
    final user = users.firstWhere((u) => u.id == userId, orElse: () => users.first);
    final effectivePermissions = MockRbacNotifier.getEffectivePermissions(user.role, user.customPermissions);

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
          'User Details',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final rbac = ref.watch(mockRbacProvider);
              final canRequestMoney = rbac.isSuperAdmin || rbac.hasPermission('collections.create') || rbac.hasPermission('contribution.create');
              if (!canRequestMoney) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(Icons.request_quote_outlined, color: colors.brandOrange),
                tooltip: 'Request Money',
                onPressed: () => _showRequestMoneyDialog(context, ref, user, colors),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.visibility, color: colors.brandOrange),
            tooltip: 'Test Access',
            onPressed: () {
              ref.read(mockRbacProvider.notifier).simulateUserAccess(user);
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Testing access for ${user.name}')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: colors.brandOrange),
            tooltip: 'Edit User',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddUserScreen(editingUser: user),
                ),
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
            // Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colors.brandOrange.withValues(alpha: 0.1),
                    child: Text(
                      user.name.substring(0, 1),
                      style: TextStyle(
                        color: colors.brandOrange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.contact,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.status == 'Active' ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.status,
                      style: TextStyle(
                        color: user.status == 'Active' ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Mandal Information
            _buildSectionHeader('Mandal Information', colors),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Mandal Name', 'Shree Siddhivinayak Ganpati Mandal', colors),
                  _buildInfoRow('Date Joined', user.joinedDate, colors),
                  _buildInfoRow('Appointed By', user.appointedBy, colors),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Role & Access
            _buildSectionHeader('Role & Access', colors),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Role',
                    user.role == MockRole.custom ? (user.customRoleName ?? 'Custom Role') : user.role.displayName,
                    colors,
                  ),
                  _buildInfoRow('Role Type', user.role == MockRole.custom ? 'Custom Role' : 'Predefined Role', colors),
                  if (user.role == MockRole.custom && user.customRoleDescription != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Description',
                      style: TextStyle(color: colors.secondaryText, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.customRoleDescription!,
                      style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                  if (effectivePermissions.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildInfoRow(
                      'Access Type',
                      user.role == MockRole.custom
                        ? 'Customized Access'
                        : (user.customPermissions != null ? 'Customized Access' : 'Default Role Access'),
                      colors
                    ),
                    if (user.role != MockRole.custom && user.customPermissions != null) ...[
                      Text(
                        'Access customized from ${user.role.displayName} default',
                        style: TextStyle(
                          color: colors.brandOrange,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Access Permissions',
                      style: TextStyle(color: colors.secondaryText, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: effectivePermissions.map((p) {
                        final label = _permissionLabels[p] ?? p;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.brandOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.brandOrange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: colors.brandOrange),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  color: colors.brandOrange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Money Request History
            _buildSectionHeader('Money Requests', colors),
            _buildMoneyRequestsSection(context, ref, user, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyRequestsSection(BuildContext context, WidgetRef ref, MockUser user, AuthColors colors) {
    // Seed sample money requests for user
    final requests = [
      {
        'id': 'REQ-8801',
        'amount': '₹5,000',
        'reason': 'Ganpati decoration & floral expenses',
        'date': '04 Aug 2026',
        'requester': 'Trust President',
        'status': 'PENDING',
      },
      {
        'id': 'REQ-7792',
        'amount': '₹2,500',
        'reason': 'Mahaprasad kitchen provisions contribution',
        'date': '28 Jul 2026',
        'requester': 'Rahul Sharma • Treasurer',
        'status': 'COMPLETED',
      },
    ];

    return Container(
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
              Text(
                'Request History (${requests.length})',
                style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showRequestMoneyDialog(context, ref, user, colors),
                icon: const Icon(Icons.send_outlined, size: 16, color: Colors.white),
                label: const Text('Request Money', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            separatorBuilder: (_, __) => Divider(color: colors.border, height: 20),
            itemBuilder: (context, index) {
              final req = requests[index];
              final isPending = req['status'] == 'PENDING';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        req['amount']!,
                        style: TextStyle(color: colors.text, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          req['status']!,
                          style: TextStyle(
                            color: isPending ? Colors.orange.shade900 : Colors.green.shade900,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    req['reason']!,
                    style: TextStyle(color: colors.secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Requested by: ${req['requester']}',
                        style: TextStyle(color: colors.secondaryText, fontSize: 11),
                      ),
                      Text(
                        req['date']!,
                        style: TextStyle(color: colors.secondaryText, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRequestMoneyDialog(BuildContext context, WidgetRef ref, MockUser user, AuthColors colors) {
    final amountController = TextEditingController(text: '5000');
    final reasonController = TextEditingController(text: 'Ganpati decoration & floral expenses');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.card,
          title: Text(
            'Request Money from ${user.name}',
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Specify amount and reason for contribution request.',
                  style: TextStyle(color: colors.secondaryText, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colors.text),
                  decoration: InputDecoration(
                    labelText: 'Amount (₹) *',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Amount required';
                    final val = double.tryParse(v);
                    if (val == null || val <= 0) return 'Enter valid positive amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 2,
                  style: TextStyle(color: colors.text),
                  decoration: InputDecoration(
                    labelText: 'Reason / Purpose *',
                    prefixIcon: const Icon(Icons.notes_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Reason is required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: colors.brandOrange),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Money request of ₹${amountController.text} sent to ${user.name}. Notification dispatched.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Send Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
