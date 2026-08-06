import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';

import 'add_user_screen.dart';
import 'user_details_screen.dart';
import '../providers/mock_rbac_provider.dart';

// Temporary mock user model for the UI
class MockUser {
  final String id;
  final String name;
  final String contact;
  final MockRole role;
  final bool isSuperAdmin;
  final String status;
  final String joinedDate;
  final String appointedBy;
  final String? customRoleName;
  final String? customRoleDescription;
  final List<String>? customPermissions;

  MockUser({
    required this.id,
    required this.name,
    required this.contact,
    required this.role,
    bool? isSuperAdmin,
    this.status = 'Active',
    this.joinedDate = '15 July 2026',
    this.appointedBy = 'Founding Committee / Mandal Administration',
    this.customRoleName,
    this.customRoleDescription,
    this.customPermissions,
  }) : isSuperAdmin = isSuperAdmin ?? (role == MockRole.president);

  List<String> get effectivePermissions {
    if (isSuperAdmin) {
      return MockRbacNotifier.getDefaultPermissions(MockRole.president);
    }
    return customPermissions ?? MockRbacNotifier.getDefaultPermissions(role);
  }

  MockUser copyWith({
    String? id,
    String? name,
    String? contact,
    MockRole? role,
    bool? isSuperAdmin,
    String? status,
    String? joinedDate,
    String? appointedBy,
    String? customRoleName,
    String? customRoleDescription,
    List<String>? customPermissions,
  }) {
    return MockUser(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      role: role ?? this.role,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      appointedBy: appointedBy ?? this.appointedBy,
      customRoleName: customRoleName ?? this.customRoleName,
      customRoleDescription: customRoleDescription ?? this.customRoleDescription,
      customPermissions: customPermissions ?? this.customPermissions,
    );
  }
}

// Temporary state for the mock user list
class MockUserListNotifier extends Notifier<List<MockUser>> {
  @override
  List<MockUser> build() {
    return [
      MockUser(
        id: 'USR-001',
        name: 'Ujwal Pandey',
        contact: 'ujwal@example.com',
        role: MockRole.president,
        isSuperAdmin: true,
      ),
      MockUser(
        id: 'USR-VP-A',
        name: 'Suresh Patil (VP - Restricted)',
        contact: 'suresh.vp1@example.com',
        role: MockRole.vicePresident,
        isSuperAdmin: false,
        customPermissions: const [
          'contribution.view',
          'collections.create',
          'reports.view',
          'analytics.view',
          'member.view',
          'members.view',
        ],
        appointedBy: 'Ujwal Pandey • Trust President (Adhyaksha)',
      ),
      MockUser(
        id: 'USR-VP-B',
        name: 'Anil Deshmukh (VP - Extended)',
        contact: 'anil.vp2@example.com',
        role: MockRole.vicePresident,
        isSuperAdmin: false,
        customPermissions: const [
          'contribution.view',
          'collections.create',
          'reports.view',
          'analytics.view',
          'member.view',
          'members.view',
          'bill.view',
          'bills.create',
          'vendor_payment.view',
          'bills.approve',
        ],
        appointedBy: 'Ujwal Pandey • Trust President (Adhyaksha)',
      ),
      MockUser(
        id: 'USR-002',
        name: 'Rahul Sharma',
        contact: '+91 9876543210',
        role: MockRole.treasurer,
        isSuperAdmin: false,
        appointedBy: 'Ujwal Pandey • Trust President (Adhyaksha)',
      ),
      MockUser(
        id: 'USR-003',
        name: 'Amit Patil',
        contact: 'amit@example.com',
        role: MockRole.secretary,
        isSuperAdmin: false,
        appointedBy: 'Ujwal Pandey • Trust President (Adhyaksha)',
      ),
      MockUser(
        id: 'USR-004',
        name: 'Rohit Joshi',
        contact: '+91 9876543211',
        role: MockRole.volunteer,
        isSuperAdmin: false,
        appointedBy: 'Rahul Sharma • Treasurer (Khajindar)',
      ),
    ];
  }

  void addUser(MockUser user) {
    state = [...state, user];
  }

  void updateUser(MockUser updatedUser) {
    state = [
      for (final user in state)
        if (user.id == updatedUser.id) updatedUser else user,
    ];
  }
}

final mockUserListProvider = NotifierProvider<MockUserListNotifier, List<MockUser>>(
  MockUserListNotifier.new,
);

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final users = ref.watch(mockUserListProvider);

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
          'User Management',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(userId: user.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: colors.brandOrange.withValues(alpha: 0.1),
                  child: Text(
                    user.name.substring(0, 1),
                    style: TextStyle(
                      color: colors.brandOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      user.contact,
                      style: TextStyle(color: colors.secondaryText, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.brandOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.role == MockRole.custom ? (user.customRoleName ?? 'Custom Role') : user.role.displayName,
                            style: TextStyle(
                              color: colors.brandOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (user.role == MockRole.custom) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Custom Role',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.brandOrange,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddUserScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add User',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
