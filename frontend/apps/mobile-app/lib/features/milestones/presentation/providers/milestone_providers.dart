import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/milestone_model.dart';
import '../../data/repositories/mock_milestone_repository.dart';
import '../../../rbac/presentation/providers/mock_rbac_provider.dart';

final mockMilestoneRepositoryProvider =
    Provider<MockMilestoneRepository>((ref) {
  return MockMilestoneRepository();
});

class MilestoneListNotifier extends Notifier<List<MockMilestone>> {
  @override
  List<MockMilestone> build() {
    final rbacState = ref.watch(mockRbacProvider);
    return _getFilteredMilestones(rbacState);
  }

  List<MockMilestone> _getFilteredMilestones(MockRbacState rbacState) {
    final repo = ref.read(mockMilestoneRepositoryProvider);
    final allMilestones = repo.getAllMilestones();

    // If user has global view permission, return all
    if (rbacState.hasPermission('milestones.view')) {
      return allMilestones;
    }

    // If user only has assigned view permission, filter by their user ID
    // In a real app, this would filter by session.userId
    if (rbacState.hasPermission('milestones.view_assigned')) {
      final activeUserId = rbacState.testingUserId;
      if (activeUserId == null) {
        // If testing generic volunteer without a specific ID, show nothing
        return [];
      }

      return allMilestones.where((m) {
        // Condition 1: Milestone itself is assigned to the user
        if (m.assignedToUserId == activeUserId) return true;
        // Condition 2: At least one work item is assigned to the user
        if (m.workItems.any((w) => w.assignedToUserId == activeUserId)) {
          return true;
        }

        return false;
      }).toList();
    }

    // No permission
    return [];
  }

  void addMilestone(MockMilestone milestone) {
    ref.read(mockMilestoneRepositoryProvider).addMilestone(milestone);
    final rbacState = ref.read(mockRbacProvider);
    state = _getFilteredMilestones(rbacState); // Refresh list
  }

  void updateMilestone(MockMilestone milestone) {
    ref.read(mockMilestoneRepositoryProvider).updateMilestone(milestone);
    final rbacState = ref.read(mockRbacProvider);
    state = _getFilteredMilestones(rbacState); // Refresh list
  }

  void deleteMilestone(String id) {
    ref.read(mockMilestoneRepositoryProvider).deleteMilestone(id);
    final rbacState = ref.read(mockRbacProvider);
    state = _getFilteredMilestones(rbacState); // Refresh list
  }
}

final milestoneListProvider =
    NotifierProvider<MilestoneListNotifier, List<MockMilestone>>(
  MilestoneListNotifier.new,
);
