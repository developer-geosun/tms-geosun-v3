import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../settings/app_settings_sheet.dart';

/// Кнопка налаштувань — відкриває нижню панель (мова + оформлення).
class AppSettingsButton extends StatelessWidget {
  const AppSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: l10n.settingsButtonLabel,
      onPressed: () => showAppSettingsSheet(context),
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
