import 'package:flutter/material.dart';

import '../domain/country_reference_sort.dart';
import '../domain/directory_models.dart';

/// Опис стовпця таблиці країн.
class CountryTableColumn {
  const CountryTableColumn({
    required this.label,
    required this.sortColumn,
    required this.valueOf,
  });

  final String label;
  final CountrySortColumn sortColumn;
  final String Function(CountryReference country) valueOf;
}

/// Таблиця країн: шапка secondaryContainer, скрол лише у рядках, пагінація до 50.
class CountriesPagedTable extends StatefulWidget {
  const CountriesPagedTable({
    super.key,
    required this.rows,
    required this.totalCount,
    required this.columns,
    required this.sortColumn,
    required this.sortAscending,
    required this.rowsPerPage,
    required this.pageIndex,
    required this.pageSizeOptions,
    required this.onSort,
    required this.onRowsPerPageChanged,
    required this.onPageIndexChanged,
    required this.emptyMessage,
    this.compact = false,
  });

  final List<CountryReference> rows;
  final int totalCount;
  final List<CountryTableColumn> columns;
  final CountrySortColumn sortColumn;
  final bool sortAscending;
  final int rowsPerPage;
  final int pageIndex;
  final List<int> pageSizeOptions;
  final void Function(CountrySortColumn column, bool ascending) onSort;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<int> onPageIndexChanged;
  final String emptyMessage;
  final bool compact;

  @override
  State<CountriesPagedTable> createState() => _CountriesPagedTableState();
}

class _CountriesPagedTableState extends State<CountriesPagedTable> {
  final _bodyScrollController = ScrollController();

  Map<int, TableColumnWidth> get _columnWidths {
    if (widget.compact) {
      return const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2.6),
      };
    }
    return const {
      0: FlexColumnWidth(1.1),
      1: FlexColumnWidth(1.1),
      2: FlexColumnWidth(2),
      3: FlexColumnWidth(2),
      4: FlexColumnWidth(2),
    };
  }

  @override
  void dispose() {
    _bodyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final widths = _columnWidths;

    return Card(
      key: const Key('countries-table'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: colorScheme.secondaryContainer,
            child: Table(
              columnWidths: widths,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  children: [
                    for (final column in widget.columns)
                      _HeaderCell(
                        label: column.label,
                        isActive: widget.sortColumn == column.sortColumn,
                        ascending: widget.sortAscending,
                        compact: widget.compact,
                        onPressed: () {
                          if (widget.sortColumn == column.sortColumn) {
                            widget.onSort(
                              column.sortColumn,
                              !widget.sortAscending,
                            );
                          } else {
                            widget.onSort(column.sortColumn, true);
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.rows.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.emptyMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : Scrollbar(
                    controller: _bodyScrollController,
                    thumbVisibility: !widget.compact,
                    child: ListView.separated(
                      controller: _bodyScrollController,
                      itemCount: widget.rows.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final country = widget.rows[index];
                        // Парні рядки — фон картки, непарні — контрастна смуга.
                        final rowColor = index.isOdd
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.surface;
                        return ColoredBox(
                          color: rowColor,
                          child: Table(
                            columnWidths: widths,
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                children: [
                                  for (final column in widget.columns)
                                    _BodyCell(
                                      column.valueOf(country),
                                      tooltip: true,
                                      compact: widget.compact,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const Divider(height: 1),
          _TablePaginator(
            totalCount: widget.totalCount,
            rowsPerPage: widget.rowsPerPage,
            pageIndex: widget.pageIndex,
            pageSizeOptions: widget.pageSizeOptions,
            compact: widget.compact,
            onRowsPerPageChanged: widget.onRowsPerPageChanged,
            onPageIndexChanged: widget.onPageIndexChanged,
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.isActive,
    required this.ascending,
    required this.onPressed,
    required this.compact,
  });

  final String label;
  final bool isActive;
  final bool ascending;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: colorScheme.onSecondaryContainer,
      fontWeight: FontWeight.w600,
    );
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              if (isActive)
                Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.text, {this.tooltip = false, this.compact = false});

  final String text;
  final bool tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final child = Padding(
      padding: padding,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
    if (!tooltip || text.isEmpty) {
      return child;
    }
    return Tooltip(message: text, child: child);
  }
}

class _TablePaginator extends StatelessWidget {
  const _TablePaginator({
    required this.totalCount,
    required this.rowsPerPage,
    required this.pageIndex,
    required this.pageSizeOptions,
    required this.onRowsPerPageChanged,
    required this.onPageIndexChanged,
    required this.compact,
  });

  final int totalCount;
  final int rowsPerPage;
  final int pageIndex;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<int> onPageIndexChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final pageCount = totalCount == 0 ? 1 : (totalCount / rowsPerPage).ceil();
    final firstRow = totalCount == 0 ? 0 : pageIndex * rowsPerPage + 1;
    final lastRow = totalCount == 0
        ? 0
        : (firstRow + rowsPerPage - 1).clamp(0, totalCount);
    final canGoBack = pageIndex > 0;
    final canGoForward = pageIndex < pageCount - 1;

    final navButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: l10n.firstPageTooltip,
          onPressed: canGoBack ? () => onPageIndexChanged(0) : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: l10n.previousPageTooltip,
          onPressed: canGoBack ? () => onPageIndexChanged(pageIndex - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: l10n.nextPageTooltip,
          onPressed: canGoForward
              ? () => onPageIndexChanged(pageIndex + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: l10n.lastPageTooltip,
          onPressed: canGoForward
              ? () => onPageIndexChanged(pageCount - 1)
              : null,
          icon: const Icon(Icons.last_page),
        ),
      ],
    );

    final pageSizeRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.rowsPerPageTitle, style: textStyle),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: rowsPerPage,
          style: textStyle,
          underline: const SizedBox.shrink(),
          items: [
            for (final size in pageSizeOptions)
              DropdownMenuItem(
                value: size,
                child: Text('$size', style: textStyle),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onRowsPerPageChanged(value);
            }
          },
        ),
      ],
    );

    final rangeText = Text(
      l10n.pageRowsInfoTitle(firstRow, lastRow, totalCount, false),
      style: textStyle,
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [pageSizeRow, rangeText],
            ),
            navButtons,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              pageSizeRow,
              const SizedBox(width: 16),
              rangeText,
              navButtons,
            ],
          ),
        ),
      ),
    );
  }
}
