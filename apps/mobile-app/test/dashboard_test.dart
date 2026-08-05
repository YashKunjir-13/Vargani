import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/session/session_state.dart';
import 'package:pauti_pustak_mobile/features/dashboard/dashboard.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        initialSessionStateProvider.overrideWithValue(SessionState.unauthenticated),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('MandalDashboardScreen renders header, quick actions, modules and navigation', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const MandalDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Shree Siddhivinayak Ganpati Mandal'), findsWidgets);
    expect(find.text('FESTIVAL OVERVIEW'), findsOneWidget);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
    expect(find.text('MAIN MODULES'), findsOneWidget);
    expect(find.text('Contribution Management'), findsOneWidget);
  });

  testWidgets('DonorDashboardScreen renders header, summary cards, quick actions and receipts', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const DonorDashboardScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Ramesh Shivaji Patil'), findsWidgets);
    expect(find.text('YOUR CONTRIBUTION OVERVIEW'), findsOneWidget);
    expect(find.text('KEY HIGHLIGHTS'), findsOneWidget);
    expect(find.text('QUICK ACTIONS'), findsOneWidget);
  });
}
