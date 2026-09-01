import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/http/api_client.dart';
import '../../core/http/api_error.dart';
import '../../core/l10n/locale_controller.dart';
import '../data/auth_api.dart';
import '../data/auth_interceptor.dart';
import '../data/token_store.dart';
import '../domain/auth_models.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenStore(prefs);
});

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return AuthApi(dio, config);
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Керування JWT-сесією (login / refresh / logout / bootstrap).
class AuthController extends Notifier<AuthState> {
  late TokenStore _tokenStore;
  late AuthApi _authApi;

  int _sessionEpoch = 0;
  Future<String>? _refreshInFlight;

  String? get currentAccessToken => state.accessToken;

  bool get isSessionRestored => state.sessionRestored;

  @override
  AuthState build() {
    _tokenStore = ref.read(tokenStoreProvider);
    _authApi = ref.read(authApiProvider);
    return const AuthState();
  }

  /// Підключає auth-interceptor до Dio після створення контролера.
  void attachInterceptor() {
    final apiClient = ref.read(apiClientProvider);
    apiClient.setAuthInterceptor(
      AuthInterceptor(dio: apiClient.dio, authController: this),
    );
  }

  /// Завантажує збережену сесію та перевіряє її на backend.
  Future<void> bootstrap() async {
    final stored = await _tokenStore.load();
    state = stored;

    await verifySessionOnStartup();
  }

  /// Для тестів: завантажити сесію зі сховища без verifySessionOnStartup.
  Future<void> loadStoredSessionForTest() async {
    state = await _tokenStore.load();
  }

  Future<void> verifySessionOnStartup() async {
    final accessToken = state.accessToken;
    final refreshToken = state.refreshToken;

    if (accessToken == null && refreshToken == null) {
      _markSessionRestored();
      return;
    }

    try {
      await _restoreSession().timeout(
        sessionBootstrapTimeout,
        onTimeout: () {},
      );
    } on ApiException catch (error) {
      if (error.isSessionRejected) {
        await clearSession();
      }
    } on Object {
      // Таймаут або офлайн — не очищаємо сесію (як у Angular).
    } finally {
      _markSessionRestored();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final tokens = await _authApi.login(
      LoginRequest(email: email.trim(), password: password),
    );
    await _applyTokens(tokens);
  }

  /// Реєстрація без сесії: токени з'являться лише після підтвердження email.
  Future<AuthUser> register({required String email, required String password}) {
    return _authApi.register(
      RegisterRequest(email: email.trim(), password: password),
    );
  }

  Future<void> verifyEmail({required String token}) {
    return _authApi.verifyEmail(token: token.trim());
  }

  Future<void> forgotPassword({required String email}) {
    return _authApi.forgotPassword(ForgotPasswordRequest(email: email.trim()));
  }

  Future<String> passwordResetInfo({required String token}) {
    return _authApi.passwordResetInfo(token: token);
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _authApi.resetPassword(
      ResetPasswordRequest(token: token, newPassword: newPassword),
    );
  }

  Future<void> logout() async {
    final accessToken = state.accessToken;
    if (accessToken != null) {
      try {
        await _authApi.logout(accessToken: accessToken);
      } on ApiException {
        // Навіть якщо logout на сервері не вдався — локально сесію очищаємо.
      }
    }
    await clearSession();
  }

  Future<String> refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight!;
    }

    final epoch = _sessionEpoch;
    _refreshInFlight = _performRefresh(epoch).whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<void> clearSession() async {
    _sessionEpoch++;
    _refreshInFlight = null;
    state = state.copyWith(clearTokens: true, clearUser: true);
    await _tokenStore.clear();
  }

  Future<AuthUser> fetchMe() async {
    final accessToken = state.accessToken;
    if (accessToken == null) {
      throw const ApiException(
        statusCode: 401,
        message: 'Access token missing',
      );
    }
    final user = await _authApi.me(accessToken: accessToken);
    state = state.copyWith(user: user);
    await _tokenStore.save(state);
    return user;
  }

  Future<void> _restoreSession() async {
    if (state.accessToken != null && !isAccessTokenExpired(state.accessToken)) {
      await fetchMe();
      return;
    }

    await refreshAccessToken();
    await fetchMe();
  }

  Future<String> _performRefresh(int epoch) async {
    final refreshToken = state.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException(
        statusCode: 401,
        message: 'Refresh token missing',
      );
    }

    try {
      final tokens = await _authApi.refresh(
        RefreshRequest(refreshToken: refreshToken),
      );
      if (epoch != _sessionEpoch) {
        throw const ApiException(
          statusCode: 401,
          message: 'Stale refresh response ignored',
        );
      }
      await _applyTokens(tokens);
      return tokens.accessToken;
    } on ApiException catch (error) {
      if (error.isSessionRejected) {
        await clearSession();
      }
      rethrow;
    }
  }

  Future<void> _applyTokens(AuthTokens tokens) async {
    state = state.copyWith(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: tokens.user,
    );
    await _tokenStore.save(state);
  }

  void _markSessionRestored() {
    if (!state.sessionRestored) {
      state = state.copyWith(sessionRestored: true);
    }
  }
}
