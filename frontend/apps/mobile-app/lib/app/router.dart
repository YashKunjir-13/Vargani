import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_controller.dart';
import '../shared/screens/access_restricted_screen.dart';
import '../features/analytics/presentation/pages/analytical_dashboard_screen.dart'
    as pauti_analytics;
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
import '../features/contribution_receipts/screens/contribution_receipt_detail_screen.dart';
import '../features/contribution_receipts/screens/contribution_receipts_list_screen.dart';
import '../features/contributions/screens/contribution_detail_screen.dart';
import '../features/contributions/screens/contributions_list_screen.dart';
import '../features/contributions/screens/create_contribution_screen.dart';
import '../features/contributions/screens/gold_silver_entry_screen.dart';
import '../features/dashboard/presentation/pages/mandal_dashboard_screen.dart';
import '../features/dashboard/presentation/pages/donor_dashboard_screen.dart';
import '../features/milestones/presentation/pages/milestones_screen.dart';
import '../features/rbac/presentation/pages/user_management_screen.dart';
import '../features/rbac/presentation/providers/mock_rbac_provider.dart';
import '../features/donors/screens/donor_detail_screen.dart';
import '../features/donors/screens/donor_form_screen.dart';
import '../features/donors/screens/donor_list_screen.dart';
import '../features/financial_accounts/screens/ledger_screen.dart';
import '../features/notifications/advanced_filters_sheet.dart';
import '../features/notifications/models/notification_models.dart';
import '../features/notifications/notification_center_screen.dart';
import '../features/notifications/notification_detail_screen.dart';
import '../features/notifications/notification_settings_screen.dart';

import '../features/payments/screens/payment_detail_screen.dart';
import '../features/payments/screens/payments_list_screen.dart';
import '../features/payments/screens/select_event_screen.dart';
import '../features/payments/screens/select_donor_screen.dart';
import '../features/payments/screens/donation_amount_screen.dart';
import '../features/payments/screens/donation_details_screen.dart';
import '../features/payments/screens/payment_method_screen.dart';
import '../features/payments/screens/payment_review_screen.dart';
import '../features/payments/screens/payment_processing_screen.dart';
import '../features/payments/screens/mock_payment_screen.dart';
import '../features/payments/screens/payment_result_screens.dart';
import '../features/payments/screens/donation_receipt_screen.dart';
import '../features/receipts/screens/receipt_detail_screen.dart';
import '../features/receipts/screens/receipts_list_screen.dart';
import '../features/reports/screens/reports_hub_screen.dart';
import '../features/sponsorship_advertisement/screens/advertisement_detail_screen.dart';
import '../features/sponsorship_advertisement/screens/advertisement_form_screen.dart';
import '../features/sponsorship_advertisement/screens/advertisement_list_screen.dart';
import '../features/sponsorship_advertisement/screens/sponsorship_detail_screen.dart';
import '../features/sponsorship_advertisement/screens/sponsorship_form_screen.dart';
import '../features/sponsorship_advertisement/screens/sponsorship_list_screen.dart';
import '../features/templates/screens/template_calibration_screen.dart';
import '../features/vault/screens/cash_counting_vault_screen.dart';
import '../features/vendors/screens/vendor_detail_screen.dart';
import '../features/vendors/screens/vendor_form_screen.dart';
import '../features/vendors/screens/vendor_list_screen.dart';
import '../features/volunteers/screens/volunteer_detail_screen.dart';
import '../features/volunteers/screens/volunteer_form_screen.dart';
import '../features/volunteers/screens/volunteer_list_screen.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';
import 'all_records_screen.dart';
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
                  child: const SelectEventScreen(),
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
          // --- 10-Step Donation Payment Journey ---
          GoRoute(
            path: '/donation/select-event',
            name: 'donation-select-event',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const SelectEventScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/select-donor',
            name: 'donation-select-donor',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const SelectDonorScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/amount',
            name: 'donation-amount',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const DonationAmountScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/details',
            name: 'donation-details',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const DonationDetailsScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/payment-method',
            name: 'donation-payment-method',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PaymentMethodScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/review',
            name: 'donation-review',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PaymentReviewScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/processing',
            name: 'donation-processing',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PaymentProcessingScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/mock-gateway',
            name: 'donation-mock-gateway',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const MockPaymentScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/result',
            name: 'donation-result',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PaymentResultScreen(),
            ),
          ),
          GoRoute(
            path: '/donation/receipt',
            name: 'donation-receipt',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const DonationReceiptScreen(),
            ),
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
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context, listen: false);
          final rbac = container.read(mockRbacProvider);
          if (!rbac.hasPermission('budget.view')) {
            return '/access-restricted?title=Budget%20Management';
          }
          return null;
        },
        builder: (context, state) => BudgetOverviewScreen(
          onOpenFilters: () => BudgetFiltersSheet.show(context),
          onOpenExport: () => ExportBudgetSheet.show(context),
          onOpenTable: () => context.pushNamed('budget-table'),
          onCreateRevision: () => context.pushNamed('budget-revision'),
          onOpenCategory: (category) =>
              context.pushNamed('budget-details', extra: category.id),
          onOpenRevision: (revision) =>
              context.pushNamed('budget-approval', extra: revision.id),
        ),
        routes: [
          GoRoute(
            path: 'table',
            name: 'budget-table',
            builder: (context, state) => const BudgetTableScreen(),
          ),
          GoRoute(
            path: 'details',
            name: 'budget-details',
            builder: (context, state) => BudgetDetailsScreen(
              categoryId: (state.extra as String?) ?? '',
            ),
          ),
          GoRoute(
            path: 'approval',
            name: 'budget-approval',
            builder: (context, state) => BudgetApprovalScreen(
              revisionId: (state.extra as String?) ?? '',
            ),
          ),
          GoRoute(
            path: 'revision',
            name: 'budget-revision',
            builder: (context, state) => const BudgetRevisionScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/milestones',
        name: 'milestones',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context, listen: false);
          final rbac = container.read(mockRbacProvider);
          if (!rbac.hasPermission('milestones.view')) {
            return '/access-restricted?title=Milestones%20%26%20Work';
          }
          return null;
        },
        builder: (context, state) => const MilestonesScreen(),
      ),
      GoRoute(
        path: '/user-management',
        name: 'user-management',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context, listen: false);
          final rbac = container.read(mockRbacProvider);
          if (!rbac.hasPermission('user.manage')) {
            return '/access-restricted?title=User%20Management';
          }
          return null;
        },
        builder: (context, state) => const UserManagementScreen(),
      ),

      // ---------------- Audit Log ----------------
      GoRoute(
        path: '/audit',
        name: 'audit',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context, listen: false);
          final rbac = container.read(mockRbacProvider);
          if (!rbac.hasPermission('audit_logs.view')) {
            return '/access-restricted?title=Audit%20Log';
          }
          return null;
        },
        builder: (context, state) => AuditOverviewScreen(
          onOpenEvent: (event) => context
              .pushNamed('audit-detail', pathParameters: {'id': event.id}),
          onOpenSearch: () => context.pushNamed('audit-search'),
          onOpenFilters: () => AuditFiltersSheet.show(context),
        ),
        routes: [
          GoRoute(
            path: 'timeline',
            name: 'audit-timeline',
            builder: (context, state) => AuditTimelineScreen(
              onOpenEvent: (event) => context
                  .pushNamed('audit-detail', pathParameters: {'id': event.id}),
            ),
          ),
          GoRoute(
            path: 'detail/:id',
            name: 'audit-detail',
            builder: (context, state) => AuditDetailScreen(
              eventId: state.pathParameters['id']!,
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

      // ---------------- Master Records & Feature Modules ----------------
      GoRoute(
        path: '/records',
        name: 'records',
        builder: (context, state) => const AllRecordsScreen(),
      ),
      GoRoute(
        path: '/donors',
        name: 'donors',
        builder: (context, state) => const DonorListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'donors-new',
            builder: (context, state) => const DonorFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'donors-detail',
            builder: (context, state) =>
                DonorDetailScreen(donorId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/vendors',
        name: 'vendors',
        builder: (context, state) => const VendorListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'vendors-new',
            builder: (context, state) => const VendorFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'vendors-detail',
            builder: (context, state) =>
                VendorDetailScreen(vendorId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/volunteers',
        name: 'volunteers',
        builder: (context, state) => const VolunteerListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'volunteers-new',
            builder: (context, state) => const VolunteerFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'volunteers-detail',
            builder: (context, state) =>
                VolunteerDetailScreen(volunteerId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/sponsorships',
        name: 'sponsorships',
        builder: (context, state) => const SponsorshipListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'sponsorships-new',
            builder: (context, state) => const SponsorshipFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'sponsorships-detail',
            builder: (context, state) => SponsorshipDetailScreen(
                sponsorshipId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/advertisements',
        name: 'advertisements',
        builder: (context, state) => const AdvertisementListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'advertisements-new',
            builder: (context, state) => const AdvertisementFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'advertisements-detail',
            builder: (context, state) => AdvertisementDetailScreen(
                advertisementId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/vault',
        name: 'vault',
        builder: (context, state) => const CashCountingVaultScreen(),
      ),
      GoRoute(
        path: '/ledger',
        name: 'ledger',
        builder: (context, state) => const LedgerScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context, listen: false);
          final rbac = container.read(mockRbacProvider);
          if (!rbac.hasPermission('analytics.view')) {
            return '/access-restricted?title=Analytics';
          }
          return null;
        },
        builder: (context, state) =>
            const pauti_analytics.AnalyticalDashboardScreen(),
      ),
      GoRoute(
        path: '/reports-hub',
        name: 'reports-hub',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context, listen: false);
          final rbac = container.read(mockRbacProvider);
          if (!rbac.hasPermission('reports.view')) {
            return '/access-restricted?title=Reports';
          }
          return null;
        },
        builder: (context, state) => const ReportsHubScreen(),
      ),
      GoRoute(
        path: '/access-restricted',
        name: 'access-restricted',
        builder: (context, state) => AccessRestrictedScreen(
          moduleTitle: state.uri.queryParameters['title'],
        ),
      ),
      GoRoute(
        path: '/gold-silver-entry',
        name: 'gold-silver-entry',
        builder: (context, state) => const GoldSilverEntryScreen(),
      ),
    ],
  );
});

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
  unreadCount: 0,
  criticalCount: 0,
  approvalsCount: 0,
  paymentsDueCount: 0,
);

final _mockNotificationItems = <NotificationItemData>[];

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
