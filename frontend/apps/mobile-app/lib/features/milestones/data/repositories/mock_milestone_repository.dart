import '../models/milestone_model.dart';

class MockMilestoneRepository {
  final List<MockMilestone> _milestones = [
    MockMilestone(
      id: 'MS-001',
      title: 'Ganpati Stage Decoration',
      description: 'Setup the main stage, backdrop, and floral arrangements for the festival.',
      category: 'Decoration',
      priority: 'High',
      startDate: DateTime(2026, 8, 20),
      dueDate: DateTime(2026, 8, 25),
      status: 'In Progress',
      progressPercentage: 65,
      assignedToUserId: 'USR-004',
      assignedToUserName: 'Rohan Patil',
      assignedByUserId: 'USR-001',
      assignedByUserName: 'Ujwal Pandey',
      estimatedCostPaise: 5000000, // ₹50,000
      actualCostPaise: null,
      paymentResponsibleUserId: 'USR-004',
      paymentResponsibleUserName: 'Rahul Sharma',
      paymentStatus: 'Partially Paid',
      vendorId: 'VND-001',
      vendorName: 'Omkar Decorators',
      workItems: [
        MockWorkItem(
          id: 'WI-001',
          milestoneId: 'MS-001',
          title: 'Stage frame setup',
          description: 'Erect the main wooden structure for the stage.',
          assignedToUserId: 'USR-004',
          status: 'Completed',
          progress: 100,
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MockWorkItem(
          id: 'WI-002',
          milestoneId: 'MS-001',
          title: 'Floral decoration',
          description: 'Decorate the stage with fresh marigold flowers.',
          assignedToUserId: 'USR-003', // Amit Patil
          status: 'In Progress',
          progress: 30,
        ),
      ],
      latestUpdate: 'Stage frame is up, floral work pending.',
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    MockMilestone(
      id: 'MS-002',
      title: 'Donation Booth Setup',
      description: 'Setup the tables, banners, and receipt books for the donation counter.',
      category: 'Logistics',
      priority: 'Medium',
      startDate: DateTime(2026, 8, 22),
      dueDate: DateTime(2026, 8, 27),
      status: 'Pending',
      progressPercentage: 0,
      assignedToUserId: 'USR-005',
      assignedToUserName: 'Amit Deshmukh',
      assignedByUserId: 'USR-001',
      assignedByUserName: 'Ujwal Pandey',
      estimatedCostPaise: 500000, // ₹5,000
      actualCostPaise: null,
      paymentResponsibleUserId: 'USR-004',
      paymentResponsibleUserName: 'Rahul Sharma',
      paymentStatus: 'Not Paid',
      vendorName: 'Default Vendor',
      workItems: [
        MockWorkItem(
          id: 'WI-003',
          milestoneId: 'MS-002',
          title: 'Procure Tables & Chairs',
          description: 'Rent 4 tables and 10 chairs from the local vendor.',
          assignedToUserId: 'USR-005',
          status: 'Pending',
          progress: 0,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MockMilestone(
      id: 'MS-003',
      title: 'Sound & Lighting Setup',
      description: 'Install speakers, lighting truss, and electrical wiring.',
      category: 'Technical',
      priority: 'High',
      startDate: DateTime(2026, 8, 18),
      dueDate: DateTime(2026, 8, 24),
      status: 'Completed',
      progressPercentage: 100,
      assignedToUserId: 'USR-002',
      assignedToUserName: 'Sanjay Deshmukh',
      assignedByUserId: 'USR-001',
      assignedByUserName: 'Ujwal Pandey',
      estimatedCostPaise: 3500000, // ₹35,000
      actualCostPaise: 3450000, // ₹34,500
      paymentResponsibleUserId: 'USR-004',
      paymentResponsibleUserName: 'Rahul Sharma',
      paymentStatus: 'Paid',
      vendorId: 'VND-003',
      vendorName: 'Loud & Clear Audio',
      workItems: [
        MockWorkItem(
          id: 'WI-004',
          milestoneId: 'MS-003',
          title: 'Speaker Installation',
          description: 'Install 4 main speakers and 2 monitors.',
          assignedToUserId: 'USR-002', // Sanjay Deshmukh
          status: 'Completed',
          progress: 100,
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      latestUpdate: 'Tested and verified by committee.',
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

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
      _milestones[mIndex] = m.copyWith(workItems: newWorkItems, updatedAt: DateTime.now(), lastUpdatedAt: DateTime.now());
    }
  }

  void updateWorkItem(MockWorkItem updatedWorkItem) {
    final mIndex = _milestones.indexWhere((m) => m.id == updatedWorkItem.milestoneId);
    if (mIndex != -1) {
      final m = _milestones[mIndex];
      final wIndex = m.workItems.indexWhere((w) => w.id == updatedWorkItem.id);
      if (wIndex != -1) {
        final newWorkItems = List<MockWorkItem>.from(m.workItems);
        newWorkItems[wIndex] = updatedWorkItem;
        _milestones[mIndex] = m.copyWith(workItems: newWorkItems, updatedAt: DateTime.now(), lastUpdatedAt: DateTime.now());
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
