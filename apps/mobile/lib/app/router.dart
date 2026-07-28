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
import 'home_screen.dart';

/// Root app router with all 6 core modules and Template Calibration wired.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/templates',
        name: 'templates',
        builder: (context, state) => const TemplateCalibrationScreen(),
      ),
      GoRoute(
        path: '/payments',
        name: 'payments',
        builder: (context, state) => const PaymentsListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'payments-new',
            builder: (context, state) => const CreatePaymentScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'payments-detail',
            builder: (context, state) => PaymentDetailScreen(paymentId: state.pathParameters['id']!),
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
            builder: (context, state) => ReceiptDetailScreen(receiptId: state.pathParameters['id']!),
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
            builder: (context, state) => const CreateBillScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'bills-detail',
            builder: (context, state) => BillDetailScreen(billId: state.pathParameters['id']!),
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
            builder: (context, state) => const CreateContributionScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'contributions-detail',
            builder: (context, state) => ContributionDetailScreen(contributionId: state.pathParameters['id']!),
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
            builder: (context, state) => ContributionReceiptDetailScreen(receiptId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
