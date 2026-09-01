import 'package:flutter/material.dart';

/// Акцентні теми (1:1 з Angular ThemeService).
enum AppAccentTheme {
  azureBlue('azure-blue'),
  roseRed('rose-red'),
  magentaViolet('magenta-violet'),
  cyanOrange('cyan-orange');

  const AppAccentTheme(this.storageKey);

  final String storageKey;

  Brightness get brightness => switch (this) {
    AppAccentTheme.azureBlue || AppAccentTheme.roseRed => Brightness.light,
    AppAccentTheme.magentaViolet ||
    AppAccentTheme.cyanOrange => Brightness.dark,
  };

  /// Seed-колір для ColorScheme.fromSeed (наближено до Angular M3 palettes).
  Color get seedColor => switch (this) {
    AppAccentTheme.azureBlue => const Color(0xFF005FB8),
    AppAccentTheme.roseRed => const Color(0xFF984061),
    AppAccentTheme.magentaViolet => const Color(0xFF9700AA),
    AppAccentTheme.cyanOrange => const Color(0xFF0A6A6C),
  };

  /// Другий акцент для превʼю (tertiary у Angular).
  Color get previewAccentColor => switch (this) {
    AppAccentTheme.azureBlue => const Color(0xFF4A7FD7),
    AppAccentTheme.roseRed => const Color(0xFFE46962),
    AppAccentTheme.magentaViolet => const Color(0xFF7F39FB),
    AppAccentTheme.cyanOrange => const Color(0xFFFF8C42),
  };

  static AppAccentTheme fromStorageKey(String? key) {
    return AppAccentTheme.values.firstWhere(
      (theme) => theme.storageKey == key,
      orElse: () => AppAccentTheme.azureBlue,
    );
  }
}
