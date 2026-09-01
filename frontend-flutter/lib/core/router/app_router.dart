import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/ui/forgot_password_page.dart';
import '../../auth/ui/home_page.dart';
import '../../auth/ui/login_page.dart';
import '../../auth/ui/register_page.dart';
import '../../auth/ui/reset_password_page.dart';
import '../../auth/ui/verify_email_page.dart';
import '../../core/shell/app_shell.dart';
import '../../features/directories/ui/countries_directory_page.dart';
import '../../features/directories/ui/currencies_directory_page.dart';
import '../../features/directories/ui/directories_page.dart';
import '../../features/directories/ui/exchange_rates_directory_page.dart';

/// Безпечний returnUrl: лише відносний шлях без protocol-relative URL.
String? sanitizeReturnUrl(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  if (!raw.startsWith('/') || raw.startsWith('//')) {
    return null;
  }
  return raw;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    // На web береться path з адресного рядка (листи /reset-password?token=).
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final returnUrl = sanitizeReturnUrl(
            state.uri.queryParameters['returnUrl'],
          );
          return LoginPage(returnUrl: returnUrl);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final token = state.uri.queryParameters['token']?.trim();
          return VerifyEmailPage(token: token);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token']?.trim();
          return ResetPasswordPage(token: token);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/directories',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DirectoriesPage()),
          ),
          GoRoute(
            path: '/directories/countries',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CountriesDirectoryPage()),
          ),
          GoRoute(
            path: '/directories/currencies',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CurrenciesDirectoryPage()),
          ),
          GoRoute(
            path: '/directories/exchange-rates',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExchangeRatesDirectoryPage()),
          ),
        ],
      ),
      GoRoute(path: '/', redirect: (context, state) => '/login'),
    ],
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (!auth.sessionRestored) {
        return null;
      }

      final location = state.matchedLocation;
      final isGuestRoute =
          location == '/login' ||
          location == '/register' ||
          location == '/verify-email' ||
          location == '/forgot-password' ||
          location == '/reset-password';
      final isAuthenticated = auth.isAuthenticated;

      if (!isAuthenticated && !isGuestRoute) {
        final returnUrl = Uri.encodeComponent(state.uri.toString());
        return '/login?returnUrl=$returnUrl';
      }

      if (isAuthenticated && isGuestRoute) {
        // Посилання з листа мають відкритися навіть за наявності сесії.
        if (location == '/verify-email' || location == '/reset-password') {
          return null;
        }
        final returnUrl = sanitizeReturnUrl(
          state.uri.queryParameters['returnUrl'],
        );
        return returnUrl ?? '/home';
      }

      return null;
    },
  );

  ref.listen(authControllerProvider, (_, _) {
    router.refresh();
  });

  ref.onDispose(router.dispose);
  return router;
});
