import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/app/app.dart';

void main() {
  testWidgets('PautiPustakApp renders the home screen via go_router',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PautiPustakApp(environment: 'test'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pauti Pustak'), findsOneWidget);
    expect(find.text('Shree Ganesh Mandal'), findsOneWidget);
    expect(find.text('Core App Modules'), findsOneWidget);
  });
}
