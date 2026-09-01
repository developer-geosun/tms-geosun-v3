import 'package:flutter/material.dart';

import 'app_accent_theme.dart';

/// Світла Material 3 тема з обраним акцентом.
ThemeData buildLightAppTheme(AppAccentTheme accent) =>
    _buildAppTheme(accent, Brightness.light);

/// Темна Material 3 тема з обраним акцентом.
ThemeData buildDarkAppTheme(AppAccentTheme accent) =>
    _buildAppTheme(accent, Brightness.dark);

ThemeData _buildAppTheme(AppAccentTheme accent, Brightness brightness) {
  const inter = 'Inter';

  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent.seedColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: inter,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontFamily: inter, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: inter, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontFamily: inter, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontFamily: inter, fontWeight: FontWeight.w500),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
  );
}
