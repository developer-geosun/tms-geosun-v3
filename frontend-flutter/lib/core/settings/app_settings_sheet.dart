import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_accent_theme.dart';
import '../theme/theme_controller.dart';

/// Відкриває нижню панель налаштувань (мова + оформлення).
void showAppSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const AppSettingsSheet(),
  );
}

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final currentLanguage = AppLanguage.fromCode(locale.languageCode);
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(themeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsAppearanceTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.settingsLanguageSection,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<AppLanguage>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: AppLanguage.uk,
                  label: Text(l10n.languageUkShort),
                ),
                ButtonSegment(
                  value: AppLanguage.en,
                  label: Text(l10n.languageEnShort),
                ),
                ButtonSegment(
                  value: AppLanguage.ru,
                  label: Text(l10n.languageRuShort),
                ),
              ],
              selected: {currentLanguage},
              onSelectionChanged: (selection) {
                ref.read(localeProvider.notifier).setLanguage(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              l10n.settingsThemeModeSection,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeModeLight),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.themeModeSystem),
                  icon: const Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeModeDark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              l10n.settingsAccentColorSection,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final option in AppAccentTheme.values)
                  _AccentSwatch(
                    accent: option,
                    label: _accentLabel(l10n, option),
                    selected: option == accent,
                    onTap: () {
                      ref.read(themeProvider.notifier).setTheme(option);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _accentLabel(AppLocalizations l10n, AppAccentTheme accent) {
    return switch (accent) {
      AppAccentTheme.azureBlue => l10n.themeAzureBlue,
      AppAccentTheme.roseRed => l10n.themeRoseRed,
      AppAccentTheme.magentaViolet => l10n.themeMagentaViolet,
      AppAccentTheme.cyanOrange => l10n.themeCyanOrange,
    };
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppAccentTheme accent;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.seedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : null,
        ),
      ),
    );
  }
}
