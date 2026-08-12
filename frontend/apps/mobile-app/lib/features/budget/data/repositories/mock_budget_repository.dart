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
      id: '',
      eventId: '',
      title: 'Event Budget',
      totalBudgetPaise: 0,
      version: 'v1',
      status: 'Draft',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerUserId: '',
      ownerUserName: '',
      categories: const [],
    );
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
