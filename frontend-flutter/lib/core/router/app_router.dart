import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/ui/home_page.dart';
import '../../auth/ui/login_page.dart';

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
    initialLocation: '/login',
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
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/', redirect: (context, state) => '/login'),
    ],
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (!auth.sessionRestored) {
        return null;
      }

      final location = state.matchedLocation;
      final isLogin = location == '/login';
      final isAuthenticated = auth.isAuthenticated;

      if (!isAuthenticated && !isLogin) {
        final returnUrl = Uri.encodeComponent(state.uri.toString());
        return '/login?returnUrl=$returnUrl';
      }

      if (isAuthenticated && isLogin) {
        final returnUrl = sanitizeReturnUrl(
          state.uri.queryParameters['returnUrl'],
        );
        return returnUrl ?? '/home';
      }

      return null;
    },
  );

  ref.listen(authControllerProvider, (_, __) {
    router.refresh();
  });

  ref.onDispose(router.dispose);
  return router;
});
