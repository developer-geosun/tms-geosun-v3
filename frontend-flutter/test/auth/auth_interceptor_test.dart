import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tms_geosun/auth/data/auth_api.dart';
import 'package:tms_geosun/auth/data/token_store.dart';
import 'package:tms_geosun/auth/domain/auth_models.dart';
import 'package:tms_geosun/auth/state/auth_controller.dart';
import 'package:tms_geosun/core/config/app_config.dart';
import 'package:tms_geosun/core/http/api_client.dart';
import 'package:tms_geosun/core/http/api_error.dart';
import 'package:tms_geosun/core/l10n/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'refreshAccessToken виконує лише один POST /refresh паралельно',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const config = AppConfig(apiUrl: 'http://localhost:8080');
      final countingApi = _CountingAuthApi(Dio(), config);

      await TokenStore(prefs)
          .save(const AuthState(refreshToken: 'stored-refresh'));

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appConfigProvider.overrideWithValue(config),
          authApiProvider.overrideWithValue(countingApi),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.loadStoredSessionForTest();

      final first = controller.refreshAccessToken();
      final second = controller.refreshAccessToken();
      countingApi.releaseRefresh();

      final results = await Future.wait([first, second]);

      expect(countingApi.refreshCount, 1);
      expect(results, ['new-access', 'new-access']);
    },
  );

  test('AuthInterceptor не рефрешить auth endpoint-и', () {
    expect(
      isAuthEndpointPath('http://localhost:8080/api/v1/auth/login'),
      isTrue,
    );
    expect(
      isAuthEndpointPath('http://localhost:8080/api/v1/auth/refresh'),
      isTrue,
    );
    expect(
      isAuthEndpointPath('http://localhost:8080/api/v1/routes/my'),
      isFalse,
    );
  });
}

class _CountingAuthApi extends AuthApi {
  _CountingAuthApi(super.dio, super.config);

  int refreshCount = 0;
  final Completer<void> _gate = Completer<void>();

  @override
  Future<AuthTokens> refresh(RefreshRequest request) async {
    refreshCount++;
    await _gate.future;
    return const AuthTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      tokenType: 'Bearer',
      expiresIn: 900,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        role: UserRole.driver,
      ),
    );
  }

  void releaseRefresh() {
    if (!_gate.isCompleted) {
      _gate.complete();
    }
  }
}
