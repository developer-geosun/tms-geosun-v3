import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/core/widgets/app_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Тривалість snackbar: успіх 5 с, помилка 10 с', () {
    expect(AppSnackKind.success.duration, const Duration(seconds: 5));
    expect(AppSnackKind.error.duration, const Duration(seconds: 10));
  });

  testWidgets('Успішний snackbar — primary, кільце таймера, закриття хрестом', (
    tester,
  ) async {
    await _pumpSnackHost(tester);
    await tester.tap(find.text('success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    final scheme = Theme.of(tester.element(find.byType(SnackBar))).colorScheme;
    expect(snack.backgroundColor, scheme.primary);
    expect(snack.duration, const Duration(seconds: 5));
    expect(find.text('Збережено'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('app-snack-close')), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-snack-close')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Помилковий snackbar — error, 10 с', (tester) async {
    await _pumpSnackHost(tester);
    await tester.tap(find.text('error'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    final scheme = Theme.of(tester.element(find.byType(SnackBar))).colorScheme;
    expect(snack.backgroundColor, scheme.error);
    expect(snack.duration, const Duration(seconds: 10));
    expect(find.text('Не вдалося'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-snack-close')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SnackBar), findsNothing);
  });
}

Future<void> _pumpSnackHost(WidgetTester tester) {
  return tester.pumpWidget(
    const MaterialApp(
      locale: Locale('uk'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _SnackHost(),
    ),
  );
}

class _SnackHost extends StatelessWidget {
  const _SnackHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () => showAppSnack(
              context,
              message: 'Збережено',
              kind: AppSnackKind.success,
            ),
            child: const Text('success'),
          ),
          TextButton(
            onPressed: () => showAppSnack(
              context,
              message: 'Не вдалося',
              kind: AppSnackKind.error,
            ),
            child: const Text('error'),
          ),
        ],
      ),
    );
  }
}
