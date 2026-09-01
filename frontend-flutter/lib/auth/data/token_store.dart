import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/locale_controller.dart';
import '../domain/auth_models.dart';

/// Зберігання auth-стану у SharedPreferences (web → localStorage).
class TokenStore {
  TokenStore(this._prefs);

  final SharedPreferences _prefs;

  Future<AuthState> load() async {
    final raw = _prefs.getString(authStorageKey);
    if (raw == null || raw.isEmpty) {
      return const AuthState();
    }

    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) {
        return const AuthState();
      }

      final userJson = parsed['user'];
      return AuthState(
        accessToken: parsed['accessToken']?.toString(),
        refreshToken: parsed['refreshToken']?.toString(),
        user: userJson is Map<String, dynamic>
            ? AuthUser.fromJson(userJson)
            : null,
      );
    } on Object {
      return const AuthState();
    }
  }

  Future<void> save(AuthState state) async {
    final payload = jsonEncode({
      'accessToken': state.accessToken,
      'refreshToken': state.refreshToken,
      'user': state.user?.toJson(),
    });
    await _prefs.setString(authStorageKey, payload);
  }

  Future<void> clear() async {
    await _prefs.remove(authStorageKey);
  }
}
