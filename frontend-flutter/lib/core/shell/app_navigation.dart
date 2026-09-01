import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Пункти бічної навігації (рейка / drawer).
class AppNavDestination {
  const AppNavDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) label;

  static List<AppNavDestination> items(AppLocalizations l10n) => [
    AppNavDestination(
      path: '/home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: (l10n) => l10n.navHome,
    ),
    AppNavDestination(
      path: '/directories',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: (l10n) => l10n.navDirectories,
    ),
  ];

  static int indexForLocation(String location) {
    if (location.startsWith('/directories')) {
      return 1;
    }
    return 0;
  }
}

/// Поріг ширини: NavigationRail (широкий) vs NavigationDrawer (вузький).
const appShellWideBreakpoint = 800.0;
