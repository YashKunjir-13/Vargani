import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pauti_pustak_mobile/core/core.dart';
import 'package:pauti_pustak_mobile/shared/shared.dart';

void main() {
  testWidgets('RoleGate toggles child visibility based on selected role',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              final currentRole = ref.watch(roleProvider);
              return Scaffold(
                body: Column(
                  children: [
                    DropdownButton<Role>(
                      value: currentRole,
                      items: Role.values
                          .map(
                            (role) => DropdownMenuItem<Role>(
                              value: role,
                              child: Text(role.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(roleProvider.notifier).setRole(value);
                        }
                      },
                    ),
                    RoleGate(
                      allowedRoles: const [Role.treasurer],
                      child: const Text('Treasurer only'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Treasurer only'), findsNothing);

    await tester.tap(find.byType(DropdownButton<Role>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('treasurer').last);
    await tester.pumpAndSettle();

    expect(find.text('Treasurer only'), findsOneWidget);
  });
}
