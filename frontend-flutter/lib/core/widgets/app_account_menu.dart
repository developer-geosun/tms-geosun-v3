import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../l10n/app_localizations.dart';
import '../settings/app_settings_sheet.dart';
import 'app_elevated_icon_button.dart';

/// Меню облікового запису в AppBar: налаштування та вихід.
class AppAccountMenu extends ConsumerStatefulWidget {
  const AppAccountMenu({super.key});

  @override
  ConsumerState<AppAccountMenu> createState() => _AppAccountMenuState();
}

class _AppAccountMenuState extends ConsumerState<AppAccountMenu> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MenuAnchor(
      builder: (context, controller, child) {
        return AppElevatedIconButton(
          tooltip: _isLoggingOut
              ? l10n.homeLogoutLoading
              : l10n.accountMenuLabel,
          onPressed: _isLoggingOut
              ? null
              : () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
          icon: _isLoggingOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.account_circle_outlined),
        );
      },
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.settings_outlined),
          onPressed: () => showAppSettingsSheet(context),
          child: Text(l10n.settingsButtonLabel),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout_outlined),
          onPressed: _logout,
          child: Text(l10n.homeLogout),
        ),
      ],
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
