import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tms_geosun/auth/domain/auth_models.dart';
import 'package:tms_geosun/auth/state/auth_controller.dart';
import 'package:tms_geosun/auth/ui/register_page.dart';
import 'package:tms_geosun/core/http/api_error.dart';
import 'package:tms_geosun/core/http/health_service.dart';
import 'package:tms_geosun/core/l10n/app_localizations.dart';
import 'package:tms_geosun/core/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Register не викликає API при невалідній формі', (tester) async {
    final fakeAuth = await _pumpRegister(tester);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(fakeAuth.registerCalls, 0);
    expect(find.text('Введіть email'), findsOneWidget);
  });

  testWidgets('Register не викликає API, якщо паролі різні', (tester) async {
    final fakeAuth = await _pumpRegister(tester);

    await _fillForm(
      tester,
      email: 'user@example.com',
      password: 'password123',
      confirm: 'password124',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(fakeAuth.registerCalls, 0);
    expect(find.text('Паролі не збігаються'), findsOneWidget);
  });

  testWidgets('Register не викликає API без літери або цифри', (tester) async {
    final fakeAuth = await _pumpRegister(tester);

    await _fillForm(
      tester,
      email: 'user@example.com',
      password: 'abcdefgh',
      confirm: 'abcdefgh',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(fakeAuth.registerCalls, 0);
    expect(
      find.text('Пароль має містити щонайменше одну літеру та одну цифру'),
      findsOneWidget,
    );
  });

  testWidgets('Register показує 409 від backend', (tester) async {
    final fakeAuth = await _pumpRegister(tester);
    fakeAuth.registerError = const ApiException(
      statusCode: 409,
      message: 'Email is already registered',
    );

    await _fillForm(
      tester,
      email: 'user@example.com',
      password: 'password123',
      confirm: 'password123',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(fakeAuth.registerCalls, 1);
    expect(find.text('Користувач з таким email вже існує'), findsOneWidget);
  });

  testWidgets('Register після успіху переходить на /login', (tester) async {
    final fakeAuth = await _pumpRegister(tester, withRouter: true);

    await _fillForm(
      tester,
      email: 'user@example.com',
      password: 'password123',
      confirm: 'password123',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(fakeAuth.registerCalls, 1);
    expect(fakeAuth.lastEmail, 'user@example.com');
    expect(fakeAuth.lastPassword, 'password123');
    expect(find.text('login-page'), findsOneWidget);
  });
}

Future<_FakeAuthController> _pumpRegister(
  WidgetTester tester, {
  bool withRouter = false,
}) async {
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

  const localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  if (withRouter) {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('uk'),
          localizationsDelegates: localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            initialLocation: '/register',
            routes: [
              GoRoute(
                path: '/register',
                builder: (context, state) => const RegisterPage(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) =>
                    const Scaffold(body: Text('login-page')),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('uk'),
          localizationsDelegates: localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RegisterPage(),
        ),
      ),
    );
  }
  await tester.pumpAndSettle();
  return fakeAuth;
}

Future<void> _fillForm(
  WidgetTester tester, {
  required String email,
  required String password,
  required String confirm,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.enterText(fields.at(2), confirm);
  await tester.pump();
}

class _FakeAuthController extends AuthController {
  int registerCalls = 0;
  String? lastEmail;
  String? lastPassword;
  ApiException? registerError;

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    registerCalls++;
    lastEmail = email;
    lastPassword = password;
    final error = registerError;
    if (error != null) {
      throw error;
    }
    return AuthUser(id: 'u1', email: email, role: UserRole.user);
  }
}

class _FakeBackendAvailability extends BackendAvailabilityNotifier {
  @override
  bool? build() => true;

  @override
  Future<void> checkOnStartup() async {}
}
