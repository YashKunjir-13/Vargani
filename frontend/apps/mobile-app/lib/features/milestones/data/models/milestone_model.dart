class MockWorkItem {
  final String id;
  final String milestoneId;
  final String title;
  final String description;
  final String assignedToUserId;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String status;
  final int progress;
  final String priority;
  final String? completionNote;
  final DateTime? completedAt;

  MockWorkItem({
    required this.id,
    required this.milestoneId,
    required this.title,
    required this.description,
    required this.assignedToUserId,
    this.startDate,
    this.dueDate,
    required this.status,
    required this.progress,
    this.priority = 'Medium',
    this.completionNote,
    this.completedAt,
  });

  MockWorkItem copyWith({
    String? id,
    String? milestoneId,
    String? title,
    String? description,
    String? assignedToUserId,
    DateTime? startDate,
    DateTime? dueDate,
    String? status,
    int? progress,
    String? priority,
    String? completionNote,
    DateTime? completedAt,
  }) {
    return MockWorkItem(
      id: id ?? this.id,
      milestoneId: milestoneId ?? this.milestoneId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      completionNote: completionNote ?? this.completionNote,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class MockMilestone {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority; // 'High', 'Medium', 'Low'
  final DateTime? startDate;
  final DateTime? dueDate;
  final String status; // 'Pending', 'In Progress', 'Completed', 'Delayed', 'Cancelled'
  final int progressPercentage;
  final List<MockWorkItem> workItems;

  final String? assignedToUserId;
  final String? assignedToUserName;

  final String? assignedByUserId;
  final String? assignedByUserName;

  final int? estimatedCostPaise;
  final int? actualCostPaise;

  final String? paymentResponsibleUserId;
  final String? paymentResponsibleUserName;

  final String paymentStatus; // 'Not Paid', 'Partially Paid', 'Paid', 'Payment Pending Approval'
  final String paymentRequestStatus; // 'Not Required', 'Pending', 'Requested', 'Approved', 'Initiated', 'Paid', 'Rejected'
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paymentDate;

  final String? vendorId;
  final String vendorName;

  final String? paymentRequestedByUserId;
  final DateTime? paymentRequestedAt;
  final String? paymentApprovedByUserId;
  final DateTime? paymentApprovedAt;
  final String? paymentInitiatedByUserId;
  final DateTime? paymentInitiatedAt;
  final String? paymentPaidByUserId;
  final DateTime? paymentPaidAt;

  final String? latestUpdate;
  final DateTime? lastUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MockMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.startDate,
    this.dueDate,
    required this.status,
    required this.progressPercentage,
    this.workItems = const [],
    this.assignedToUserId,
    this.assignedToUserName,
    this.assignedByUserId,
    this.assignedByUserName,
    this.estimatedCostPaise,
    this.actualCostPaise,
    this.paymentResponsibleUserId,
    this.paymentResponsibleUserName,
    required this.paymentStatus,
    this.paymentRequestStatus = 'Not Required',
    this.paymentMethod,
    this.paymentReference,
    this.paymentDate,
    this.vendorId,
    required this.vendorName,
    this.paymentRequestedByUserId,
    this.paymentRequestedAt,
    this.paymentApprovedByUserId,
    this.paymentApprovedAt,
    this.paymentInitiatedByUserId,
    this.paymentInitiatedAt,
    this.paymentPaidByUserId,
    this.paymentPaidAt,
    this.latestUpdate,
    this.lastUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  int get calculatedProgress {
    if (workItems.isEmpty) return progressPercentage;
    int totalProgress = workItems.fold(0, (sum, item) => sum + item.progress);
    return (totalProgress / workItems.length).round();
  }

  MockMilestone copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? startDate,
    DateTime? dueDate,
    String? status,
    int? progressPercentage,
    List<MockWorkItem>? workItems,
    String? assignedToUserId,
    String? assignedToUserName,
    String? assignedByUserId,
    String? assignedByUserName,
    int? estimatedCostPaise,
    int? actualCostPaise,
    String? paymentResponsibleUserId,
    String? paymentResponsibleUserName,
    String? paymentStatus,
    String? paymentRequestStatus,
    String? paymentMethod,
    String? paymentReference,
    DateTime? paymentDate,
    String? vendorId,
    String? vendorName,
    String? paymentRequestedByUserId,
    DateTime? paymentRequestedAt,
    String? paymentApprovedByUserId,
    DateTime? paymentApprovedAt,
    String? paymentInitiatedByUserId,
    DateTime? paymentInitiatedAt,
    String? paymentPaidByUserId,
    DateTime? paymentPaidAt,
    String? latestUpdate,
    DateTime? lastUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MockMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      workItems: workItems ?? this.workItems,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName,
      assignedByUserId: assignedByUserId ?? this.assignedByUserId,
      assignedByUserName: assignedByUserName ?? this.assignedByUserName,
      estimatedCostPaise: estimatedCostPaise ?? this.estimatedCostPaise,
      actualCostPaise: actualCostPaise ?? this.actualCostPaise,
      paymentResponsibleUserId: paymentResponsibleUserId ?? this.paymentResponsibleUserId,
      paymentResponsibleUserName: paymentResponsibleUserName ?? this.paymentResponsibleUserName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentRequestStatus: paymentRequestStatus ?? this.paymentRequestStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      paymentDate: paymentDate ?? this.paymentDate,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      paymentRequestedByUserId: paymentRequestedByUserId ?? this.paymentRequestedByUserId,
      paymentRequestedAt: paymentRequestedAt ?? this.paymentRequestedAt,
      paymentApprovedByUserId: paymentApprovedByUserId ?? this.paymentApprovedByUserId,
      paymentApprovedAt: paymentApprovedAt ?? this.paymentApprovedAt,
      paymentInitiatedByUserId: paymentInitiatedByUserId ?? this.paymentInitiatedByUserId,
      paymentInitiatedAt: paymentInitiatedAt ?? this.paymentInitiatedAt,
      paymentPaidByUserId: paymentPaidByUserId ?? this.paymentPaidByUserId,
      paymentPaidAt: paymentPaidAt ?? this.paymentPaidAt,
      latestUpdate: latestUpdate ?? this.latestUpdate,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
