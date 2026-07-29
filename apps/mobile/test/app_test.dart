import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/app/app.dart';

import 'package:pauti_pustak_mobile/core/session/session_controller.dart';
import 'package:pauti_pustak_mobile/core/session/session_state.dart';

void main() {
  testWidgets(
      'PautiPustakApp starts on the registration landing screen via go_router',
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

    expect(find.text('Pauti Pustak'), findsOneWidget);
    expect(find.text('REGISTER — SELECT TYPE'), findsOneWidget);
  });
}
