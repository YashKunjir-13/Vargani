/// Represents a category-wise allocation in the budget.
class MockBudgetCategory {
  final String id;
  final String name;
  final String iconName; // store string, map to IconData in UI
  final int allocatedPaise;
  final int utilizedPaise;
  final String ownerUserId;
  final String ownerUserName;
  final String? footnote;

  const MockBudgetCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.allocatedPaise,
    required this.utilizedPaise,
    required this.ownerUserId,
    required this.ownerUserName,
    this.footnote,
  });

  MockBudgetCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    int? allocatedPaise,
    int? utilizedPaise,
    String? ownerUserId,
    String? ownerUserName,
    String? footnote,
  }) {
    return MockBudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      allocatedPaise: allocatedPaise ?? this.allocatedPaise,
      utilizedPaise: utilizedPaise ?? this.utilizedPaise,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerUserName: ownerUserName ?? this.ownerUserName,
      footnote: footnote ?? this.footnote,
    );
  }
}

/// Represents the overall budget for an event or organization.
class MockBudget {
  final String id;
  final String eventId;
  final String title;
  final int totalBudgetPaise;
  final List<MockBudgetCategory> categories;
  final String version;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerUserId;
  final String ownerUserName;

  const MockBudget({
    required this.id,
    required this.eventId,
    required this.title,
    required this.totalBudgetPaise,
    required this.categories,
    required this.version,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerUserId,
    required this.ownerUserName,
  });

  int get totalAllocatedPaise =>
      categories.fold(0, (sum, cat) => sum + cat.allocatedPaise);
  int get totalUtilizedPaise =>
      categories.fold(0, (sum, cat) => sum + cat.utilizedPaise);
  int get remainingPaise => totalBudgetPaise - totalAllocatedPaise;

  MockBudget copyWith({
    String? id,
    String? eventId,
    String? title,
    int? totalBudgetPaise,
    List<MockBudgetCategory>? categories,
    String? version,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerUserId,
    String? ownerUserName,
  }) {
    return MockBudget(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      totalBudgetPaise: totalBudgetPaise ?? this.totalBudgetPaise,
      categories: categories ?? this.categories,
      version: version ?? this.version,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerUserName: ownerUserName ?? this.ownerUserName,
    );
  }
}

/// Represents a requested change to the budget.
class MockBudgetRevision {
  final String id;
  final String budgetId;
  final String version;
  final String title;
  final String? reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final String requestedByUserId;
  final String requestedByUserName;
  final DateTime requestedAt;
  final String? approvedByUserId;
  final String? approvedByUserName;
  final DateTime? approvedAt;
  final List<MockRevisionAdjustment> adjustments;
  final List<MockCommentEntry> comments;

  const MockBudgetRevision({
    required this.id,
    required this.budgetId,
    required this.version,
    required this.title,
    this.reason,
    required this.status,
    required this.requestedByUserId,
    required this.requestedByUserName,
    required this.requestedAt,
    this.approvedByUserId,
    this.approvedByUserName,
    this.approvedAt,
    required this.adjustments,
    required this.comments,
  });

  MockBudgetRevision copyWith({
    String? id,
    String? budgetId,
    String? version,
    String? title,
    String? reason,
    String? status,
    String? requestedByUserId,
    String? requestedByUserName,
    DateTime? requestedAt,
    String? approvedByUserId,
    String? approvedByUserName,
    DateTime? approvedAt,
    List<MockRevisionAdjustment>? adjustments,
    List<MockCommentEntry>? comments,
  }) {
    return MockBudgetRevision(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      version: version ?? this.version,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      requestedByUserName: requestedByUserName ?? this.requestedByUserName,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedByUserName: approvedByUserName ?? this.approvedByUserName,
      approvedAt: approvedAt ?? this.approvedAt,
      adjustments: adjustments ?? this.adjustments,
      comments: comments ?? this.comments,
    );
  }
}

class MockRevisionAdjustment {
  final String categoryId;
  final String categoryName;
  final int currentAllocationPaise;
  final int proposedAllocationPaise;

  const MockRevisionAdjustment({
    required this.categoryId,
    required this.categoryName,
    required this.currentAllocationPaise,
    required this.proposedAllocationPaise,
  });
}

class MockCommentEntry {
  final String authorUserId;
  final String authorUserName;
  final String authorRoleName;
  final String body;
  final DateTime timestamp;

  const MockCommentEntry({
    required this.authorUserId,
    required this.authorUserName,
    required this.authorRoleName,
    required this.body,
    required this.timestamp,
  });
}

class MockLinkedExpense {
  final String id;
  final String categoryId;
  final DateTime date;
  final String vendorName;
  final int amountPaise;
  final String status;
  final bool isPaid;

  const MockLinkedExpense({
    required this.id,
    required this.categoryId,
    required this.date,
    required this.vendorName,
    required this.amountPaise,
    required this.status,
    required this.isPaid,
  });
}
