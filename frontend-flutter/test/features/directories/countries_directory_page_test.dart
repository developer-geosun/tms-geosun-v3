import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tms_geosun/core/config/app_config.dart';
import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/features/directories/data/directories_api.dart';
import 'package:tms_geosun/features/directories/domain/directory_models.dart';
import 'package:tms_geosun/features/directories/ui/countries_directory_page.dart';
import 'package:tms_geosun/features/directories/ui/countries_paged_table.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleCountries = [
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

  testWidgets(
    'Таблиця країн має шапку secondaryContainer та сортовані заголовки',
    (tester) async {
      await _pumpCountriesPage(
        tester,
        sampleCountries,
        size: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaginatedDataTable), findsNothing);
      expect(find.byType(CountriesPagedTable), findsOneWidget);
      expect(find.byType(Scrollbar), findsWidgets);
      expect(find.text('ISO-2'), findsOneWidget);
      expect(find.text('ISO-3'), findsOneWidget);
      expect(find.text('Назва (UA)'), findsOneWidget);
      expect(find.text('Назва (EN)'), findsOneWidget);
      expect(find.text('Назва (RU)'), findsOneWidget);

      final headerStyle = tester.widget<Text>(find.text('ISO-2')).style;
      final onHeader = Theme.of(tester.element(find.text('ISO-2')))
          .colorScheme
          .onSecondaryContainer;
      expect(headerStyle?.color, onHeader);

      expect(find.text('DE'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);

      await tester.tap(find.text('Назва (EN)'));
      await tester.pumpAndSettle();

      final germanyY = tester.getTopLeft(find.text('Germany')).dy;
      final ukraineY = tester.getTopLeft(find.text('Ukraine')).dy;
      expect(germanyY, lessThan(ukraineY));
    },
  );

  testWidgets(
    'На смартфоні один стовпець назви мовою інтерфейсу та пагінація внизу',
    (tester) async {
      await _pumpCountriesPage(
        tester,
        sampleCountries,
        size: const Size(400, 800),
      );
      await tester.pumpAndSettle();

      expect(find.text('ISO-2'), findsOneWidget);
      expect(find.text('ISO-3'), findsOneWidget);
      expect(find.text('Назва'), findsOneWidget);
      expect(find.text('Назва (UA)'), findsNothing);
      expect(find.text('Назва (EN)'), findsNothing);
      expect(find.text('Назва (RU)'), findsNothing);
      expect(find.text('Україна'), findsOneWidget);
      expect(find.text('Ukraine'), findsNothing);
      expect(find.text('Німеччина'), findsOneWidget);

      final tableBottom = tester
          .getBottomLeft(find.byType(CountriesPagedTable))
          .dy;
      final paginatorTop = tester
          .getTopLeft(find.textContaining('Рядків на сторінці'))
          .dy;
      expect(paginatorTop, lessThan(tableBottom));
      expect(
        paginatorTop,
        greaterThan(tester.getTopLeft(find.text('Україна')).dy),
      );
    },
  );

  testWidgets('Пагінація на смартфоні показує наступну сторінку', (
    tester,
  ) async {
    final countries = [
      for (var i = 0; i < 12; i++)
        CountryReference(
          codeAlpha2: '${String.fromCharCode(65 + i)}A',
          codeAlpha3: '${String.fromCharCode(65 + i)}AA',
          nameUk: 'Країна $i',
          nameEn: 'Country $i',
          nameRu: 'Страна $i',
        ),
    ];

    await _pumpCountriesPage(tester, countries, size: const Size(400, 800));
    await tester.pumpAndSettle();

    expect(find.text('Країна 0'), findsOneWidget);
    expect(find.text('Країна 5'), findsNothing);

    await tester.tap(find.byTooltip('Наступна сторінка'));
    await tester.pumpAndSettle();

    expect(find.text('Країна 0'), findsNothing);
    expect(find.text('Країна 5'), findsOneWidget);
  });

  testWidgets('Пагінація показує наступну сторінку країн', (tester) async {
    final countries = [
      for (var i = 0; i < 12; i++)
        CountryReference(
          codeAlpha2: '${String.fromCharCode(65 + i)}A',
          codeAlpha3: '${String.fromCharCode(65 + i)}AA',
          nameUk: 'Країна $i',
          nameEn: 'Country $i',
          nameRu: 'Страна $i',
        ),
    ];

    await _pumpCountriesPage(tester, countries, size: const Size(1200, 900));
    await tester.pumpAndSettle();

    expect(find.text('Country 0'), findsOneWidget);
    expect(find.text('Country 10'), findsNothing);

    await tester.tap(find.byTooltip('Наступна сторінка'));
    await tester.pumpAndSettle();

    expect(find.text('Country 0'), findsNothing);
    expect(find.text('Country 10'), findsOneWidget);
  });

  test('Максимум записів на сторінці — 50', () {
    expect(CountriesDirectoryPage.maxPageSize, 50);
    expect(
      CountriesDirectoryPage.pageSizeOptions.every(
        (size) => size <= CountriesDirectoryPage.maxPageSize,
      ),
      isTrue,
    );
  });
}

Future<void> _pumpCountriesPage(
  WidgetTester tester,
  List<CountryReference> countries, {
  required Size size,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        directoriesApiProvider.overrideWithValue(
          _FakeDirectoriesApi(countries),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CountriesDirectoryPage()),
      ),
    ),
  );
}

class _FakeDirectoriesApi extends DirectoriesApi {
  _FakeDirectoriesApi(this.countries)
    : super(Dio(), const AppConfig(apiUrl: 'http://test'));

  final List<CountryReference> countries;

  @override
  Future<List<CountryReference>> listCountries({String? search}) async {
    return countries;
  }
}
