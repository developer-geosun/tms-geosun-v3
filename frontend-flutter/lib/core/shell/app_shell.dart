import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_logout_button.dart';
import '../widgets/app_settings_button.dart';
import 'app_navigation.dart';

/// Адаптивний каркас: NavigationRail (≥800px) або drawer + burger (вузький екран).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final destinations = AppNavDestination.items(l10n);
    final selectedIndex = AppNavDestination.indexForLocation(location);
    final title = AppNavDestination.titleForLocation(location, l10n);
    final showDirectoryBack = AppNavDestination.isNestedDirectory(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= appShellWideBreakpoint;

        void onDestinationSelected(int index) {
          final path = destinations[index].path;
          if (location != path) {
            context.go(path);
          }
        }

        return Scaffold(
          drawer: isWide
              ? null
              : _AppNavigationDrawer(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                ),
          appBar: AppBar(
            title: Text(title),
            leading: showDirectoryBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: l10n.directoryBack,
                    onPressed: () => context.go('/directories'),
                  )
                : null,
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: const [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [AppLogoutButton(), AppSettingsButton()],
              ),
            ],
          ),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label(l10n)),
                      ),
                  ],
                ),
              if (isWide) const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _AppNavigationDrawer extends StatelessWidget {
  const _AppNavigationDrawer({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        onDestinationSelected(index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(l10n.appTitle, style: theme.textTheme.titleSmall),
        ),
        for (final destination in destinations)
          NavigationDrawerDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label(l10n)),
          ),
      ],
    );
  }
}
