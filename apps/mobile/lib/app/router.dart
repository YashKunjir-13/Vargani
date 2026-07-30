import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_controller.dart';
import '../features/audit_logs/advanced_filters_sheet.dart';
import '../features/audit_logs/audit_detail_screen.dart';
import '../features/audit_logs/audit_overview_screen.dart';
import '../features/audit_logs/audit_search_screen.dart';
import '../features/audit_logs/audit_timeline_screen.dart';
import '../features/audit_logs/models/audit_models.dart';
import '../features/authentication/data/models/auth_models.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/registration_page.dart';
import '../features/bills/screens/bill_detail_screen.dart';
import '../features/bills/screens/bills_list_screen.dart';
import '../features/bills/screens/create_bill_screen.dart';
import '../features/budget/advanced_filters_sheet.dart';
import '../features/budget/budget_approval_screen.dart';
import '../features/budget/budget_details_screen.dart';
import '../features/budget/budget_overview_screen.dart';
import '../features/budget/budget_revision_screen.dart';
import '../features/budget/budget_table_screen.dart';
import '../features/budget/export_budget_sheet.dart';
import '../features/budget/models/budget_models.dart';
import '../features/contribution_receipts/screens/contribution_receipt_detail_screen.dart';
import '../features/contribution_receipts/screens/contribution_receipts_list_screen.dart';
import '../features/contributions/screens/contribution_detail_screen.dart';
import '../features/contributions/screens/contributions_list_screen.dart';
import '../features/contributions/screens/create_contribution_screen.dart';
import '../features/dashboard/presentation/pages/donor_dashboard_screen.dart';
import '../features/dashboard/presentation/pages/mandal_dashboard_screen.dart';
import '../features/notifications/advanced_filters_sheet.dart';
import '../features/notifications/models/notification_models.dart';
import '../features/notifications/notification_center_screen.dart';
import '../features/notifications/notification_detail_screen.dart';
import '../features/notifications/notification_settings_screen.dart';
import '../features/payments/screens/create_payment_screen.dart';
import '../features/payments/screens/payment_detail_screen.dart';
import '../features/payments/screens/payments_list_screen.dart';
import '../features/receipts/screens/receipt_detail_screen.dart';
import '../features/receipts/screens/receipts_list_screen.dart';
import '../features/templates/screens/template_calibration_screen.dart';
import '../shared/ui_kit/chips/severity_badge.dart';
import '../shared/ui_kit/navigation/approval_stepper.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';
import 'coming_soon_screen.dart';
import 'home_screen.dart';

/// Helper to build ultra-smooth fade and slide transitions for sub-routes.
CustomTransitionPage<void> _buildSmoothPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      );
    },
  );
}

/// Notifies go_router's redirect logic to re-run whenever the session state
/// changes (login, logout, restore), without recreating the whole router.
class _SessionRefreshNotifier extends ChangeNotifier {
  _SessionRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (_, __) => notifyListeners());
  }
}

/// Root app router.
///
/// The tenant-scoped `(organizationId, eventId)` context-switch guard lands
/// alongside the auth/tenant route trees in a later feature phase.
///
/// Detail screens receive their data via `state.extra`, passed by the hub
/// screen that navigated to them (e.g. tapping a budget category passes
/// that category's [BudgetCategoryData]). This is a deliberate placeholder:
/// once Step 9/10 wire real Riverpod providers backed by a repository,
/// these mock constants are replaced by `ref.watch(...)` reads and the
/// route builders stop constructing data themselves -- the route
/// *structure* below does not change.
final appRouterProvider = Provider.family<GoRouter, String>((ref, environment) {
  final refreshNotifier = _SessionRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/register',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isDashboardRoute = state.matchedLocation == '/mandal-dashboard' ||
          state.matchedLocation == '/donor-dashboard';

      if (!session.isAuthenticated && !isAuthRoute) {
        return '/register';
      }

      if (session.isAuthenticated) {
        final targetRoute = (session.activeRole == LoginRole.donor)
            ? '/donor-dashboard'
            : '/mandal-dashboard';

        if (isAuthRoute || state.matchedLocation == '/') {
          return targetRoute;
        }

        // Prevent donor from accessing mandal dashboard directly or vice versa
        if (isDashboardRoute && state.matchedLocation != targetRoute) {
          return targetRoute;
        }
      }

      return null;
    },
    routes: [
      // ---------------- Authentication ----------------
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(
          onBackToRegistration: () => context.go('/register'),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegistrationPage(
          onLoginRequested: () => context.go('/login'),
        ),
      ),

      // ---------------- Dashboard ----------------
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/payments',
            name: 'payments',
            builder: (context, state) => const PaymentsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'payments-new',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: const CreatePaymentScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'payments-detail',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: PaymentDetailScreen(
                      paymentId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/receipts',
            name: 'receipts',
            builder: (context, state) => const ReceiptsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'receipts-detail',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: ReceiptDetailScreen(
                      receiptId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/bills',
            name: 'bills',
            builder: (context, state) => const BillsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'bills-new',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: const CreateBillScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'bills-detail',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: BillDetailScreen(billId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/contributions',
            name: 'contributions',
            builder: (context, state) => const ContributionsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'contributions-new',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: const CreateContributionScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'contributions-detail',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: ContributionDetailScreen(
                      contributionId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/contribution-receipts',
            name: 'contribution-receipts',
            builder: (context, state) => const ContributionReceiptsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'contribution-receipts-detail',
                pageBuilder: (context, state) => _buildSmoothPage(
                  context: context,
                  state: state,
                  child: ContributionReceiptDetailScreen(
                      receiptId: state.pathParameters['id']!),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/templates',
        name: 'templates',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const TemplateCalibrationScreen(),
        ),
      ),
      GoRoute(
        path: '/mandal-dashboard',
        name: 'mandal-dashboard',
        builder: (context, state) => const MandalDashboardScreen(),
      ),
      GoRoute(
        path: '/donor-dashboard',
        name: 'donor-dashboard',
        builder: (context, state) => const DonorDashboardScreen(),
      ),

      // ---------------- Budget ----------------
      GoRoute(
        path: '/budget',
        name: 'budget',
        builder: (context, state) => BudgetOverviewScreen(
          overview: _mockBudgetOverview,
          categories: _mockBudgetCategories,
          revisions: _mockRevisions,
          onOpenFilters: () => BudgetFiltersSheet.show(context),
          onOpenExport: () => ExportBudgetSheet.show(context),
          onOpenTable: () => context.pushNamed('budget-table'),
          onCreateRevision: () => context.pushNamed('budget-revision'),
          onOpenCategory: (category) =>
              context.pushNamed('budget-details', extra: category),
          onOpenRevision: (_) => context.pushNamed('budget-approval'),
        ),
        routes: [
          GoRoute(
            path: 'table',
            name: 'budget-table',
            builder: (context, state) =>
                const BudgetTableScreen(categories: _mockBudgetCategories),
          ),
          GoRoute(
            path: 'details',
            name: 'budget-details',
            builder: (context, state) => BudgetDetailsScreen(
              category: (state.extra as BudgetCategoryData?) ??
                  _mockBudgetCategories.first,
              linkedExpenses: _mockLinkedExpenses,
              approvalHistoryNote:
                  'Revision v3 approved · allocation raised to ₹4,00,000',
            ),
          ),
          GoRoute(
            path: 'approval',
            name: 'budget-approval',
            builder: (context, state) => BudgetApprovalScreen(
              request: _mockApprovalRequest,
              steps: _mockApprovalSteps,
              onApprove: () => Navigator.of(context).pop(),
              onReject: () => Navigator.of(context).pop(),
              onReturn: () => Navigator.of(context).pop(),
            ),
          ),
          GoRoute(
            path: 'revision',
            name: 'budget-revision',
            builder: (context, state) => BudgetRevisionScreen(
              nextVersionLabel: 'v5',
              initialReason: '',
              adjustments: _mockRevisionAdjustments,
              netChangeBalances: true,
              onSaveDraft: () => Navigator.of(context).pop(),
              onSubmitForApproval: () =>
                  context.pushReplacementNamed('budget-approval'),
            ),
          ),
        ],
      ),

      // ---------------- Audit Log ----------------
      GoRoute(
        path: '/audit',
        name: 'audit',
        builder: (context, state) => AuditOverviewScreen(
          summary: _mockAuditSummary,
          events: _mockAuditEvents,
          criticalAlertTitle: '5 failed login attempts',
          criticalAlertSubtitle: 'IP 103.22.x.x · unrecognized device',
          onOpenEvent: (event) =>
              context.pushNamed('audit-detail', extra: event),
          onOpenSearch: () => context.pushNamed('audit-search'),
          onOpenFilters: () => AuditFiltersSheet.show(context),
        ),
        routes: [
          GoRoute(
            path: 'timeline',
            name: 'audit-timeline',
            builder: (context, state) => AuditTimelineScreen(
              events: _mockAuditEvents,
              onOpenEvent: (event) =>
                  context.pushNamed('audit-detail', extra: event),
            ),
          ),
          GoRoute(
            path: 'detail',
            name: 'audit-detail',
            builder: (context, state) => AuditDetailScreen(
              detail: _mockAuditDetail,
              onOpenLinkedRecord: () => context.pushNamed('budget'),
            ),
          ),
          GoRoute(
            path: 'search',
            name: 'audit-search',
            builder: (context, state) => AuditSearchScreen(
              recentSearches: const [
                'AUD-88213',
                'Rahul S.',
                'EXP-2291',
                'Role changed'
              ],
              onSearch: (query) async => _mockSearchResults
                  .where((r) => (r.beforeMatch + r.matchText + r.afterMatch)
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList(),
            ),
          ),
        ],
      ),

      // ---------------- Notifications ----------------
      GoRoute(
        path: '/notifications',
        name: 'dashboard-notifications',
        builder: (context, state) => NotificationCenterScreen(
          summary: _mockNotificationSummary,
          items: _mockNotificationItems,
          priorityAlertTitle: 'Budget revision awaiting your approval',
          priorityAlertSubtitle: 'Submitted by Priya Deshmukh · 2h ago',
          onOpenItem: (item) =>
              context.pushNamed('notification-detail', extra: item),
          onOpenFilters: () => NotificationFiltersSheet.show(context),
          onOpenSettings: () => context.pushNamed('notification-settings'),
          onPrimaryAction: (id) {},
        ),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'notification-detail',
            builder: (context, state) => NotificationDetailScreen(
              detail: _mockNotificationDetail,
              onPrimaryAction: () => Navigator.of(context).pop(),
              onOpenLinkedRecord: () => context.pushNamed('budget'),
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'notification-settings',
            builder: (context, state) => const NotificationSettingsScreen(
              categories: _mockNotificationSettings,
              quietHoursStart: '10:00 PM',
              quietHoursEnd: '7:00 AM',
              quietHoursEnabled: true,
              digestFrequency: 'Hourly digest',
              weeklySummaryEnabled: true,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ComingSoonScreen(title: 'Expenses'),
      ),
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ComingSoonScreen(title: 'Reports'),
      ),
    ],
  );
});

// ============================================================
// Temporary mock data -- superseded by the repository layer in Step 10.
// ============================================================

const _mockBudgetOverview = BudgetOverviewData(
  totalBudgetLabel: '₹25.0L',
  allocatedLabel: '₹23.1L',
  utilizedLabel: '₹16.4L',
  remainingLabel: '₹6.68L',
  utilizationProgress: 0.71,
  healthLabel: 'Warning · 2 over',
  isHealthWarning: true,
  ownerName: 'Priya Deshmukh',
  version: 'v4',
  daysRemainingCaption: '5 days left',
);

const _mockBudgetCategories = <BudgetCategoryData>[
  BudgetCategoryData(
    id: 'decoration',
    name: 'Decoration',
    icon: Icons.style_outlined,
    allocatedLabel: '₹4,00,000',
    spentLabel: '₹4,18,200',
    progress: 1.04,
    percentLabel: '104%',
    ownerName: 'Priya Deshmukh',
  ),
  BudgetCategoryData(
    id: 'security',
    name: 'Security',
    icon: Icons.shield_outlined,
    allocatedLabel: '₹2,50,000',
    spentLabel: '₹1,95,000',
    progress: 0.78,
    percentLabel: '78%',
    ownerName: 'Amit Kulkarni',
  ),
  BudgetCategoryData(
    id: 'annadan',
    name: 'Annadan',
    icon: Icons.restaurant_outlined,
    allocatedLabel: '₹5,50,000',
    spentLabel: '₹4,10,000',
    progress: 0.75,
    percentLabel: '75%',
    ownerName: 'Priya Deshmukh',
  ),
  BudgetCategoryData(
    id: 'advertising',
    name: 'Advertising',
    icon: Icons.campaign_outlined,
    allocatedLabel: '₹1,20,000',
    spentLabel: '₹54,000',
    progress: 0.45,
    percentLabel: '45%',
    ownerName: 'Amit Kulkarni',
    footnote: 'under-used',
  ),
];

const _mockRevisions = <RevisionEntry>[
  RevisionEntry(
    version: 'v4',
    dateLabel: 'Today',
    title: 'Increased Lighting by ₹15,000',
    subtitle: 'Priya Deshmukh · awaiting President',
    isPending: true,
    isApproved: false,
  ),
  RevisionEntry(
    version: 'v3',
    dateLabel: '2 days ago',
    title: 'Reallocated ₹40,000: Advertising → Decoration',
    isPending: false,
    isApproved: true,
  ),
];

const _mockLinkedExpenses = <LinkedExpense>[
  LinkedExpense(
      dateLabel: '24 Jul',
      vendorName: 'Sai Decorators',
      amountLabel: '₹2,10,000',
      statusLabel: 'Pending',
      isPaid: false),
  LinkedExpense(
      dateLabel: '22 Jul',
      vendorName: 'Mandap Wale Bros.',
      amountLabel: '₹1,45,200',
      statusLabel: 'Paid',
      isPaid: true),
];

const _mockApprovalRequest = BudgetApprovalRequest(
  revisionVersion: 'v4',
  submittedBy: 'Priya Deshmukh',
  changes: [
    BudgetFieldChange(
        fieldLabel: 'Lighting',
        oldValueLabel: '₹1,80,000',
        newValueLabel: '₹1,95,000'),
  ],
  reason: 'Extra LED units needed for stage backdrop.',
  comments: [
    CommentEntry(
        authorName: 'Anil Joshi',
        authorRole: 'President',
        body: "Confirm this doesn't push Lighting over budget too."),
    CommentEntry(
        authorName: 'Priya Deshmukh',
        authorRole: 'Treasurer',
        body: 'Confirmed — still at 90%, within threshold.'),
  ],
);

const _mockApprovalSteps = [
  ApprovalStep(label: 'Submitted', state: StepState.done),
  ApprovalStep(label: 'Treasurer', state: StepState.done),
  ApprovalStep(label: 'President', state: StepState.current),
  ApprovalStep(label: 'Active', state: StepState.pending),
];

const _mockRevisionAdjustments = [
  RevisionAdjustment(
      categoryName: 'Decoration',
      currentAllocationLabel: '₹4,00,000',
      proposedAllocationLabel: '₹4,00,000'),
  RevisionAdjustment(
      categoryName: 'Lighting',
      currentAllocationLabel: '₹1,80,000',
      proposedAllocationLabel: '₹1,95,000'),
  RevisionAdjustment(
      categoryName: 'Advertising',
      currentAllocationLabel: '₹1,20,000',
      proposedAllocationLabel: '₹1,05,000'),
];

const _mockAuditSummary = AuditSummaryData(
  todayEventsCount: 128,
  criticalCount: 3,
  financialCount: 46,
  securityCount: 1,
);

const _mockAuditEvents = <AuditEventData>[
  AuditEventData(
    id: 'AUD-88213',
    timeLabel: '11:42 AM',
    title: 'Budget (Decoration) updated',
    actorName: 'Priya Deshmukh',
    moduleLabel: 'Financial',
    severity: Severity.medium,
    groupLabel: 'Today',
  ),
  AuditEventData(
    id: 'AUD-88210',
    timeLabel: '10:15 AM',
    title: 'Expense #EXP-2291 approved',
    actorName: 'Amit Kulkarni',
    moduleLabel: 'Financial',
    severity: Severity.low,
    groupLabel: 'Today',
  ),
  AuditEventData(
    id: 'AUD-88205',
    timeLabel: '9:58 AM',
    title: 'Role changed: Volunteer → Treasurer',
    actorName: 'Rahul S.',
    moduleLabel: 'Security',
    severity: Severity.critical,
    groupLabel: 'Today',
  ),
  AuditEventData(
    id: 'AUD-88190',
    timeLabel: '6:20 PM',
    title: 'Vendor payment marked overdue',
    actorName: 'System',
    moduleLabel: 'Financial',
    severity: Severity.high,
    groupLabel: 'Yesterday',
  ),
];

const _mockAuditDetail = AuditEventDetail(
  id: 'AUD-88213',
  moduleLabel: 'Budget',
  action: 'Category updated',
  performedBy: 'Priya Deshmukh (Treasurer)',
  timeLabel: '26 Jul, 11:42 AM',
  severity: Severity.medium,
  approvalStatusLabel: 'Not required',
  fieldChange: AuditFieldChange(
    fieldLabel: 'Decoration',
    oldValueLabel: '₹3,60,000',
    newValueLabel: '₹4,00,000',
  ),
  reason: 'Vendor quote increase',
  relatedEvents: [
    RelatedEvent(
        title: 'Budget revision v3 approved',
        timeAgoLabel: '2d ago',
        icon: Icons.check_circle_outline),
    RelatedEvent(
        title: 'Vendor Sai Decorators quote updated',
        timeAgoLabel: '2d ago',
        icon: Icons.storefront_outlined),
  ],
  metadata: AuditMetadata(
    ipAddress: '10.4.22.118',
    device: 'Android · Pixel 7',
    browser: 'Chrome 126',
    sessionId: 'sess_9f21…',
    requestId: 'req_2c88…',
    executionTimeLabel: '142ms',
  ),
);

const _mockSearchResults = <AuditSearchResult>[
  AuditSearchResult(
    icon: Icons.account_balance_wallet_outlined,
    beforeMatch: '',
    matchText: 'Sai Decorators',
    afterMatch: ' quote updated',
    moduleLabel: 'Budget',
    timeLabel: '2 days ago',
  ),
  AuditSearchResult(
    icon: Icons.receipt_long_outlined,
    beforeMatch: 'Expense approved for ',
    matchText: 'Sai Decorators',
    afterMatch: '',
    moduleLabel: 'Financial',
    timeLabel: '2 days ago',
  ),
];

const _mockNotificationSummary = NotificationSummaryData(
  unreadCount: 9,
  criticalCount: 2,
  approvalsCount: 3,
  paymentsDueCount: 4,
);

final _mockNotificationItems = <NotificationItemData>[
  NotificationItemData(
    id: 'ntf-1',
    icon: Icons.payments_outlined,
    iconBackground: Colors.orange.shade50,
    iconColor: Colors.orange.shade800,
    title: 'Vendor payment due tomorrow',
    description: 'Sai Decorators · ₹85,000',
    isUnread: true,
    primaryActionLabel: 'Pay Now',
    secondaryActionLabel: 'Snooze',
    groupLabel: 'Today',
  ),
  NotificationItemData(
    id: 'ntf-2',
    icon: Icons.volunteer_activism_outlined,
    iconBackground: Colors.green.shade50,
    iconColor: Colors.green.shade800,
    title: 'Donation received',
    description: '₹5,000 · Sharma family',
    isUnread: true,
    primaryActionLabel: 'View Receipt',
    groupLabel: 'Today',
  ),
  NotificationItemData(
    id: 'ntf-3',
    icon: Icons.check_circle_outline,
    iconBackground: Colors.grey.shade200,
    iconColor: Colors.grey.shade700,
    title: 'Expense approved',
    description: 'Fireworks vendor · ₹12,400',
    isUnread: false,
    groupLabel: 'Today',
  ),
];

const _mockNotificationDetail = NotificationDetailData(
  id: 'NTF-40213',
  title: 'Vendor payment due',
  priorityLabel: 'Payment Reminder · High',
  createdLabel: 'Today, 8:00 AM',
  triggeredBy: 'System (due-date rule)',
  statusLabel: 'Unread',
  contextLabel: 'DUE TOMORROW',
  contextValue: '₹85,000',
  contextSubtitle: 'Sai Decorators',
  linkedBudgetName: 'Decoration',
  linkedBudgetStatus: 'Over by ₹18,200',
  activityLog: [
    'Reminder sent · today, 8:00 AM',
    'Invoice attached · 3 days ago'
  ],
  attachmentName: 'invoice_sai_decorators.pdf',
  primaryActionLabel: 'Pay Now',
);

const _mockNotificationSettings = [
  NotificationCategorySetting(
    name: 'Payment reminders',
    description: 'Vendor & bill due dates',
    emailEnabled: true,
    pushEnabled: true,
    inAppEnabled: true,
  ),
  NotificationCategorySetting(
    name: 'Budget alerts',
    description: 'Threshold & approval events',
    emailEnabled: false,
    pushEnabled: true,
    inAppEnabled: true,
  ),
  NotificationCategorySetting(
    name: 'Milestone alerts',
    description: 'Delays & completions',
    emailEnabled: false,
    pushEnabled: false,
    inAppEnabled: true,
  ),
  NotificationCategorySetting(
    name: 'Audit alerts',
    description: 'Security & compliance',
    emailEnabled: true,
    pushEnabled: true,
    inAppEnabled: true,
    isLocked: true,
  ),
];
