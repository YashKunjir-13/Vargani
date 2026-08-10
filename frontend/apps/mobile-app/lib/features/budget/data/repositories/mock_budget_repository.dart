import 'budget_repository.dart';
import '../../models/budget_models.dart';

class MockBudgetRepository implements BudgetRepository {
  late MockBudget _budget;
  final List<MockBudgetRevision> _revisions = [];
  final List<MockLinkedExpense> _expenses = [];

  MockBudgetRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _budget = MockBudget(
      id: 'BGT-2026',
      eventId: 'EVT-001',
      title: 'Ganeshotsav 2026',
      totalBudgetPaise: 80000000, // ₹8,00,000
      version: 'v4',
      status: 'Active',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ownerUserId: 'USR-002',
      ownerUserName: 'Rahul Sharma',
      categories: [
        const MockBudgetCategory(
          id: 'CAT-001',
          name: 'Mandap & Decoration',
          iconName: 'home_repair_service',
          allocatedPaise: 30000000, // ₹3,00,000
          utilizedPaise: 25000000, // ₹2,50,000
          ownerUserId: 'USR-002',
          ownerUserName: 'Rahul Sharma',
        ),
        const MockBudgetCategory(
          id: 'CAT-002',
          name: 'Prasad & Annadaan',
          iconName: 'restaurant',
          allocatedPaise: 20000000, // ₹2,00,000
          utilizedPaise: 8500000, // ₹85,000
          ownerUserId: 'USR-003',
          ownerUserName: 'Amit Patil',
          footnote: 'Additional allocation pending sponsor confirmation',
        ),
        const MockBudgetCategory(
          id: 'CAT-003',
          name: 'Sound & Lighting',
          iconName: 'speaker',
          allocatedPaise: 15000000, // ₹1,50,000
          utilizedPaise: 12000000, // ₹1,20,000
          ownerUserId: 'USR-004',
          ownerUserName: 'Rohit Joshi',
        ),
      ],
    );

    _revisions.addAll([
      MockBudgetRevision(
        id: 'REV-001',
        budgetId: 'BGT-2026',
        version: 'v4 -> v5',
        title: 'Increase Mandap Budget',
        reason: 'Vendor prices have increased due to inflation',
        status: 'Pending',
        requestedByUserId: 'USR-003',
        requestedByUserName: 'Amit Patil',
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        adjustments: [
          const MockRevisionAdjustment(
            categoryId: 'CAT-001',
            categoryName: 'Mandap & Decoration',
            currentAllocationPaise: 30000000,
            proposedAllocationPaise: 35000000,
          ),
        ],
        comments: [
          MockCommentEntry(
            authorUserId: 'USR-003',
            authorUserName: 'Amit Patil',
            authorRoleName: 'Secretary',
            body: 'Please approve this increase. The decorator requires an advance.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      MockBudgetRevision(
        id: 'REV-002',
        budgetId: 'BGT-2026',
        version: 'v3 -> v4',
        title: 'Initial Lighting Allocation',
        status: 'Approved',
        requestedByUserId: 'USR-002',
        requestedByUserName: 'Rahul Sharma',
        requestedAt: DateTime.now().subtract(const Duration(days: 5)),
        approvedByUserId: 'USR-001',
        approvedByUserName: 'Ujwal Pandey',
        approvedAt: DateTime.now().subtract(const Duration(days: 4)),
        adjustments: [
          const MockRevisionAdjustment(
            categoryId: 'CAT-003',
            categoryName: 'Sound & Lighting',
            currentAllocationPaise: 10000000,
            proposedAllocationPaise: 15000000,
          ),
        ],
        comments: [],
      ),
    ]);

    _expenses.addAll([
      MockLinkedExpense(
        id: 'EXP-001',
        categoryId: 'CAT-001',
        date: DateTime.now().subtract(const Duration(days: 10)),
        vendorName: 'Omkar Decorators',
        amountPaise: 15000000, // ₹1,50,000
        status: 'Paid',
        isPaid: true,
      ),
      MockLinkedExpense(
        id: 'EXP-002',
        categoryId: 'CAT-001',
        date: DateTime.now().subtract(const Duration(days: 2)),
        vendorName: 'Omkar Decorators',
        amountPaise: 10000000, // ₹1,00,000
        status: 'Pending',
        isPaid: false,
      ),
    ]);
  }

  @override
  MockBudget getBudget() {
    return _budget;
  }

  @override
  List<MockBudgetRevision> getRevisions(String budgetId) {
    return _revisions.where((r) => r.budgetId == budgetId).toList();
  }

  @override
  List<MockLinkedExpense> getLinkedExpenses(String categoryId) {
    return _expenses.where((e) => e.categoryId == categoryId).toList();
  }

  @override
  void requestRevision(MockBudgetRevision revision) {
    _revisions.insert(0, revision);
  }

  @override
  void approveRevision(String revisionId, MockCommentEntry approvalComment) {
    final index = _revisions.indexWhere((r) => r.id == revisionId);
    if (index != -1) {
      final oldRev = _revisions[index];

      // Update revision status
      _revisions[index] = oldRev.copyWith(
        status: 'Approved',
        approvedByUserId: approvalComment.authorUserId,
        approvedByUserName: approvalComment.authorUserName,
        approvedAt: approvalComment.timestamp,
        comments: [...oldRev.comments, approvalComment],
      );

      // Apply the adjustments to the budget
      List<MockBudgetCategory> updatedCategories = List.from(_budget.categories);
      for (var adjustment in oldRev.adjustments) {
        final catIndex = updatedCategories.indexWhere((c) => c.id == adjustment.categoryId);
        if (catIndex != -1) {
          updatedCategories[catIndex] = updatedCategories[catIndex].copyWith(
            allocatedPaise: adjustment.proposedAllocationPaise,
          );
        }
      }

      _budget = _budget.copyWith(
        categories: updatedCategories,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  void addRevisionComment(String revisionId, MockCommentEntry comment) {
    final index = _revisions.indexWhere((r) => r.id == revisionId);
    if (index != -1) {
      final oldRev = _revisions[index];
      _revisions[index] = oldRev.copyWith(
        comments: [...oldRev.comments, comment],
      );
    }
  }
}
