import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

/// Хаб розділу «Довідники»: посилання на країни, валюти та курси.
class DirectoriesPage extends StatelessWidget {
  const DirectoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final links = [
      _DirectoryLink(
        keyName: 'directory-countries',
        path: '/directories/countries',
        icon: Icons.public_outlined,
        label: l10n.directoryCountries,
      ),
      _DirectoryLink(
        keyName: 'directory-currencies',
        path: '/directories/currencies',
        icon: Icons.payments_outlined,
        label: l10n.directoryCurrencies,
      ),
      _DirectoryLink(
        keyName: 'directory-exchange-rates',
        path: '/directories/exchange-rates',
        icon: Icons.currency_exchange,
        label: l10n.directoryExchangeRates,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < links.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                ListTile(
                  key: Key(links[i].keyName),
                  leading: Icon(links[i].icon),
                  title: Text(links[i].label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(links[i].path),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DirectoryLink {
  const _DirectoryLink({
    required this.keyName,
    required this.path,
    required this.icon,
    required this.label,
  });

  final String keyName;
  final String path;
  final IconData icon;
  final String label;
}
