import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import 'directory_page_body.dart';

/// Константи оболонки сторінок довідників з таблицею.
abstract final class DirectoryTableLayout {
  static const pageSizeOptions = [5, 10, 15, 25, 50];
  static const maxPageSize = 50;
  static const defaultPageSize = 50;
  static const contentInset = 24.0;
  static const compactContentInset = 12.0;
  static const searchRefreshGap = 16.0;
  static const compactSearchRefreshGap = 8.0;
  static const searchFieldMaxWidth = 420.0;
  static const searchRefreshButtonExtent = 48.0;

  static double insetFor(bool compact) =>
      compact ? compactContentInset : contentInset;

  static double searchGapFor(bool compact) =>
      compact ? compactSearchRefreshGap : searchRefreshGap;
}

int clampDirectoryPageIndex(int pageIndex, int totalCount, int rowsPerPage) {
  if (totalCount == 0) {
    return 0;
  }
  final lastPage = ((totalCount - 1) / rowsPerPage).floor();
  if (pageIndex > lastPage) {
    return lastPage;
  }
  if (pageIndex < 0) {
    return 0;
  }
  return pageIndex;
}

/// Пошук зліва (max 420) і кнопка оновлення.
class DirectorySearchBar extends StatelessWidget {
  const DirectorySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onRefresh,
    required this.refreshEnabled,
    required this.compact,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onRefresh;
  final bool refreshEnabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inset = DirectoryTableLayout.insetFor(compact);
    final searchGap = DirectoryTableLayout.searchGapFor(compact);

    return Padding(
      padding: EdgeInsets.fromLTRB(inset, 12, inset, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final searchWidth = math.min(
            DirectoryTableLayout.searchFieldMaxWidth,
            math.max(
              0.0,
              constraints.maxWidth -
                  searchGap -
                  DirectoryTableLayout.searchRefreshButtonExtent,
            ),
          );
          return Row(
            children: [
              SizedBox(
                width: searchWidth,
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                    hintText: l10n.directorySearch,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.directoryClearSearch,
                            onPressed: onClear,
                            icon: const Icon(Icons.close),
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: searchGap),
              DirectoryRefreshButton(
                onPressed: onRefresh,
                enabled: refreshEnabled,
              ),
            ],
          );
        },
      ),
    );
  }
}
