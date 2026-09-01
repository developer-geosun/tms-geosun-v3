import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../domain/country_reference_sort.dart';
import '../domain/directory_models.dart';

/// Стиль клітинки довідника країн.
enum CountryTableCellKind { text, isoCode }

/// Опис стовпця таблиці країн.
class CountryTableColumn {
  const CountryTableColumn({
    required this.label,
    required this.sortColumn,
    required this.valueOf,
    this.kind = CountryTableCellKind.text,
    this.emphasize = false,
  });

  final String label;
  final CountrySortColumn sortColumn;
  final String Function(CountryReference country) valueOf;
  final CountryTableCellKind kind;
  final bool emphasize;
}

/// Таблиця країн: шапка surfaceContainer, скрол лише у рядках, пагінація до 50.
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
    // Ширина під заголовок «ISO-2»/«ISO-3» і стрілку сортування.
    final iso2 = widget.compact
        ? const FixedColumnWidth(88)
        : const FixedColumnWidth(104);
    final iso3 = widget.compact
        ? const FixedColumnWidth(96)
        : const FixedColumnWidth(112);
    if (widget.compact) {
      return {0: iso2, 1: iso3, 2: const FlexColumnWidth(1)};
    }
    return {
      0: iso2,
      1: iso3,
      2: const FlexColumnWidth(1.2),
      3: const FlexColumnWidth(1),
      4: const FlexColumnWidth(1),
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
            key: const Key('countries-table-header'),
            color: colorScheme.surfaceContainer,
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
                        // Парні рядки — фон картки, непарні — м’який контраст.
                        final rowColor = index.isOdd
                            ? colorScheme.surfaceContainerLow
                            : colorScheme.surface;
                        return _HoverableRow(
                          color: rowColor,
                          hoverColor: colorScheme.surfaceContainerHigh,
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
                                      compact: widget.compact,
                                      kind: column.kind,
                                      emphasize: column.emphasize,
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

class _HoverableRow extends StatefulWidget {
  const _HoverableRow({
    required this.color,
    required this.hoverColor,
    required this.child,
  });

  final Color color;
  final Color hoverColor;
  final Widget child;

  @override
  State<_HoverableRow> createState() => _HoverableRowState();
}

class _HoverableRowState extends State<_HoverableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ColoredBox(
        color: _hovered ? widget.hoverColor : widget.color,
        child: widget.child,
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
    final color = isActive ? colorScheme.primary : colorScheme.onSurface;
    final textStyle = Theme.of(context).textTheme.titleSmall
        ?.copyWith(color: color, fontWeight: FontWeight.w600);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

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
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(
    this.text, {
    required this.compact,
    required this.kind,
    required this.emphasize,
  });

  final String text;
  final bool compact;
  final CountryTableCellKind kind;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    if (kind == CountryTableCellKind.isoCode) {
      return Padding(
        padding: padding,
        child: Align(
          alignment: Alignment.centerLeft,
          child: _IsoCodeChip(text),
        ),
      );
    }

    final colorScheme = theme.colorScheme;
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: emphasize ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
      fontWeight: emphasize ? FontWeight.w500 : FontWeight.w400,
    );

    return Padding(
      padding: padding,
      child: _OverflowText(text, style: style),
    );
  }
}

class _IsoCodeChip extends StatelessWidget {
  const _IsoCodeChip(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          code,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Текст з tooltip лише коли рядок обрізається.
class _OverflowText extends StatelessWidget {
  const _OverflowText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = style ?? DefaultTextStyle.of(context).style;
        final painter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: 1,
          ellipsis: '\u2026',
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflow = painter.didExceedMaxLines;
        painter.dispose();

        final child = Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        );
        if (!overflow) {
          return child;
        }
        return Tooltip(message: text, child: child);
      },
    );
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
    final material = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final pageCount = totalCount == 0 ? 1 : (totalCount / rowsPerPage).ceil();
    final firstRow = totalCount == 0 ? 0 : pageIndex * rowsPerPage + 1;
    final lastRow = totalCount == 0
        ? 0
        : math.min((pageIndex + 1) * rowsPerPage, totalCount);
    final canGoBack = pageIndex > 0;
    final canGoForward = pageIndex < pageCount - 1;
    final showPageNav = pageCount > 1;

    final navButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: material.firstPageTooltip,
          onPressed: canGoBack ? () => onPageIndexChanged(0) : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: material.previousPageTooltip,
          onPressed: canGoBack ? () => onPageIndexChanged(pageIndex - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: material.nextPageTooltip,
          onPressed: canGoForward
              ? () => onPageIndexChanged(pageIndex + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          visualDensity: compact
              ? VisualDensity.compact
              : VisualDensity.standard,
          tooltip: material.lastPageTooltip,
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
        Text(material.rowsPerPageTitle, style: textStyle),
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
      showPageNav
          ? material.pageRowsInfoTitle(firstRow, lastRow, totalCount, false)
          : l10n.directoryRecordCount(totalCount),
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
            if (showPageNav) navButtons,
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
              if (showPageNav) navButtons,
            ],
          ),
        ),
      ),
    );
  }
}
