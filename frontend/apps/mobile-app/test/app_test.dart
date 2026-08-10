import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/app/app.dart';

import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/session/session_state.dart';

import 'package:pauti_pustak_mobile/features/authentication/presentation/pages/registration_page.dart';

void main() {
  testWidgets(
      'GIVEN an unauthenticated session WHEN PautiPustakApp starts THEN routes to the registration landing screen via go_router',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSessionStateProvider.overrideWithValue(SessionState.unauthenticated),
        ],
        child: const PautiPustakApp(environment: 'test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RegistrationPage), findsOneWidget);
  });
}
