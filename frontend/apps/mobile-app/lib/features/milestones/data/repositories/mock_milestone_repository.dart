import '../models/milestone_model.dart';

class MockMilestoneRepository {
  final List<MockMilestone> _milestones = [];

  List<MockMilestone> getAllMilestones() {
    return List.unmodifiable(_milestones);
  }

  MockMilestone? getMilestoneById(String id) {
    try {
      return _milestones.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  void addMilestone(MockMilestone milestone) {
    _milestones.insert(0, milestone);
  }

  void updateMilestone(MockMilestone updatedMilestone) {
    final index = _milestones.indexWhere((m) => m.id == updatedMilestone.id);
    if (index != -1) {
      _milestones[index] = updatedMilestone;
    }
  }

  void deleteMilestone(String id) {
    _milestones.removeWhere((m) => m.id == id);
  }

  void addWorkItem(MockWorkItem workItem) {
    final mIndex = _milestones.indexWhere((m) => m.id == workItem.milestoneId);
    if (mIndex != -1) {
      final m = _milestones[mIndex];
      final newWorkItems = List<MockWorkItem>.from(m.workItems)..add(workItem);
      _milestones[mIndex] = m.copyWith(
          workItems: newWorkItems,
          updatedAt: DateTime.now(),
          lastUpdatedAt: DateTime.now());
    }
  }

  void updateWorkItem(MockWorkItem updatedWorkItem) {
    final mIndex =
        _milestones.indexWhere((m) => m.id == updatedWorkItem.milestoneId);
    if (mIndex != -1) {
      final m = _milestones[mIndex];
      final wIndex = m.workItems.indexWhere((w) => w.id == updatedWorkItem.id);
      if (wIndex != -1) {
        final newWorkItems = List<MockWorkItem>.from(m.workItems);
        newWorkItems[wIndex] = updatedWorkItem;
        _milestones[mIndex] = m.copyWith(
            workItems: newWorkItems,
            updatedAt: DateTime.now(),
            lastUpdatedAt: DateTime.now());
      }
    }
  }

  void updateProgress(String milestoneId, int newProgressPercentage) {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index != -1) {
      _milestones[index] = _milestones[index].copyWith(
        progressPercentage: newProgressPercentage,
        updatedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
    }
  }

  void initiatePaymentRequest(String milestoneId) {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index != -1) {
      _milestones[index] = _milestones[index].copyWith(
        paymentRequestStatus: 'Payment Requested',
        updatedAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );
    }
  }
}
