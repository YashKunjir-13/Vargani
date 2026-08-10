import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/dashboard/dashboard.dart';
import 'helpers/test_wrapper.dart';

void main() {
  group('Dashboard Screens — GIVEN-WHEN-THEN UI States', () {
    testWidgets(
      'GIVEN an active Mandal session WHEN MandalDashboardScreen is rendered THEN shows header, overview cards, and module navigation',
      (tester) async {
        await tester.pumpWidget(createTestableWidget(child: const MandalDashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Shree Siddhivinayak Ganpati Mandal'), findsWidgets);
        expect(find.text('FESTIVAL OVERVIEW'), findsOneWidget);
        expect(find.text('QUICK ACTIONS'), findsOneWidget);
        expect(find.text('MAIN MODULES'), findsOneWidget);
        expect(find.text('Contribution Management'), findsOneWidget);
      },
    );

    testWidgets(
      'GIVEN an active Donor session WHEN DonorDashboardScreen is rendered THEN shows donor profile, overview, highlights and receipts',
      (tester) async {
        await tester.pumpWidget(createTestableWidget(child: const DonorDashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Ramesh Shivaji Patil'), findsWidgets);
        expect(find.text('YOUR CONTRIBUTION OVERVIEW'), findsOneWidget);
        expect(find.text('KEY HIGHLIGHTS'), findsOneWidget);
        expect(find.text('QUICK ACTIONS'), findsOneWidget);
      },
    );
  });
}
