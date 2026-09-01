import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/app_logout_button.dart';
import '../../core/widgets/app_settings_button.dart';
import '../state/auth_controller.dart';

/// Заглушка після входу: показує профіль користувача.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: const [AppLogoutButton(), AppSettingsButton()],
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
          ],
        ),
      ),
    );
  }
}
