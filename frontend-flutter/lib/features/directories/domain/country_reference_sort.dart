import 'directory_models.dart';

/// Стовпці таблиці довідника країн (порядок як у UI).
enum CountrySortColumn { codeAlpha2, codeAlpha3, nameUk, nameEn, nameRu }

bool isCountryNameSortColumn(CountrySortColumn column) {
  return column == CountrySortColumn.nameUk ||
      column == CountrySortColumn.nameEn ||
      column == CountrySortColumn.nameRu;
}

/// Стовпець назви відповідно до мови інтерфейсу.
CountrySortColumn countryNameSortColumn(String languageCode) {
  return switch (languageCode) {
    'en' => CountrySortColumn.nameEn,
    'ru' => CountrySortColumn.nameRu,
    _ => CountrySortColumn.nameUk,
  };
}

/// Сортування довідника країн на клієнті (як у Angular MatSort).
List<CountryReference> sortCountryReferences(
  Iterable<CountryReference> countries, {
  required CountrySortColumn column,
  required bool ascending,
}) {
  int compare(CountryReference a, CountryReference b) {
    final result = switch (column) {
      CountrySortColumn.codeAlpha2 => a.codeAlpha2.compareTo(b.codeAlpha2),
      CountrySortColumn.codeAlpha3 => a.codeAlpha3.compareTo(b.codeAlpha3),
      CountrySortColumn.nameUk => a.nameUk.compareTo(b.nameUk),
      CountrySortColumn.nameEn => a.nameEn.compareTo(b.nameEn),
      CountrySortColumn.nameRu => a.nameRu.compareTo(b.nameRu),
    };
    return ascending ? result : -result;
  }

  return [...countries]..sort(compare);
}
