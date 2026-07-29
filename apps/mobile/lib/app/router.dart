import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bills/screens/bill_detail_screen.dart';
import '../features/bills/screens/bills_list_screen.dart';
import '../features/bills/screens/create_bill_screen.dart';
import '../features/contribution_receipts/screens/contribution_receipt_detail_screen.dart';
import '../features/contribution_receipts/screens/contribution_receipts_list_screen.dart';
import '../features/contributions/screens/contribution_detail_screen.dart';
import '../features/contributions/screens/contributions_list_screen.dart';
import '../features/contributions/screens/create_contribution_screen.dart';
import '../features/payments/screens/create_payment_screen.dart';
import '../features/payments/screens/payment_detail_screen.dart';
import '../features/payments/screens/payments_list_screen.dart';
import '../features/receipts/screens/receipt_detail_screen.dart';
import '../features/receipts/screens/receipts_list_screen.dart';
import '../features/templates/screens/template_calibration_screen.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';
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

/// Root app router configured with ShellRoute for persistent bottom navigation & smooth transitions.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
                  child: PaymentDetailScreen(paymentId: state.pathParameters['id']!),
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
                  child: ReceiptDetailScreen(receiptId: state.pathParameters['id']!),
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
                  child: ContributionDetailScreen(contributionId: state.pathParameters['id']!),
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
                  child: ContributionReceiptDetailScreen(receiptId: state.pathParameters['id']!),
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
    ],
  );
});

