import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/shell/app_navigation.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/directories_api.dart';
import '../domain/country_reference_sort.dart';
import '../domain/directory_models.dart';
import 'countries_paged_table.dart';
import 'directory_format.dart';
import 'directory_page_body.dart';
import 'directory_paged_table.dart';
import 'directory_table_layout.dart';

/// Довідник країн Європи: таблиця з пагінацією та сортуванням стовпців.
class CountriesDirectoryPage extends ConsumerStatefulWidget {
  const CountriesDirectoryPage({super.key});

  static const pageSizeOptions = DirectoryTableLayout.pageSizeOptions;
  static const maxPageSize = DirectoryTableLayout.maxPageSize;
  static const defaultPageSize = DirectoryTableLayout.defaultPageSize;
  static const contentInset = DirectoryTableLayout.contentInset;
  static const compactContentInset = DirectoryTableLayout.compactContentInset;

  @override
  ConsumerState<CountriesDirectoryPage> createState() =>
      _CountriesDirectoryPageState();
}

class _CountriesDirectoryPageState
    extends ConsumerState<CountriesDirectoryPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<CountryReference> _countries = const [];
  bool _isLoading = true;
  CountrySortColumn _sortColumn = CountrySortColumn.codeAlpha2;
  bool _sortAscending = true;
  int _rowsPerPage = CountriesDirectoryPage.defaultPageSize;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncNameSortForCompactLayout();
  }

  /// На смартфоні назва сортується мовою інтерфейсу, а не трьома стовпцями.
  void _syncNameSortForCompactLayout() {
    final compact = MediaQuery.sizeOf(context).width < appShellWideBreakpoint;
    if (!compact || !isCountryNameSortColumn(_sortColumn)) {
      return;
    }
    final mapped = countryNameSortColumn(
      Localizations.localeOf(context).languageCode,
    );
    if (mapped == _sortColumn) {
      return;
    }
    _sortColumn = mapped;
    _countries = sortCountryReferences(
      _countries,
      column: _sortColumn,
      ascending: _sortAscending,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final countries = await ref
          .read(directoriesApiProvider)
          .listCountries(search: _searchController.text);
      if (!mounted) {
        return;
      }
      _applyCountries(countries, resetPage: true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _countries = const [];
        _isLoading = false;
        _pageIndex = 0;
      });
      showAppSnack(
        context,
        message: directoryErrorMessage(error, AppLocalizations.of(context)),
        kind: AppSnackKind.error,
      );
    }
  }

  void _applyCountries(
    List<CountryReference> countries, {
    required bool resetPage,
  }) {
    final sorted = sortCountryReferences(
      countries,
      column: _sortColumn,
      ascending: _sortAscending,
    );
    setState(() {
      _countries = sorted;
      _isLoading = false;
      if (resetPage) {
        _pageIndex = 0;
      } else {
        _pageIndex = clampDirectoryPageIndex(
          _pageIndex,
          sorted.length,
          _rowsPerPage,
        );
      }
    });
  }

  void _onSort(CountrySortColumn column, bool ascending) {
    _sortColumn = column;
    _sortAscending = ascending;
    _applyCountries(_countries, resetPage: false);
  }

  void _onRowsPerPageChanged(int value) {
    final rowsPerPage = value.clamp(1, CountriesDirectoryPage.maxPageSize);
    setState(() {
      _rowsPerPage = rowsPerPage;
      _pageIndex = clampDirectoryPageIndex(
        _pageIndex,
        _countries.length,
        rowsPerPage,
      );
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _reload);
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    _reload();
    setState(() {});
  }

  List<CountryReference> get _pageRows {
    if (_countries.isEmpty) {
      return const [];
    }
    final start = _pageIndex * _rowsPerPage;
    if (start >= _countries.length) {
      return const [];
    }
    final end = math.min(start + _rowsPerPage, _countries.length);
    return _countries.sublist(start, end);
  }

  List<CountryTableColumn> _tableColumns({
    required AppLocalizations l10n,
    required bool compact,
    required String languageCode,
  }) {
    final iso2Width = compact
        ? const FixedColumnWidth(88)
        : const FixedColumnWidth(104);
    final iso3Width = compact
        ? const FixedColumnWidth(96)
        : const FixedColumnWidth(112);
    final iso2 = CountryTableColumn(
      label: l10n.directoryCodeAlpha2,
      sortColumn: CountrySortColumn.codeAlpha2,
      valueOf: (country) => country.codeAlpha2,
      kind: DirectoryTableCellKind.codeChip,
      width: iso2Width,
    );
    final iso3 = CountryTableColumn(
      label: l10n.directoryCodeAlpha3,
      sortColumn: CountrySortColumn.codeAlpha3,
      valueOf: (country) => country.codeAlpha3,
      kind: DirectoryTableCellKind.codeChip,
      width: iso3Width,
    );
    if (compact) {
      return [
        iso2,
        iso3,
        CountryTableColumn(
          label: l10n.directoryName,
          sortColumn: countryNameSortColumn(languageCode),
          valueOf: (country) => country.localizedName(languageCode),
          emphasize: true,
          width: const FlexColumnWidth(1),
        ),
      ];
    }
    final nameUk = CountryTableColumn(
      label: l10n.directoryNameUk,
      sortColumn: CountrySortColumn.nameUk,
      valueOf: (country) => country.nameUk,
      emphasize: languageCode != 'en' && languageCode != 'ru',
      width: const FlexColumnWidth(1.2),
    );
    final nameEn = CountryTableColumn(
      label: l10n.directoryNameEn,
      sortColumn: CountrySortColumn.nameEn,
      valueOf: (country) => country.nameEn,
      emphasize: languageCode == 'en',
      width: const FlexColumnWidth(1),
    );
    final nameRu = CountryTableColumn(
      label: l10n.directoryNameRu,
      sortColumn: CountrySortColumn.nameRu,
      valueOf: (country) => country.nameRu,
      emphasize: languageCode == 'ru',
      width: const FlexColumnWidth(1),
    );
    final names = switch (languageCode) {
      'en' => [nameEn, nameUk, nameRu],
      'ru' => [nameRu, nameUk, nameEn],
      _ => [nameUk, nameEn, nameRu],
    };
    return [iso2, iso3, ...names];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < appShellWideBreakpoint;
    final inset = DirectoryTableLayout.insetFor(compact);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DirectorySearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onSubmitted: _reload,
          onClear: _clearSearch,
          onRefresh: _reload,
          refreshEnabled: !_isLoading,
          compact: compact,
        ),
        DirectoryLoadProgress(isLoading: _isLoading),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(inset, 0, inset, 16),
            child: CountriesPagedTable(
              rows: _pageRows,
              totalCount: _countries.length,
              columns: _tableColumns(
                l10n: l10n,
                compact: compact,
                languageCode: languageCode,
              ),
              sortColumn: _sortColumn,
              sortAscending: _sortAscending,
              rowsPerPage: _rowsPerPage,
              pageIndex: _pageIndex,
              pageSizeOptions: CountriesDirectoryPage.pageSizeOptions,
              onSort: _onSort,
              onRowsPerPageChanged: _onRowsPerPageChanged,
              onPageIndexChanged: (index) => setState(() => _pageIndex = index),
              emptyMessage: l10n.directoryEmpty,
              compact: compact,
            ),
          ),
        ),
      ],
    );
  }
}
