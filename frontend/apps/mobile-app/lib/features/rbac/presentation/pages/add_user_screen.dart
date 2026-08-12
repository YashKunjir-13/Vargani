import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';

import 'user_management_screen.dart';
import '../providers/mock_rbac_provider.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  final MockUser? editingUser;

  const AddUserScreen({super.key, this.editingUser});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _customRoleNameController;
  late TextEditingController _customRoleDescController;
  late MockRole _selectedRole;

  // Track selected permissions for custom role
  final Set<String> _selectedPermissions = {};

  // All permissions available for President to assign
  final Map<String, List<Map<String, String>>> _permissionGroups = {
    'Contributions & Collections': [
      {'id': 'contribution.view', 'name': 'Contribution Management'},
      {'id': 'collections.create', 'name': 'Donation Collection'},
      {'id': 'receipts.create', 'name': 'Receipt Generation'},
    ],
    'Finance & Budget': [
      {'id': 'budget.view', 'name': 'Budget Management'},
      {'id': 'bills.create', 'name': 'Bill Management'},
      {'id': 'bills.approve', 'name': 'Vendor Payments / Approvals'},
      {'id': 'expenses.create', 'name': 'Expense Management'},
      {'id': 'kunda.manage', 'name': 'Donation Box (Kunda)'},
    ],
    'Administration': [
      {'id': 'users.manage', 'name': 'User Management'},
      {'id': 'members.view', 'name': 'Member Management'},
      {'id': 'volunteers.manage', 'name': 'Volunteer Management'},
    ],
    'Event & Promotion': [
      {'id': 'sponsors.manage', 'name': 'Sponsors & Advertisements'},
    ],
    'Reports & Audit': [
      {'id': 'reports.view', 'name': 'Reports'},
      {'id': 'audit.view', 'name': 'Audit Log'},
      {'id': 'analytics.view', 'name': 'Analytics'},
      {'id': 'records.view', 'name': 'All Records'},
    ],
    'Milestones & Work': [
      {'id': 'milestones.view', 'name': 'View Milestones'},
      {'id': 'milestones.view_assigned', 'name': 'View Assigned Milestones'},
      {'id': 'milestones.create', 'name': 'Create Milestones'},
      {'id': 'milestones.assign', 'name': 'Assign Milestones'},
      {'id': 'milestones.update', 'name': 'Update Milestones'},
      {'id': 'milestones.manage_financials', 'name': 'Manage Financials'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingUser?.name ?? '');
    _contactController = TextEditingController(text: widget.editingUser?.contact ?? '');
    _selectedRole = widget.editingUser?.role ?? MockRole.volunteer;

    _customRoleNameController = TextEditingController(text: widget.editingUser?.customRoleName ?? '');
    _customRoleDescController = TextEditingController(text: widget.editingUser?.customRoleDescription ?? '');

    if (widget.editingUser?.customPermissions != null) {
      _selectedPermissions.addAll(widget.editingUser!.customPermissions!);
    } else if (_selectedRole != MockRole.custom) {
      _selectedPermissions.addAll(MockRbacNotifier.getDefaultPermissions(_selectedRole));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _customRoleNameController.dispose();
    _customRoleDescController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRole == MockRole.custom && _customRoleNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a Custom Role Name')),
        );
        return;
      }

      final isEdit = widget.editingUser != null;

      bool isOverridden = false;
      if (_selectedRole != MockRole.custom) {
        final defaults = MockRbacNotifier.getDefaultPermissions(_selectedRole).toSet();
        if (defaults.length != _selectedPermissions.length || !defaults.containsAll(_selectedPermissions)) {
          isOverridden = true;
        }
      } else {
        isOverridden = true;
      }

      final savedUser = MockUser(
        id: isEdit ? widget.editingUser!.id : 'USR-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        role: _selectedRole,
        status: isEdit ? widget.editingUser!.status : 'Active',
        joinedDate: isEdit ? widget.editingUser!.joinedDate : 'Today',
        appointedBy: isEdit ? widget.editingUser!.appointedBy : '${ref.read(sessionControllerProvider).user?.displayName ?? 'Admin'} • President',
        customRoleName: _selectedRole == MockRole.custom ? _customRoleNameController.text.trim() : null,
        customRoleDescription: _selectedRole == MockRole.custom ? _customRoleDescController.text.trim() : null,
        customPermissions: isOverridden ? _selectedPermissions.toList() : null,
      );

      if (isEdit) {
        ref.read(mockUserListProvider.notifier).updateUser(savedUser);
      } else {
        ref.read(mockUserListProvider.notifier).addUser(savedUser);
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'User updated successfully' : 'User added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final isEdit = widget.editingUser != null;

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
          isEdit ? 'Edit User' : 'Add User',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'User Details',
                style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Email or Mobile Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.contact_mail_outlined),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter contact info' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Assign Role',
                style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MockRole>(
                    value: _selectedRole,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: MockRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedRole = val;
                          _selectedPermissions.clear();
                          if (val != MockRole.custom) {
                            _selectedPermissions.addAll(MockRbacNotifier.getDefaultPermissions(val));
                          }
                        });
                      }
                    },
                  ),
                ),
              ),

              if (_selectedRole == MockRole.custom) ...[
                const SizedBox(height: 24),
                Text(
                  'Custom Role Information',
                  style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customRoleNameController,
                  decoration: InputDecoration(
                    labelText: 'Role Name (e.g. Event Coordinator)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customRoleDescController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 24),
              Text(
                'Access & Permissions',
                style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._permissionGroups.entries.map((group) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          group.key,
                          style: TextStyle(
                            color: colors.brandOrange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.border),
                          ),
                          child: Column(
                            children: group.value.map((perm) {
                              final isSelected = _selectedPermissions.contains(perm['id']!);
                              return CheckboxListTile(
                                title: Text(
                                  perm['name']!,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                activeColor: colors.brandOrange,
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedPermissions.add(perm['id']!);
                                    } else {
                                      _selectedPermissions.remove(perm['id']!);
                                    }
                                  });
                                },
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                  ),
                );
              }),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? 'Save Changes' : 'Create User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
