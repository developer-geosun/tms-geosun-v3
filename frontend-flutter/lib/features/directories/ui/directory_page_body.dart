import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/app_elevated_icon_button.dart';

/// Спільна оболонка списку довідника: тулбар, прогрес, порожній стан.
class DirectoryPageBody extends StatelessWidget {
  const DirectoryPageBody({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.emptyMessage,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
  });

  final Widget? header;
  final bool isLoading;
  final bool isEmpty;
  final String emptyMessage;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ?header,
        DirectoryLoadProgress(isLoading: isLoading),
        Expanded(
          child: isEmpty && !isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
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

/// Смуга прогресу постійної висоти: таблиця не зміщується під час оновлення.
class DirectoryLoadProgress extends StatelessWidget {
  const DirectoryLoadProgress({super.key, required this.isLoading});

  final bool isLoading;

  static const height = 4.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: isLoading
          ? const LinearProgressIndicator(minHeight: height)
          : const SizedBox.expand(),
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
