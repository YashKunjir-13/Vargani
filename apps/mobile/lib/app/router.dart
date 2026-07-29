import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_controller.dart';
import '../features/authentication/authentication.dart';
import '../features/authentication/data/models/auth_models.dart';
import '../features/dashboard/dashboard.dart';

/// Notifies go_router's redirect logic to re-run whenever the session state
/// changes (login, logout, restore), without recreating the whole router.
class _SessionRefreshNotifier extends ChangeNotifier {
  _SessionRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (_, __) => notifyListeners());
  }
}

/// Root app router, keyed by the app environment.
///
/// The registration landing screen is the product entry point for signed-out
/// users in every environment; authenticated users are redirected to their dashboard based on role.
final appRouterProvider = Provider.family<GoRouter, String>((ref, environment) {
  final refreshNotifier = _SessionRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/register',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isDashboardRoute = state.matchedLocation == '/mandal-dashboard' || state.matchedLocation == '/donor-dashboard';

      if (!session.isAuthenticated && !isAuthRoute) {
        return '/register';
      }

      if (session.isAuthenticated) {
        final targetRoute = (session.activeRole == LoginRole.donor) ? '/donor-dashboard' : '/mandal-dashboard';

        if (isAuthRoute || state.matchedLocation == '/') {
          return targetRoute;
        }

        // Prevent donor from accessing mandal dashboard directly or vice versa
        if (isDashboardRoute && state.matchedLocation != targetRoute) {
          return targetRoute;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          final session = ref.watch(sessionControllerProvider);
          if (session.activeRole == LoginRole.donor) {
            return const DonorDashboardScreen();
          }
          return const MandalDashboardScreen();
        },
      ),
      GoRoute(
        path: '/mandal-dashboard',
        name: 'mandal-dashboard',
        builder: (context, state) => const MandalDashboardScreen(),
      ),
      GoRoute(
        path: '/donor-dashboard',
        name: 'donor-dashboard',
        builder: (context, state) => const DonorDashboardScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(
          onBackToRegistration: () => context.go('/register'),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegistrationPage(
          onLoginRequested: () => context.go('/login'),
        ),
      ),
    ],
  );
});

