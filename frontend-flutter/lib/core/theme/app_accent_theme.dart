import 'package:flutter/material.dart';

/// Акцентні кольори (як у flutter-test Design Playground).
enum AppAccentTheme {
  indigo('indigo'),
  emerald('emerald'),
  amber('amber'),
  raspberry('raspberry');

  const AppAccentTheme(this.storageKey);

  final String storageKey;

  /// Seed-колір для ColorScheme.fromSeed (Material 3).
  Color get seedColor => switch (this) {
    AppAccentTheme.indigo => const Color(0xFF4F46E5),
    AppAccentTheme.emerald => const Color(0xFF10B981),
    AppAccentTheme.amber => const Color(0xFFF59E0B),
    AppAccentTheme.raspberry => const Color(0xFFE11D48),
  };

  static AppAccentTheme fromStorageKey(String? key) {
    return switch (key) {
      'indigo' => AppAccentTheme.indigo,
      'emerald' => AppAccentTheme.emerald,
      'amber' => AppAccentTheme.amber,
      'raspberry' => AppAccentTheme.raspberry,
      // Міграція зі старих ключів Angular / попередньої версії Flutter.
      'azure-blue' => AppAccentTheme.indigo,
      'rose-red' => AppAccentTheme.raspberry,
      'magenta-violet' => AppAccentTheme.indigo,
      'cyan-orange' => AppAccentTheme.amber,
      _ => AppAccentTheme.indigo,
    };
  }
}
