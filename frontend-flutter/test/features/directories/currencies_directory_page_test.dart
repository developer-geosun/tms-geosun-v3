import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tms_geosun/core/config/app_config.dart';
import 'package:tms_geosun/core/http/api_error.dart';
import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/features/directories/data/directories_api.dart';
import 'package:tms_geosun/features/directories/domain/directory_models.dart';
import 'package:tms_geosun/features/directories/ui/currencies_directory_page.dart';
import 'package:tms_geosun/features/directories/ui/directory_page_body.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleCurrencies = [
    CurrencyReference(
      code: 'USD',
      numericCode: 840,
      nameUk: 'Долар США',
      nameEn: 'US Dollar',
      nameRu: 'Доллар США',
      nbuUnits: 1,
      minorUnits: 2,
      isActive: true,
      latestNbuRatePerUnit: 41.25,
      latestRateDate: '2026-09-01',
    ),
    CurrencyReference(
      code: 'EUR',
      numericCode: 978,
      nameUk: 'Євро',
      nameEn: 'Euro',
      nameRu: 'Евро',
      nbuUnits: 1,
      minorUnits: 2,
      isActive: true,
      latestNbuRatePerUnit: 45.1,
      latestRateDate: '2026-09-01',
    ),
    CurrencyReference(
      code: 'PLN',
      numericCode: 985,
      nameUk: 'Злотий',
      nameEn: 'Zloty',
      nameRu: 'Злотый',
      nbuUnits: 1,
      minorUnits: 2,
      isActive: false,
      latestNbuRatePerUnit: 11.2,
      latestRateDate: '2026-08-31',
    ),
  ];

  testWidgets(
    'Таблиця валют має шапку surfaceContainer та сортовані заголовки',
    (tester) async {
      await _pumpCurrenciesPage(
        tester,
        sampleCurrencies,
        size: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaginatedDataTable), findsNothing);
      expect(find.byKey(const Key('currencies-table')), findsOneWidget);
      expect(find.byType(DirectoryLoadProgress), findsOneWidget);
      expect(find.text('Код'), findsOneWidget);
      expect(find.text('Назва'), findsOneWidget);
      expect(find.text('Од. НБУ'), findsOneWidget);
      expect(find.text('Курс UAH/од.'), findsOneWidget);
      expect(find.text('Дата курсу'), findsOneWidget);

      final scheme = Theme.of(
        tester.element(find.byKey(const Key('currencies-table'))),
      ).colorScheme;
      expect(
        tester
            .widget<ColoredBox>(
              find.byKey(const Key('currencies-table-header')),
            )
            .color,
        scheme.surfaceContainer,
      );
      expect(
        tester.widget<Text>(find.text('Код')).style?.color,
        scheme.primary,
      );

      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('Євро'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(3));
      expect(find.text('Неактивна'), findsNothing);
      expect(find.byTooltip('Наступна сторінка'), findsNothing);
      expect(find.text('3 записи'), findsOneWidget);

      await tester.tap(find.text('Назва'));
      await tester.pumpAndSettle();

      // Unicode: «Євро» перед «Долар»; «Долар» перед «Злотий» — не порядок ISO-кодів.
      final dollarY = tester.getTopLeft(find.text('Долар США')).dy;
      final zlotyY = tester.getTopLeft(find.text('Злотий')).dy;
      expect(dollarY, lessThan(zlotyY));
    },
  );

  testWidgets('На смартфоні код, назва і курс без трьох мов', (tester) async {
    await _pumpCurrenciesPage(
      tester,
      sampleCurrencies,
      size: const Size(400, 800),
    );
    await tester.pumpAndSettle();

    expect(find.text('Код'), findsOneWidget);
    expect(find.text('Назва'), findsOneWidget);
    expect(find.text('Курс UAH/од.'), findsOneWidget);
    expect(find.text('Од. НБУ'), findsNothing);
    expect(find.text('Дата курсу'), findsNothing);
    expect(find.text('Долар США'), findsOneWidget);
    expect(find.text('US Dollar'), findsNothing);
    expect(find.byType(Switch), findsNWidgets(3));

    final tableBottom = tester
        .getBottomLeft(find.byKey(const Key('currencies-table')))
        .dy;
    final paginatorTop = tester
        .getTopLeft(find.textContaining('Рядків на сторінці'))
        .dy;
    expect(paginatorTop, lessThan(tableBottom));
  });

  testWidgets('Пагінація показує наступну сторінку валют', (tester) async {
    final currencies = [
      for (var i = 0; i < 51; i++)
        CurrencyReference(
          code: 'C${i.toString().padLeft(2, '0')}',
          numericCode: i,
          nameUk: 'Валюта $i',
          nameEn: 'Currency $i',
          nbuUnits: 1,
          minorUnits: 2,
          isActive: true,
        ),
    ];

    await _pumpCurrenciesPage(tester, currencies, size: const Size(1200, 900));
    await tester.pumpAndSettle();

    expect(find.text('Валюта 0'), findsOneWidget);
    expect(find.text('Валюта 50'), findsNothing);
    expect(find.textContaining('1–50'), findsOneWidget);

    await tester.tap(find.byTooltip('Наступна сторінка'));
    await tester.pumpAndSettle();

    expect(find.text('Валюта 0'), findsNothing);
    expect(find.text('Валюта 50'), findsOneWidget);
  });

  testWidgets('Пошук валют фільтрує список на клієнті', (tester) async {
    await _pumpCurrenciesPage(
      tester,
      sampleCurrencies,
      size: const Size(1200, 900),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'eur');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('USD'), findsNothing);
    expect(find.text('1 запис'), findsOneWidget);
  });

  testWidgets('Перемикач активності оновлює валюту через API', (tester) async {
    final api = _FakeDirectoriesApi(sampleCurrencies);
    await _pumpCurrenciesPage(
      tester,
      sampleCurrencies,
      size: const Size(1200, 900),
      api: api,
    );
    await tester.pumpAndSettle();

    final plnSwitch = find.byKey(const Key('currency-active-PLN'));
    expect(tester.widget<Switch>(plnSwitch).value, isFalse);

    await tester.tap(plnSwitch);
    await tester.pumpAndSettle();

    expect(api.updatedCodes, ['PLN']);
    expect(api.lastIsActive, isTrue);
    expect(tester.widget<Switch>(plnSwitch).value, isTrue);
  });

  testWidgets(
    'Помилка оновлення валюти показується у snackbar, перемикач не змінюється',
    (tester) async {
      await _pumpCurrenciesPage(
        tester,
        sampleCurrencies,
        size: const Size(1200, 900),
        throwOnUpdate: true,
      );
      await tester.pumpAndSettle();

      final plnSwitch = find.byKey(const Key('currency-active-PLN'));
      await tester.tap(plnSwitch);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Не вдалося оновити валюту'),
        ),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(plnSwitch).value, isFalse);
    },
  );

  testWidgets('Розмір сторінки за замовчуванням — 50', (tester) async {
    expect(CurrenciesDirectoryPage.defaultPageSize, 50);
    expect(CurrenciesDirectoryPage.maxPageSize, 50);
  });

  testWidgets(
    'Помилка завантаження валют показується у snackbar, не на сторінці',
    (tester) async {
      await _pumpCurrenciesPage(
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
    },
  );
}

Future<void> _pumpCurrenciesPage(
  WidgetTester tester,
  List<CurrencyReference> currencies, {
  required Size size,
  bool throwOnList = false,
  bool throwOnUpdate = false,
  _FakeDirectoriesApi? api,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        directoriesApiProvider.overrideWithValue(
          api ??
              _FakeDirectoriesApi(
                currencies,
                throwOnList: throwOnList,
                throwOnUpdate: throwOnUpdate,
              ),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CurrenciesDirectoryPage()),
      ),
    ),
  );
}

class _FakeDirectoriesApi extends DirectoriesApi {
  _FakeDirectoriesApi(
    this.currencies, {
    this.throwOnList = false,
    this.throwOnUpdate = false,
  }) : super(Dio(), const AppConfig(apiUrl: 'http://test'));

  final List<CurrencyReference> currencies;
  final bool throwOnList;
  final bool throwOnUpdate;
  final List<String> updatedCodes = [];
  bool? lastIsActive;

  @override
  Future<List<CurrencyReference>> listCurrencies({
    bool activeOnly = false,
  }) async {
    if (throwOnList) {
      throw const ApiException(statusCode: 500, message: 'fail');
    }
    return currencies;
  }

  @override
  Future<CurrencyReference> updateCurrency({
    required String code,
    required bool isActive,
  }) async {
    if (throwOnUpdate) {
      throw const ApiException(statusCode: 500, message: 'fail');
    }
    updatedCodes.add(code);
    lastIsActive = isActive;
    final current = currencies.firstWhere((item) => item.code == code);
    return current.copyWith(isActive: isActive);
  }
}
