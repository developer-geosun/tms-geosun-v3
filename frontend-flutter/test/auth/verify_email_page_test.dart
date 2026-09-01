import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tms_geosun/auth/state/auth_controller.dart';
import 'package:tms_geosun/auth/ui/verify_email_page.dart';
import 'package:tms_geosun/core/http/health_service.dart';
import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/core/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VerifyEmail без токена показує помилку посилання', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fakeAuth = _FakeAuthController();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        backendAvailabilityProvider.overrideWith(_FakeBackendAvailability.new),
        authControllerProvider.overrideWith(() => fakeAuth),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('uk'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const VerifyEmailPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(fakeAuth.verifyCalls, 0);
    expect(
      find.text('Посилання підтвердження недійсне або застаріле'),
      findsOneWidget,
    );
  });
}

class _FakeAuthController extends AuthController {
  int verifyCalls = 0;

  @override
  Future<void> verifyEmail({required String token}) async {
    verifyCalls++;
  }
}

class _FakeBackendAvailability extends BackendAvailabilityNotifier {
  @override
  bool? build() => true;

  @override
  Future<void> checkOnStartup() async {}
}
