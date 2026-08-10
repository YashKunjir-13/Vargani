import '../../models/budget_models.dart';

abstract class BudgetRepository {
  /// Fetches the primary budget data.
  MockBudget getBudget();

  /// Fetches all active revisions for the budget.
  List<MockBudgetRevision> getRevisions(String budgetId);

  /// Fetches expenses linked to a specific category.
  List<MockLinkedExpense> getLinkedExpenses(String categoryId);

  /// Requests a new revision.
  void requestRevision(MockBudgetRevision revision);

  /// Approves a pending revision, optionally adding a comment.
  void approveRevision(String revisionId, MockCommentEntry approvalComment);

  /// Adds a comment to a revision.
  void addRevisionComment(String revisionId, MockCommentEntry comment);
}
