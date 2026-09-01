import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_settings_button.dart';
import '../state/auth_controller.dart';

/// Заглушка після входу: показує профіль і дозволяє перевірити logout.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: const [AppSettingsButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeWelcome,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(user?.email ?? '—'),
            const SizedBox(height: 16),
            Text('${l10n.homeRoleLabel}: ${user?.role.name ?? '—'}'),
            const Spacer(),
            FilledButton(
              onPressed: _isLoggingOut ? null : _logout,
              child: _isLoggingOut
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.homeLogoutLoading),
                      ],
                    )
                  : Text(l10n.homeLogout),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authControllerProvider.notifier).logout();
      if (!mounted) {
        return;
      }
      context.go('/login');
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }
}
