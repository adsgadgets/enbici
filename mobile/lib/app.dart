import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_verification_screen.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/cyclist/screens/cyclist_dashboard_screen.dart';
import 'features/cyclist/screens/request_ride_screen.dart';
import 'features/cyclist/screens/ride_in_progress_screen.dart';

class EnBiciApp extends ConsumerWidget {
  const EnBiciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'EnBici',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

// ──────────────────────────────────────
// Router
// ──────────────────────────────────────

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/otp') ||
          state.matchedLocation.startsWith('/role');

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && isOnAuth) return '/cyclist/dashboard';
      return null;
    },
    routes: [
      // ── Auth ──
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final phone = state.extra as String;
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/role',
        builder: (_, __) => const RoleSelectionScreen(),
      ),

      // ── Ciclista ──
      GoRoute(
        path: '/cyclist/dashboard',
        builder: (_, __) => const CyclistDashboardScreen(),
      ),
      GoRoute(
        path: '/cyclist/request',
        builder: (_, __) => const RequestRideScreen(),
      ),
      GoRoute(
        path: '/cyclist/ride/:rideId',
        builder: (_, state) {
          final rideId = state.pathParameters['rideId']!;
          return RideInProgressScreen(rideId: rideId);
        },
      ),
    ],
  );
});
