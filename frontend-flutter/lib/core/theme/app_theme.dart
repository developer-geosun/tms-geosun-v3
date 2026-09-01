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

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: inter,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  // Увесь Material-текст — Inter; інакше dropdown/пагінатор беруть Roboto.
  final textTheme = base.textTheme.apply(fontFamily: inter);

  return base.copyWith(
    textTheme: textTheme.copyWith(
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    ),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: inter),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(textStyle: textTheme.bodyMedium),
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
