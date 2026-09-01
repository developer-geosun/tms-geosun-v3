import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tms_geosun/core/config/app_config.dart';
import 'package:tms_geosun/core/http/api_error.dart';
import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/features/directories/data/directories_api.dart';
import 'package:tms_geosun/features/directories/domain/directory_models.dart';
import 'package:tms_geosun/features/directories/ui/countries_directory_page.dart';
import 'package:tms_geosun/features/directories/ui/countries_paged_table.dart';
import 'package:tms_geosun/features/directories/ui/directory_page_body.dart';

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
      expect(find.byType(DirectoryLoadProgress), findsOneWidget);
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

      final stripeScheme = Theme.of(
        tester.element(find.byType(CountriesPagedTable)),
      ).colorScheme;
      expect(
        tester
            .widget<ColoredBox>(
              find
                  .ancestor(
                    of: find.text('DE'),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        stripeScheme.surface,
      );
      expect(
        tester
            .widget<ColoredBox>(
              find
                  .ancestor(
                    of: find.text('PL'),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        stripeScheme.surfaceContainerHighest,
      );

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
      for (var i = 0; i < 51; i++)
        CountryReference(
          codeAlpha2: i.toString().padLeft(2, '0'),
          codeAlpha3: i.toString().padLeft(3, '0'),
          nameUk: 'Країна $i',
          nameEn: 'Country $i',
          nameRu: 'Страна $i',
        ),
    ];

    await _pumpCountriesPage(tester, countries, size: const Size(400, 800));
    await tester.pumpAndSettle();

    expect(find.text('Країна 0'), findsOneWidget);
    expect(find.text('Країна 50'), findsNothing);

    await tester.tap(find.byTooltip('Наступна сторінка'));
    await tester.pumpAndSettle();

    expect(find.text('Країна 0'), findsNothing);
    expect(find.text('Країна 50'), findsOneWidget);
  });

  testWidgets('Пагінація показує наступну сторінку країн', (tester) async {
    final countries = [
      for (var i = 0; i < 51; i++)
        CountryReference(
          codeAlpha2: i.toString().padLeft(2, '0'),
          codeAlpha3: i.toString().padLeft(3, '0'),
          nameUk: 'Країна $i',
          nameEn: 'Country $i',
          nameRu: 'Страна $i',
        ),
    ];

    await _pumpCountriesPage(tester, countries, size: const Size(1200, 900));
    await tester.pumpAndSettle();

    expect(find.text('Country 0'), findsOneWidget);
    expect(find.text('Country 50'), findsNothing);

    await tester.tap(find.byTooltip('Наступна сторінка'));
    await tester.pumpAndSettle();

    expect(find.text('Country 0'), findsNothing);
    expect(find.text('Country 50'), findsOneWidget);
  });

  test('За замовчуванням і максимум записів на сторінці — 50', () {
    expect(CountriesDirectoryPage.defaultPageSize, 50);
    expect(CountriesDirectoryPage.maxPageSize, 50);
    expect(
      CountriesDirectoryPage.pageSizeOptions.every(
        (size) => size <= CountriesDirectoryPage.maxPageSize,
      ),
      isTrue,
    );
  });

  testWidgets(
    'Помилка завантаження країн показується у snackbar, не на сторінці',
    (tester) async {
      await _pumpCountriesPage(
        tester,
        const [],
        size: const Size(1200, 900),
        throwOnList: true,
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Не вдалося завантажити довідник'),
        ),
        findsOneWidget,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byKey(const Key('app-snack-close')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}

Future<void> _pumpCountriesPage(
  WidgetTester tester,
  List<CountryReference> countries, {
  required Size size,
  bool throwOnList = false,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        directoriesApiProvider.overrideWithValue(
          _FakeDirectoriesApi(countries, throwOnList: throwOnList),
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
  _FakeDirectoriesApi(this.countries, {this.throwOnList = false})
    : super(Dio(), const AppConfig(apiUrl: 'http://test'));

  final List<CountryReference> countries;
  final bool throwOnList;

  @override
  Future<List<CountryReference>> listCountries({String? search}) async {
    if (throwOnList) {
      throw const ApiException(statusCode: 500, message: 'fail');
    }
    return countries;
  }
}
