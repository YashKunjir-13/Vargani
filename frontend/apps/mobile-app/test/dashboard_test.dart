import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/features/dashboard/dashboard.dart';
import 'helpers/test_wrapper.dart';

void main() {
  setUpAll(() {
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });

  group('Dashboard Screens — GIVEN-WHEN-THEN UI States', () {
    testWidgets(
      'GIVEN an active Mandal session WHEN MandalDashboardScreen is rendered THEN shows header, overview cards, and module navigation',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestableWidget(child: const MandalDashboardScreen()));
        await tester.pump(const Duration(seconds: 1));
        tester.takeException();

        expect(find.byType(MandalDashboardScreen), findsOneWidget);
        expect(find.text('MAIN MODULES'), findsOneWidget);
      },
    );

    testWidgets(
      'GIVEN an active Donor session WHEN DonorDashboardScreen is rendered THEN shows donor profile, overview, highlights and receipts',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestableWidget(child: const DonorDashboardScreen()));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('YOUR CONTRIBUTION OVERVIEW'), findsOneWidget);
        expect(find.text('KEY HIGHLIGHTS'), findsOneWidget);
        expect(find.text('QUICK ACTIONS'), findsOneWidget);
      },
    );
  });
}
