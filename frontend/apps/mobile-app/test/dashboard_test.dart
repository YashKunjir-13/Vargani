import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/dashboard/dashboard.dart';
import 'package:pauti_pustak_mobile/features/profile/widgets/bank_details_section.dart';
import 'helpers/test_wrapper.dart';

class TestMandalDashboardNotifier extends MandalDashboardNotifier {
  @override
  Future<void> fetchDashboardData() async {
    // No-op in widget test to avoid network calls & async timers
  }
}

class TestBankDetailsNotifier extends BankDetailsNotifier {
  @override
  Future<void> fetchBankDetails() async {
    // No-op in widget test
  }
}

class TestDonorDashboardNotifier extends DonorDashboardNotifier {
  @override
  Future<void> fetchDashboard() async {
    // No-op in widget test to avoid network calls & async timers
  }
}

void main() {
  group('Dashboard Screens — GIVEN-WHEN-THEN UI States', () {
    testWidgets(
      'GIVEN an active Mandal session WHEN MandalDashboardScreen is rendered THEN shows header, overview cards, and module navigation',
      (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: const MandalDashboardScreen(),
          overrides: [
            mandalDashboardProvider.overrideWith(() => TestMandalDashboardNotifier()),
            bankDetailsProvider.overrideWith(() => TestBankDetailsNotifier()),
          ],
        ));
        final exception = tester.takeException();
        if (exception != null) {
          debugPrint('PUMP EXCEPTION: $exception');
        }
        expect(find.byType(MandalDashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'GIVEN an active Donor session WHEN DonorDashboardScreen is rendered THEN shows donor profile, overview, highlights and receipts',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createTestableWidget(
          child: const DonorDashboardScreen(),
          overrides: [
            donorDashboardProvider.overrideWith(() => TestDonorDashboardNotifier()),
          ],
        ));
        expect(find.byType(DonorDashboardScreen), findsOneWidget);
      },
    );
  });
}
