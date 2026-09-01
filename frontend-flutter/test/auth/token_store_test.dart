import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tms_geosun/auth/data/token_store.dart';
import 'package:tms_geosun/auth/domain/auth_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TokenStore зберігає та відновлює auth state', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = TokenStore(prefs);

    const state = AuthState(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      user: AuthUser(
        id: 'user-1',
        email: 'driver@example.com',
        role: UserRole.driver,
      ),
    );

    await store.save(state);
    final restored = await store.load();

    expect(restored.accessToken, 'access-token');
    expect(restored.refreshToken, 'refresh-token');
    expect(restored.user?.email, 'driver@example.com');
    expect(restored.user?.role, UserRole.driver);
  });

  test('TokenStore.clear видаляє збережену сесію', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = TokenStore(prefs);

    await store.save(
      const AuthState(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    );
    await store.clear();

    final restored = await store.load();
    expect(restored.accessToken, isNull);
    expect(restored.refreshToken, isNull);
  });
}
