import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/locale_controller.dart';
import 'app_accent_theme.dart';

const themeStorageKey = 'app-theme';
const themeModeStorageKey = 'app-theme-mode';

final themeProvider = NotifierProvider<ThemeNotifier, AppAccentTheme>(
  ThemeNotifier.new,
);

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Збереження акцентної теми (той самий ключ app-theme, що й у Angular).
class ThemeNotifier extends Notifier<AppAccentTheme> {
  @override
  AppAccentTheme build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(themeStorageKey);

    if (saved == 'light') {
      return AppAccentTheme.indigo;
    }
    if (saved == 'dark') {
      return AppAccentTheme.indigo;
    }

    return AppAccentTheme.fromStorageKey(saved);
  }

  Future<void> setTheme(AppAccentTheme theme) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(themeStorageKey, theme.storageKey);
    state = theme;
  }
}

/// Світла / системна / темна — як у flutter-test Design Playground.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(themeModeStorageKey);
    final legacyTheme = prefs.getString(themeStorageKey);

    if (saved == 'light' || saved == 'system' || saved == 'dark') {
      return ThemeMode.values.firstWhere(
        (mode) => mode.name == saved,
        orElse: () => ThemeMode.system,
      );
    }

    // Зворотна сумісність: старі значення app-theme light/dark.
    if (legacyTheme == 'light') {
      return ThemeMode.light;
    }
    if (legacyTheme == 'dark') {
      return ThemeMode.dark;
    }

    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(themeModeStorageKey, mode.name);
    state = mode;
  }
}
