import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/app_elevated_icon_button.dart';

/// Спільна оболонка списку довідника: тулбар, прогрес, помилка, порожній стан.
class DirectoryPageBody extends StatelessWidget {
  const DirectoryPageBody({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.errorMessage,
  });

  final Widget? header;
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String emptyMessage;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?header,
        if (isLoading) const LinearProgressIndicator(),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        Expanded(
          child: isEmpty && !isLoading && errorMessage == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: itemCount,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: itemBuilder,
                ),
        ),
      ],
    );
  }
}

/// Кнопка оновлення списку довідника.
class DirectoryRefreshButton extends StatelessWidget {
  const DirectoryRefreshButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppElevatedIconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: l10n.directoryRefresh,
      icon: const Icon(Icons.refresh),
    );
  }
}
