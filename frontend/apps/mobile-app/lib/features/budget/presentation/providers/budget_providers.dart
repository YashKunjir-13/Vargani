import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../rbac/presentation/providers/mock_rbac_provider.dart';
import '../../models/budget_models.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/mock_budget_repository.dart';

final mockBudgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return MockBudgetRepository();
});

class BudgetNotifier extends Notifier<MockBudget?> {
  @override
  MockBudget? build() {
    final rbacState = ref.watch(mockRbacProvider);
    // Use expenses.create as the baseline permission for budget access
    // based on existing dashboard logic.
    if (!rbacState.hasPermission('expenses.create')) {
      return null;
    }
    return ref.read(mockBudgetRepositoryProvider).getBudget();
  }

  void refresh() {
    state = ref.read(mockBudgetRepositoryProvider).getBudget();
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, MockBudget?>(
  BudgetNotifier.new,
);

final budgetRevisionsProvider =
    Provider.family<List<MockBudgetRevision>, String>((ref, budgetId) {
  final rbacState = ref.watch(mockRbacProvider);
  if (!rbacState.hasPermission('expenses.create')) {
    return [];
  }
  // We trigger a re-fetch when budget changes
  ref.watch(budgetProvider);
  return ref.read(mockBudgetRepositoryProvider).getRevisions(budgetId);
});

final linkedExpensesProvider =
    Provider.family<List<MockLinkedExpense>, String>((ref, categoryId) {
  final rbacState = ref.watch(mockRbacProvider);
  if (!rbacState.hasPermission('expenses.create')) {
    return [];
  }
  return ref.read(mockBudgetRepositoryProvider).getLinkedExpenses(categoryId);
});

class BudgetActions {
  final Ref ref;
  BudgetActions(this.ref);

  void requestRevision(MockBudgetRevision revision) {
    ref.read(mockBudgetRepositoryProvider).requestRevision(revision);
    ref.read(budgetProvider.notifier).refresh();
  }

  void approveRevision(String revisionId, String commentBody) {
    final rbacState = ref.read(mockRbacProvider);
    // Only users who can approve bills can approve budget revisions
    if (!rbacState.hasPermission('bills.approve')) {
      throw Exception('Unauthorized to approve budget revisions');
    }

    final comment = MockCommentEntry(
      authorUserId: rbacState.testingUserId ?? 'USR-000',
      authorUserName: rbacState.testingUserName ?? 'Unknown',
      authorRoleName: rbacState.activeRole.displayName,
      body: commentBody,
      timestamp: DateTime.now(),
    );

    ref.read(mockBudgetRepositoryProvider).approveRevision(revisionId, comment);
    ref.read(budgetProvider.notifier).refresh();
  }

  void addComment(String revisionId, String commentBody) {
    final rbacState = ref.read(mockRbacProvider);
    final comment = MockCommentEntry(
      authorUserId: rbacState.testingUserId ?? 'USR-000',
      authorUserName: rbacState.testingUserName ?? 'Unknown',
      authorRoleName: rbacState.activeRole.displayName,
      body: commentBody,
      timestamp: DateTime.now(),
    );

    ref
        .read(mockBudgetRepositoryProvider)
        .addRevisionComment(revisionId, comment);
    ref.read(budgetProvider.notifier).refresh();
  }
}

final budgetActionsProvider = Provider<BudgetActions>((ref) {
  return BudgetActions(ref);
});
