import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/features/directories/ui/directories_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Хаб довідників показує три посилання і відкриває країни', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/directories',
      routes: [
        GoRoute(
          path: '/directories',
          builder: (context, state) => const DirectoriesPage(),
        ),
        GoRoute(
          path: '/directories/countries',
          builder: (context, state) => const Text('countries-page'),
        ),
        GoRoute(
          path: '/directories/currencies',
          builder: (context, state) => const Text('currencies-page'),
        ),
        GoRoute(
          path: '/directories/exchange-rates',
          builder: (context, state) => const Text('rates-page'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Довідник країн'), findsOneWidget);
    expect(find.text('Довідник валют'), findsOneWidget);
    expect(find.text('Довідник курсів валют'), findsOneWidget);

    await tester.tap(find.byKey(const Key('directory-countries')));
    await tester.pumpAndSettle();

    expect(find.text('countries-page'), findsOneWidget);
  });

  testWidgets('Посилання відкривають довідник валют і курсів', (tester) async {
    final router = GoRouter(
      initialLocation: '/directories',
      routes: [
        GoRoute(
          path: '/directories',
          builder: (context, state) => const DirectoriesPage(),
        ),
        GoRoute(
          path: '/directories/currencies',
          builder: (context, state) => const Text('currencies-page'),
        ),
        GoRoute(
          path: '/directories/exchange-rates',
          builder: (context, state) => const Text('rates-page'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('uk'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('directory-currencies')));
    await tester.pumpAndSettle();
    expect(find.text('currencies-page'), findsOneWidget);

    router.go('/directories');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('directory-exchange-rates')));
    await tester.pumpAndSettle();
    expect(find.text('rates-page'), findsOneWidget);
  });
}
