import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../l10n/app_localizations.dart';
import 'app_elevated_icon_button.dart';

/// Кнопка виходу — іконка в AppBar, ліворуч від налаштувань.
class AppLogoutButton extends ConsumerStatefulWidget {
  const AppLogoutButton({super.key});

  @override
  ConsumerState<AppLogoutButton> createState() => _AppLogoutButtonState();
}

class _AppLogoutButtonState extends ConsumerState<AppLogoutButton> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppElevatedIconButton(
      tooltip: _isLoggingOut ? l10n.homeLogoutLoading : l10n.homeLogout,
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout_outlined),
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
