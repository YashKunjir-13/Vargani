import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../authentication/presentation/widgets/auth_design_tokens.dart';
import '../../../rbac/presentation/providers/mock_rbac_provider.dart';
import '../../../rbac/presentation/pages/user_management_screen.dart';
import '../../data/models/milestone_model.dart';
import '../providers/milestone_providers.dart';

class MilestoneFormScreen extends ConsumerStatefulWidget {
  final MockMilestone? existingMilestone;

  const MilestoneFormScreen({super.key, this.existingMilestone});

  @override
  ConsumerState<MilestoneFormScreen> createState() => _MilestoneFormScreenState();
}

class _MilestoneFormScreenState extends ConsumerState<MilestoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late TextEditingController _vendorController;

  MockUser? _selectedAssignedTo;
  MockUser? _selectedPaymentResponsible;
  String? _selectedCategory;
  String? _selectedPriority;

  DateTime? _startDate;
  DateTime? _dueDate;

  List<MockWorkItem> _workItems = [];

  final List<String> _categories = [
    'Decoration',
    'Electrical',
    'Sound & Lighting',
    'Donation Collection',
    'Publicity & Advertisement',
    'Vendor Management',
    'Event Setup',
    'Prasad / Food',
    'Security',
    'Permissions & Compliance',
    'Transportation',
    'Other'
  ];

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  bool _usersInitialized = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existingMilestone;
    _titleController = TextEditingController(text: m?.title ?? '');
    _descriptionController = TextEditingController(text: m?.description ?? '');
    _budgetController = TextEditingController(text: m?.estimatedCostPaise != null ? (m!.estimatedCostPaise! / 100).toStringAsFixed(0) : '');
    _vendorController = TextEditingController(text: m?.vendorName ?? '');

    _selectedCategory = m?.category;
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Other';
    }

    _selectedPriority = m?.priority;
    _startDate = m?.startDate;
    _dueDate = m?.dueDate;
    _workItems = m?.workItems.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final rbacState = ref.watch(mockRbacProvider);
    final users = ref.watch(mockUserListProvider);

    if (!_usersInitialized && widget.existingMilestone != null) {
      final m = widget.existingMilestone!;
      if (m.assignedToUserId != null) {
        _selectedAssignedTo = users.where((u) => u.id == m.assignedToUserId).firstOrNull;
      }
      if (m.paymentResponsibleUserId != null) {
        _selectedPaymentResponsible = users.where((u) => u.id == m.paymentResponsibleUserId).firstOrNull;
      }
      _usersInitialized = true;
    }

    final bool isEdit = widget.existingMilestone != null;
    final bool canManageFinancials = rbacState.hasPermission('milestones.manage_financials');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
        title: Text(
          isEdit ? 'Edit Milestone' : 'Create Milestone',
          style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('BASIC DETAILS', colors),
              _buildTextField('Work / Milestone Name *', colors, Icons.assignment, controller: _titleController),
              const SizedBox(height: 16),
              _buildTextField('Description', colors, Icons.description, maxLines: 3, controller: _descriptionController),
              const SizedBox(height: 16),
              _buildDropdownSelector('Category *', colors, Icons.category, _selectedCategory, _categories, (val) => setState(() => _selectedCategory = val)),
              const SizedBox(height: 16),
              _buildDropdownSelector('Priority *', colors, Icons.priority_high, _selectedPriority, _priorities, (val) => setState(() => _selectedPriority = val)),
              const SizedBox(height: 24),

              _buildSectionHeader('TIMELINE', colors),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Start Date',
                      colors,
                      Icons.calendar_today,
                      _startDate,
                      (date) => setState(() => _startDate = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      'Due Date',
                      colors,
                      Icons.event,
                      _dueDate,
                      (date) => setState(() => _dueDate = date),
                      minDate: _startDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('RESPONSIBILITY', colors),
              _buildUserSelector('Assigned Coordinator *', colors, Icons.person, _selectedAssignedTo, users, (u) {
                setState(() => _selectedAssignedTo = u);
              }),
              const SizedBox(height: 24),

              _buildSectionHeader('WORK ITEMS', colors),
              ..._workItems.map((wi) => _buildWorkItemTile(wi, colors, users)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddWorkItemSheet(context, colors, users),
                icon: Icon(Icons.add, color: colors.brandOrange),
                label: Text('Add Work Item', style: TextStyle(color: colors.brandOrange)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.brandOrange.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              if (canManageFinancials) ...[
                _buildSectionHeader('FINANCIAL DETAILS', colors),
                _buildTextField('Estimated Budget', colors, Icons.currency_rupee, controller: _budgetController, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildUserSelector('Payment Responsible', colors, Icons.account_balance_wallet, _selectedPaymentResponsible,
                  users.where((u) => MockRbacNotifier.getEffectivePermissions(u.role, u.customPermissions).contains('milestones.manage_financials')).toList(),
                (u) {
                  setState(() => _selectedPaymentResponsible = u);
                }),
                const SizedBox(height: 24),
              ],

              _buildSectionHeader('VENDOR *', colors),
              _buildTextField('Vendor Name *', colors, Icons.store, controller: _vendorController),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveMilestone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brandOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEdit ? 'Save Changes' : 'Create Milestone',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    AuthColors colors,
    IconData icon,
    DateTime? selectedDate,
    Function(DateTime) onSelected,
    {DateTime? minDate}
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? minDate ?? DateTime.now(),
          firstDate: minDate ?? DateTime(2020),
          lastDate: DateTime(2030),
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
        if (date != null) {
          onSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.secondaryText),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
          prefixIcon: Icon(icon, color: colors.secondaryText),
        ),
        child: Text(
          selectedDate != null ? DateFormat('dd MMM yyyy').format(selectedDate) : 'Select Date',
          style: TextStyle(color: selectedDate != null ? colors.text : colors.secondaryText),
        ),
      ),
    );
  }

  Widget _buildWorkItemTile(MockWorkItem wi, AuthColors colors, List<MockUser> users) {
    final assignee = users.where((u) => u.id == wi.assignedToUserId).firstOrNull;
    return Card(
      color: colors.card,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colors.border)),
      child: ListTile(
        title: Text(wi.title, style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        subtitle: Text(assignee?.name ?? 'Unknown', style: TextStyle(color: colors.secondaryText, fontSize: 12)),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            setState(() {
              _workItems.removeWhere((w) => w.id == wi.id);
            });
          },
        ),
      ),
    );
  }

  void _showAddWorkItemSheet(BuildContext context, AuthColors colors, List<MockUser> users) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    MockUser? selectedUser;
    DateTime? wiStartDate;
    DateTime? wiDueDate;
    String priority = 'Medium';
    String status = 'Pending';
    double progress = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 24,
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text('WORK ITEM DETAILS', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: 16),

                      TextField(
                        controller: titleCtrl,
                        style: TextStyle(color: colors.text),
                        decoration: InputDecoration(
                          labelText: 'Work Item Title *',
                          labelStyle: TextStyle(color: colors.secondaryText),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.brandOrange)),
                          prefixIcon: Icon(Icons.assignment, color: colors.secondaryText),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: descCtrl,
                        style: TextStyle(color: colors.text),
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          labelStyle: TextStyle(color: colors.secondaryText),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.brandOrange)),
                          prefixIcon: Icon(Icons.description, color: colors.secondaryText),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('ASSIGNED TO *', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      _buildUserSelector('Select User', colors, Icons.person, selectedUser, users, (u) {
                        setSheetState(() => selectedUser = u);
                      }),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('START DATE', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                                const SizedBox(height: 16),
                                _buildDatePicker('Select Date', colors, Icons.calendar_today, wiStartDate, (date) {
                                  setSheetState(() => wiStartDate = date);
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DUE DATE', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                                const SizedBox(height: 16),
                                _buildDatePicker('Select Date', colors, Icons.event, wiDueDate, (date) {
                                  setSheetState(() => wiDueDate = date);
                                }, minDate: wiStartDate),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text('PRIORITY', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: TextStyle(color: colors.secondaryText),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.brandOrange)),
                          prefixIcon: Icon(Icons.priority_high, color: colors.secondaryText),
                        ),
                        dropdownColor: colors.background,
                        items: ['Low', 'Medium', 'High', 'Critical'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(color: colors.text)))).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => priority = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      Text('STATUS', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: colors.secondaryText),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.brandOrange)),
                          prefixIcon: Icon(Icons.info_outline, color: colors.secondaryText),
                        ),
                        dropdownColor: colors.background,
                        items: ['Pending', 'In Progress', 'Completed'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(color: colors.text)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              status = val;
                              if (status == 'Completed') progress = 100.0;
                              if (status == 'Pending') progress = 0.0;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      Text('PROGRESS: ${progress.toInt()}%', style: TextStyle(color: colors.brandOrange, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      Slider(
                        value: progress,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        activeColor: colors.brandOrange,
                        label: '${progress.toInt()}%',
                        onChanged: (val) {
                          setSheetState(() {
                            progress = val;
                            if (progress == 100) status = 'Completed';
                            else if (progress > 0 && status == 'Pending') status = 'In Progress';
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          if (titleCtrl.text.isEmpty || selectedUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                            return;
                          }
                          if (wiDueDate != null && wiStartDate != null && wiDueDate!.isBefore(wiStartDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Due Date cannot be before Start Date')));
                            return;
                          }

                          setState(() {
                            _workItems.add(MockWorkItem(
                              id: 'WI-${DateTime.now().millisecondsSinceEpoch}',
                              milestoneId: widget.existingMilestone?.id ?? '', // Temporary if new
                              title: titleCtrl.text,
                              description: descCtrl.text,
                              assignedToUserId: selectedUser!.id,
                              status: status,
                              progress: progress.toInt(),
                              startDate: wiStartDate,
                              dueDate: wiDueDate,
                            ));
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.brandOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Work Item', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }
            );
          }
        );
      }
    );
  }

  Widget _buildSectionHeader(String title, AuthColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          color: colors.brandOrange,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, AuthColors colors, IconData icon, {int maxLines = 1, TextEditingController? controller, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.secondaryText),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.brandOrange)),
        prefixIcon: Icon(icon, color: colors.secondaryText),
      ),
      validator: (value) {
        if (label.contains('*') && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownSelector(
    String label,
    AuthColors colors,
    IconData icon,
    String? selectedValue,
    List<String> options,
    Function(String) onSelected,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colors.secondaryText),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.brandOrange)),
        prefixIcon: Icon(icon, color: colors.secondaryText),
      ),
      dropdownColor: colors.background,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: TextStyle(color: colors.text)),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onSelected(val);
      },
      validator: (value) {
        if (label.contains('*') && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildUserSelector(
    String label,
    AuthColors colors,
    IconData icon,
    MockUser? selectedUser,
    List<MockUser> availableUsers,
    Function(MockUser) onSelected,
  ) {
    return InkWell(
      onTap: () {
        _showUserSelectionSheet(label, colors, availableUsers, onSelected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.secondaryText),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
          prefixIcon: Icon(icon, color: colors.secondaryText),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedUser != null
                    ? '${selectedUser.name} (${selectedUser.role.displayName})'
                    : 'Select User',
                style: TextStyle(color: selectedUser != null ? colors.text : colors.secondaryText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }

  void _showUserSelectionSheet(String title, AuthColors colors, List<MockUser> users, Function(MockUser) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: colors.border),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (ctx, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.brandOrange.withValues(alpha: 0.1),
                      child: Text(user.name.substring(0, 1), style: TextStyle(color: colors.brandOrange)),
                    ),
                    title: Text(user.name, style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
                    subtitle: Text(user.role.displayName, style: TextStyle(color: colors.secondaryText, fontSize: 12)),
                    onTap: () {
                      onSelected(user);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveMilestone() {
    if (!_formKey.currentState!.validate()) return;

    if (_vendorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vendor Name is required')));
      return;
    }
    if (_titleController.text.trim().isEmpty || _selectedCategory == null || _selectedPriority == null || _selectedAssignedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required basic details')));
      return;
    }

    if (_dueDate != null && _startDate != null && _dueDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Due Date cannot be before Start Date')));
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      int parsedBudget = 0;
      if (_budgetController.text.isNotEmpty) {
        parsedBudget = (int.tryParse(_budgetController.text) ?? 0) * 100;
      }

      final mId = widget.existingMilestone?.id ?? 'MS-${DateTime.now().millisecondsSinceEpoch}';

      // Ensure all work items have the correct milestoneId
      final finalWorkItems = _workItems.map((w) => w.copyWith(milestoneId: mId)).toList();

      final newMilestone = MockMilestone(
        id: mId,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? 'Other',
        status: widget.existingMilestone?.status ?? 'Pending',
        priority: _selectedPriority ?? 'Medium',
        startDate: _startDate,
        dueDate: _dueDate,
        createdAt: widget.existingMilestone?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        assignedToUserId: _selectedAssignedTo!.id,
        assignedToUserName: _selectedAssignedTo!.name,
        assignedByUserId: widget.existingMilestone?.assignedByUserId ?? ref.read(mockRbacProvider).testingUserId ?? 'USR-001',
        assignedByUserName: widget.existingMilestone?.assignedByUserName ?? ref.read(mockRbacProvider).testingUserName ?? 'Admin',
        paymentResponsibleUserId: _selectedPaymentResponsible?.id ?? widget.existingMilestone?.paymentResponsibleUserId,
        paymentResponsibleUserName: _selectedPaymentResponsible?.name ?? widget.existingMilestone?.paymentResponsibleUserName,
        estimatedCostPaise: parsedBudget > 0 ? parsedBudget : widget.existingMilestone?.estimatedCostPaise,
        actualCostPaise: widget.existingMilestone?.actualCostPaise ?? 0,
        paymentStatus: widget.existingMilestone?.paymentStatus ?? 'Not Paid',
        paymentRequestStatus: widget.existingMilestone?.paymentRequestStatus ?? 'Not Required',
        progressPercentage: widget.existingMilestone?.progressPercentage ?? 0,
        vendorName: _vendorController.text.trim(),
        workItems: finalWorkItems,
      );

      if (widget.existingMilestone != null) {
        ref.read(milestoneListProvider.notifier).updateMilestone(newMilestone);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Milestone Updated')));
      } else {
        ref.read(milestoneListProvider.notifier).addMilestone(newMilestone);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Milestone Created')));
      }

      Navigator.pop(context);
    }
  }
}
