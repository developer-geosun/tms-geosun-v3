import 'package:flutter/material.dart';

import '../domain/country_reference_sort.dart';
import '../domain/directory_models.dart';
import 'directory_paged_table.dart';

/// Опис стовпця таблиці країн.
typedef CountryTableColumn =
    DirectoryTableColumn<CountryReference, CountrySortColumn>;

/// Таблиця країн на спільному каркасі DirectoryPagedTable.
class CountriesPagedTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DirectoryPagedTable<CountryReference, CountrySortColumn>(
      tableKey: const Key('countries-table'),
      headerKey: const Key('countries-table-header'),
      rows: rows,
      totalCount: totalCount,
      columns: columns,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      rowsPerPage: rowsPerPage,
      pageIndex: pageIndex,
      pageSizeOptions: pageSizeOptions,
      onSort: onSort,
      onRowsPerPageChanged: onRowsPerPageChanged,
      onPageIndexChanged: onPageIndexChanged,
      emptyMessage: emptyMessage,
      compact: compact,
    );
  }
}
