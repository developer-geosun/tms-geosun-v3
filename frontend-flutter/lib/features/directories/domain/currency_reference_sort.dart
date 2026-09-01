import '../domain/directory_models.dart';

/// Стовпці таблиці довідника валют.
enum CurrencySortColumn {
  code,
  nameUk,
  nameEn,
  nameRu,
  nbuUnits,
  ratePerUnit,
  rateDate,
  isActive,
}

bool isCurrencyNameSortColumn(CurrencySortColumn column) {
  return column == CurrencySortColumn.nameUk ||
      column == CurrencySortColumn.nameEn ||
      column == CurrencySortColumn.nameRu;
}

/// Стовпець назви відповідно до мови інтерфейсу.
CurrencySortColumn currencyNameSortColumn(String languageCode) {
  return switch (languageCode) {
    'en' => CurrencySortColumn.nameEn,
    'ru' => CurrencySortColumn.nameRu,
    _ => CurrencySortColumn.nameUk,
  };
}

/// Клієнтський фільтр: код, числовий код, назви.
List<CurrencyReference> filterCurrencyReferences(
  Iterable<CurrencyReference> currencies,
  String search,
) {
  final query = search.trim().toLowerCase();
  if (query.isEmpty) {
    return [...currencies];
  }
  return [
    for (final currency in currencies)
      if (_currencyMatches(currency, query)) currency,
  ];
}

bool _currencyMatches(CurrencyReference currency, String query) {
  if (currency.code.toLowerCase().contains(query)) {
    return true;
  }
  if (currency.numericCode.toString().contains(query)) {
    return true;
  }
  if (currency.nameUk.toLowerCase().contains(query)) {
    return true;
  }
  final nameEn = currency.nameEn?.toLowerCase();
  if (nameEn != null && nameEn.contains(query)) {
    return true;
  }
  final nameRu = currency.nameRu?.toLowerCase();
  if (nameRu != null && nameRu.contains(query)) {
    return true;
  }
  return false;
}

/// Сортування довідника валют на клієнті.
List<CurrencyReference> sortCurrencyReferences(
  Iterable<CurrencyReference> currencies, {
  required CurrencySortColumn column,
  required bool ascending,
}) {
  int compareNullable<T extends Comparable<T>>(T? a, T? b) {
    if (a == null && b == null) {
      return 0;
    }
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return a.compareTo(b);
  }

  int compare(CurrencyReference a, CurrencyReference b) {
    final result = switch (column) {
      CurrencySortColumn.code => a.code.compareTo(b.code),
      CurrencySortColumn.nameUk => a.nameUk.compareTo(b.nameUk),
      CurrencySortColumn.nameEn => compareNullable(
        a.nameEn?.trim().isEmpty == true ? null : a.nameEn,
        b.nameEn?.trim().isEmpty == true ? null : b.nameEn,
      ),
      CurrencySortColumn.nameRu => compareNullable(
        a.nameRu?.trim().isEmpty == true ? null : a.nameRu,
        b.nameRu?.trim().isEmpty == true ? null : b.nameRu,
      ),
      CurrencySortColumn.nbuUnits => a.nbuUnits.compareTo(b.nbuUnits),
      CurrencySortColumn.ratePerUnit => compareNullable(
        a.latestNbuRatePerUnit,
        b.latestNbuRatePerUnit,
      ),
      CurrencySortColumn.rateDate => compareNullable(
        a.latestRateDate,
        b.latestRateDate,
      ),
      CurrencySortColumn.isActive => (a.isActive ? 1 : 0).compareTo(
        b.isActive ? 1 : 0,
      ),
    };
    if (result != 0) {
      return ascending ? result : -result;
    }
    // За однакової активності — стабільний порядок за кодом.
    if (column == CurrencySortColumn.isActive) {
      return a.code.compareTo(b.code);
    }
    return 0;
  }

  return [...currencies]..sort(compare);
}
