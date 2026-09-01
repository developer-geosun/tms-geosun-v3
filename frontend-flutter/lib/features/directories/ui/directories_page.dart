import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

/// Заглушка розділу «Довідники».
class DirectoriesPage extends StatelessWidget {
  const DirectoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.directoriesPlaceholder,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
