import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_error.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/shell/app_navigation.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../data/directories_api.dart';
import '../domain/currency_reference_sort.dart';
import '../domain/directory_models.dart';
import 'directory_format.dart';
import 'directory_page_body.dart';
import 'directory_paged_table.dart';
import 'directory_table_layout.dart';

/// Довідник валют: таблиця з пагінацією та сортуванням, як у країн.
class CurrenciesDirectoryPage extends ConsumerStatefulWidget {
  const CurrenciesDirectoryPage({super.key});

  static const pageSizeOptions = DirectoryTableLayout.pageSizeOptions;
  static const maxPageSize = DirectoryTableLayout.maxPageSize;
  static const defaultPageSize = DirectoryTableLayout.defaultPageSize;

  @override
  ConsumerState<CurrenciesDirectoryPage> createState() =>
      _CurrenciesDirectoryPageState();
}

class _CurrenciesDirectoryPageState
    extends ConsumerState<CurrenciesDirectoryPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<CurrencyReference> _allCurrencies = const [];
  List<CurrencyReference> _currencies = const [];
  bool _isLoading = true;
  CurrencySortColumn _sortColumn = CurrencySortColumn.code;
  bool _sortAscending = true;
  int _rowsPerPage = CurrenciesDirectoryPage.defaultPageSize;
  int _pageIndex = 0;
  final _updatingCodes = <String>{};

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

  /// На смартфоні назва сортується мовою інтерфейсу.
  void _syncNameSortForCompactLayout() {
    final compact = MediaQuery.sizeOf(context).width < appShellWideBreakpoint;
    if (!compact || !isCurrencyNameSortColumn(_sortColumn)) {
      return;
    }
    final mapped = currencyNameSortColumn(
      Localizations.localeOf(context).languageCode,
    );
    if (mapped == _sortColumn) {
      return;
    }
    _sortColumn = mapped;
    _applyCurrencies(resetPage: false);
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
      final currencies = await ref
          .read(directoriesApiProvider)
          .listCurrencies();
      if (!mounted) {
        return;
      }
      _allCurrencies = currencies;
      _applyCurrencies(resetPage: true);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _allCurrencies = const [];
        _currencies = const [];
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

  void _applyCurrencies({required bool resetPage}) {
    final filtered = filterCurrencyReferences(
      _allCurrencies,
      _searchController.text,
    );
    final sorted = sortCurrencyReferences(
      filtered,
      column: _sortColumn,
      ascending: _sortAscending,
    );
    setState(() {
      _currencies = sorted;
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

  void _onSort(CurrencySortColumn column, bool ascending) {
    _sortColumn = column;
    _sortAscending = ascending;
    _applyCurrencies(resetPage: false);
  }

  void _onRowsPerPageChanged(int value) {
    final rowsPerPage = value.clamp(1, CurrenciesDirectoryPage.maxPageSize);
    setState(() {
      _rowsPerPage = rowsPerPage;
      _pageIndex = clampDirectoryPageIndex(
        _pageIndex,
        _currencies.length,
        rowsPerPage,
      );
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }
      _applyCurrencies(resetPage: true);
    });
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    _applyCurrencies(resetPage: true);
    setState(() {});
  }

  Future<void> _toggleActive(CurrencyReference currency, bool isActive) async {
    if (_updatingCodes.contains(currency.code)) {
      return;
    }
    setState(() {
      _updatingCodes.add(currency.code);
    });
    try {
      final updated = await ref
          .read(directoriesApiProvider)
          .updateCurrency(code: currency.code, isActive: isActive);
      if (!mounted) {
        return;
      }
      _allCurrencies = [
        for (final item in _allCurrencies)
          if (item.code == updated.code) updated else item,
      ];
      _updatingCodes.remove(currency.code);
      _applyCurrencies(resetPage: false);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _updatingCodes.remove(currency.code);
      });
      showAppSnack(
        context,
        message: error.statusCode == 403
            ? AppLocalizations.of(context).directoryAccessDenied
            : AppLocalizations.of(context).directoryCurrencyUpdateFailed,
        kind: AppSnackKind.error,
      );
    }
  }

  List<CurrencyReference> get _pageRows {
    if (_currencies.isEmpty) {
      return const [];
    }
    final start = _pageIndex * _rowsPerPage;
    if (start >= _currencies.length) {
      return const [];
    }
    final end = math.min(start + _rowsPerPage, _currencies.length);
    return _currencies.sublist(start, end);
  }

  List<DirectoryTableColumn<CurrencyReference, CurrencySortColumn>>
  _tableColumns({
    required AppLocalizations l10n,
    required bool compact,
    required String languageCode,
    required String localeName,
  }) {
    final code = DirectoryTableColumn<CurrencyReference, CurrencySortColumn>(
      label: l10n.directoryCurrencyCode,
      sortColumn: CurrencySortColumn.code,
      valueOf: (currency) => currency.code,
      kind: DirectoryTableCellKind.codeChip,
      width: compact ? const FixedColumnWidth(88) : const FixedColumnWidth(104),
    );
    final name = DirectoryTableColumn<CurrencyReference, CurrencySortColumn>(
      label: compact ? l10n.directoryCurrencyName : l10n.directoryName,
      sortColumn: currencyNameSortColumn(languageCode),
      valueOf: (currency) => currency.localizedName(languageCode),
      emphasize: true,
      width: const FlexColumnWidth(1.4),
    );
    final rate = DirectoryTableColumn<CurrencyReference, CurrencySortColumn>(
      label: l10n.directoryRatePerUnit,
      sortColumn: CurrencySortColumn.ratePerUnit,
      valueOf: (currency) =>
          formatDirectoryRate(currency.latestNbuRatePerUnit, localeName),
      kind: DirectoryTableCellKind.numeric,
      width: compact ? const FlexColumnWidth(1) : const FixedColumnWidth(128),
    );
    final active = DirectoryTableColumn<CurrencyReference, CurrencySortColumn>(
      label: l10n.directoryCurrencyActive,
      sortColumn: CurrencySortColumn.isActive,
      valueOf: (currency) => currency.isActive
          ? l10n.directoryCurrencyActive
          : l10n.directoryCurrencyInactive,
      width: compact ? const FixedColumnWidth(80) : const FixedColumnWidth(104),
      cellBuilder: (context, currency) {
        final updating = _updatingCodes.contains(currency.code);
        return Tooltip(
          message: currency.isActive
              ? l10n.directoryCurrencyActive
              : l10n.directoryCurrencyInactive,
          child: Switch(
            key: Key('currency-active-${currency.code}'),
            value: currency.isActive,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: updating
                ? null
                : (value) => _toggleActive(currency, value),
          ),
        );
      },
    );
    if (compact) {
      return [code, name, rate, active];
    }
    return [
      code,
      name,
      DirectoryTableColumn(
        label: l10n.directoryNbuUnits,
        sortColumn: CurrencySortColumn.nbuUnits,
        valueOf: (currency) => '${currency.nbuUnits}',
        kind: DirectoryTableCellKind.numeric,
        width: const FixedColumnWidth(96),
      ),
      rate,
      DirectoryTableColumn(
        label: l10n.directoryRateDate,
        sortColumn: CurrencySortColumn.rateDate,
        valueOf: (currency) => currency.latestRateDate ?? '—',
        width: const FixedColumnWidth(120),
      ),
      active,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < appShellWideBreakpoint;
    final inset = DirectoryTableLayout.insetFor(compact);
    final languageCode = Localizations.localeOf(context).languageCode;
    final localeName = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DirectorySearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onSubmitted: () => _applyCurrencies(resetPage: true),
          onClear: _clearSearch,
          onRefresh: _reload,
          refreshEnabled: !_isLoading,
          compact: compact,
        ),
        DirectoryLoadProgress(isLoading: _isLoading),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(inset, 0, inset, 16),
            child: DirectoryPagedTable<CurrencyReference, CurrencySortColumn>(
              tableKey: const Key('currencies-table'),
              headerKey: const Key('currencies-table-header'),
              rows: _pageRows,
              totalCount: _currencies.length,
              columns: _tableColumns(
                l10n: l10n,
                compact: compact,
                languageCode: languageCode,
                localeName: localeName,
              ),
              sortColumn: _sortColumn,
              sortAscending: _sortAscending,
              rowsPerPage: _rowsPerPage,
              pageIndex: _pageIndex,
              pageSizeOptions: CurrenciesDirectoryPage.pageSizeOptions,
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
