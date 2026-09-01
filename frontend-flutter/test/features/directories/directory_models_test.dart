import 'package:flutter_test/flutter_test.dart';
import 'package:tms_geosun/features/directories/domain/country_reference_sort.dart';
import 'package:tms_geosun/features/directories/domain/directory_models.dart';
import 'package:tms_geosun/features/directories/ui/directory_format.dart';

void main() {
  test('CountryReference бере локалізовану назву з fallback на українську', () {
    const country = CountryReference(
      codeAlpha2: 'UA',
      codeAlpha3: 'UKR',
      nameUk: 'Україна',
      nameEn: 'Ukraine',
      nameRu: '',
    );

    expect(country.localizedName('uk'), 'Україна');
    expect(country.localizedName('en'), 'Ukraine');
    expect(country.localizedName('ru'), 'Україна');
  });

  test('countryNameSortColumn відповідає мові інтерфейсу', () {
    expect(countryNameSortColumn('uk'), CountrySortColumn.nameUk);
    expect(countryNameSortColumn('en'), CountrySortColumn.nameEn);
    expect(countryNameSortColumn('ru'), CountrySortColumn.nameRu);
    expect(isCountryNameSortColumn(CountrySortColumn.nameUk), isTrue);
    expect(isCountryNameSortColumn(CountrySortColumn.codeAlpha2), isFalse);
  });

  test('CurrencyReference.fromJson читає курс і активність', () {
    final currency = CurrencyReference.fromJson({
      'code': 'USD',
      'numericCode': 840,
      'nameUk': 'Долар США',
      'nameEn': 'US Dollar',
      'nameRu': null,
      'nbuUnits': 1,
      'minorUnits': 2,
      'isActive': true,
      'latestNbuRatePerUnit': 41.25,
      'latestRateDate': '2026-09-01',
    });

    expect(currency.code, 'USD');
    expect(currency.isActive, isTrue);
    expect(currency.latestNbuRatePerUnit, 41.25);
    expect(currency.localizedName('en'), 'US Dollar');
    expect(currency.localizedName('ru'), 'Долар США');
  });

  test('NbuRatesSnapshot.fromJson читає список курсів', () {
    final snapshot = NbuRatesSnapshot.fromJson({
      'rateDate': '2026-09-01',
      'fetchedAt': '2026-09-01T10:00:00Z',
      'rates': [
        {
          'currencyCode': 'EUR',
          'rate': 45.1,
          'ratePerUnit': 45.1,
          'nbuUnits': 1,
          'special': null,
        },
      ],
    });

    expect(snapshot.rateDate, '2026-09-01');
    expect(snapshot.rates, hasLength(1));
    expect(snapshot.rates.first.currencyCode, 'EUR');
  });

  test('formatDirectoryIsoDate формат yyyy-MM-dd', () {
    expect(formatDirectoryIsoDate(DateTime(2026, 9, 1)), '2026-09-01');
  });

  test('sortCountryReferences сортує за ISO-2 за зростанням і спаданням', () {
    const countries = [
      CountryReference(
        codeAlpha2: 'UA',
        codeAlpha3: 'UKR',
        nameUk: 'Україна',
        nameEn: 'Ukraine',
        nameRu: 'Украина',
      ),
      CountryReference(
        codeAlpha2: 'DE',
        codeAlpha3: 'DEU',
        nameUk: 'Німеччина',
        nameEn: 'Germany',
        nameRu: 'Германия',
      ),
      CountryReference(
        codeAlpha2: 'PL',
        codeAlpha3: 'POL',
        nameUk: 'Польща',
        nameEn: 'Poland',
        nameRu: 'Польша',
      ),
    ];

    final asc = sortCountryReferences(
      countries,
      column: CountrySortColumn.codeAlpha2,
      ascending: true,
    );
    expect(asc.map((c) => c.codeAlpha2), ['DE', 'PL', 'UA']);

    final desc = sortCountryReferences(
      countries,
      column: CountrySortColumn.nameEn,
      ascending: false,
    );
    expect(desc.map((c) => c.nameEn), ['Ukraine', 'Poland', 'Germany']);
  });
}
