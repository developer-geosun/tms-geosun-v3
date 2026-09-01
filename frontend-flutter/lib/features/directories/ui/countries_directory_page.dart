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

/// Довідник країн Європи: таблиця з пагінацією та сортуванням стовпців.
class CountriesDirectoryPage extends ConsumerStatefulWidget {
  const CountriesDirectoryPage({super.key});

  static const pageSizeOptions = [5, 10, 15, 25, 50];
  static const maxPageSize = 50;
  static const defaultPageSize = 50;

  /// Спільний горизонтальний відступ панелі пошуку та таблиці (широкий екран).
  static const contentInset = 24.0;

  /// Відступ контенту на вузькому екрані смартфона.
  static const compactContentInset = 12.0;

  /// Відступ між полем пошуку та кнопкою оновлення.
  static const searchRefreshGap = 16.0;

  static const compactSearchRefreshGap = 8.0;

  /// Пошук не розтягується на всю ширину таблиці.
  static const searchFieldMaxWidth = 420.0;

  /// Ширина круглої кнопки оновлення (для розрахунку поля пошуку).
  static const searchRefreshButtonExtent = 48.0;

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
        _pageIndex = _clampPageIndex(_pageIndex, sorted.length, _rowsPerPage);
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
      _pageIndex = _clampPageIndex(_pageIndex, _countries.length, rowsPerPage);
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
    final iso2 = CountryTableColumn(
      label: l10n.directoryCodeAlpha2,
      sortColumn: CountrySortColumn.codeAlpha2,
      valueOf: (country) => country.codeAlpha2,
      kind: CountryTableCellKind.isoCode,
    );
    final iso3 = CountryTableColumn(
      label: l10n.directoryCodeAlpha3,
      sortColumn: CountrySortColumn.codeAlpha3,
      valueOf: (country) => country.codeAlpha3,
      kind: CountryTableCellKind.isoCode,
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
        ),
      ];
    }
    final nameUk = CountryTableColumn(
      label: l10n.directoryNameUk,
      sortColumn: CountrySortColumn.nameUk,
      valueOf: (country) => country.nameUk,
      emphasize: languageCode != 'en' && languageCode != 'ru',
    );
    final nameEn = CountryTableColumn(
      label: l10n.directoryNameEn,
      sortColumn: CountrySortColumn.nameEn,
      valueOf: (country) => country.nameEn,
      emphasize: languageCode == 'en',
    );
    final nameRu = CountryTableColumn(
      label: l10n.directoryNameRu,
      sortColumn: CountrySortColumn.nameRu,
      valueOf: (country) => country.nameRu,
      emphasize: languageCode == 'ru',
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
    final inset = compact
        ? CountriesDirectoryPage.compactContentInset
        : CountriesDirectoryPage.contentInset;
    final searchGap = compact
        ? CountriesDirectoryPage.compactSearchRefreshGap
        : CountriesDirectoryPage.searchRefreshGap;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(inset, 12, inset, 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final searchWidth = math.min(
                CountriesDirectoryPage.searchFieldMaxWidth,
                math.max(
                  0.0,
                  constraints.maxWidth -
                      searchGap -
                      CountriesDirectoryPage.searchRefreshButtonExtent,
                ),
              );
              return Row(
                children: [
                  SizedBox(
                    width: searchWidth,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _reload(),
                      decoration: InputDecoration(
                        hintText: l10n.directorySearch,
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                tooltip: l10n.directoryClearSearch,
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close),
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(width: searchGap),
                  DirectoryRefreshButton(
                    onPressed: _reload,
                    enabled: !_isLoading,
                  ),
                ],
              );
            },
          ),
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

int _clampPageIndex(int pageIndex, int totalCount, int rowsPerPage) {
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
