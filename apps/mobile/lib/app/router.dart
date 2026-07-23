import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'home_screen.dart';

/// Root app router. Kept intentionally minimal for the foundation phase --
/// one route proving `go_router` is wired end-to-end through Riverpod.
/// Authenticated/tenant-scoped route trees land with their owning feature
/// phases, alongside the `(organizationId, eventId)` context-switch guard.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
