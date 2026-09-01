import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tms_geosun/auth/state/auth_controller.dart';
import 'package:tms_geosun/auth/ui/login_page.dart';
import 'package:tms_geosun/core/http/health_service.dart';
import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/core/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login не викликає API при невалідній формі', (tester) async {
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
          home: const LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(fakeAuth.loginCalls, 0);
    expect(find.text('Введіть email'), findsOneWidget);
  });
}

class _FakeAuthController extends AuthController {
  int loginCalls = 0;

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls++;
  }
}

class _FakeBackendAvailability extends BackendAvailabilityNotifier {
  @override
  bool? build() => true;

  @override
  Future<void> checkOnStartup() async {}
}
