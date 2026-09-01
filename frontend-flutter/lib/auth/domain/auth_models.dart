import 'dart:convert';

import '../../core/http/api_error.dart';

enum UserRole { admin, manager, driver, user }

UserRole normalizeUserRole(String raw) {
  final normalized = raw.trim().toLowerCase();
  return UserRole.values.firstWhere(
    (role) => role.name == normalized,
    orElse: () => UserRole.user,
  );
}

class AuthUser {
  const AuthUser({required this.id, required this.email, required this.role});

  final String id;
  final String email;
  final UserRole role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: normalizeUserRole(json['role']?.toString() ?? 'user'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role.name};
  }
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: _readInt(json['expiresIn']) ?? 0,
      user: AuthUser.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class AuthState {
  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.sessionRestored = false,
  });

  final String? accessToken;
  final String? refreshToken;
  final AuthUser? user;
  final bool sessionRestored;

  bool get isAuthenticated => accessToken != null && user != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    AuthUser? user,
    bool? sessionRestored,
    bool clearTokens = false,
    bool clearUser = false,
  }) {
    return AuthState(
      accessToken: clearTokens ? null : accessToken ?? this.accessToken,
      refreshToken: clearTokens ? null : refreshToken ?? this.refreshToken,
      user: clearUser ? null : user ?? this.user,
      sessionRestored: sessionRestored ?? this.sessionRestored,
    );
  }
}

enum LoginErrorCode {
  error401,
  error403,
  accountDisabled,
  userDeleted,
  emailNotVerified,
  generic,
}

LoginErrorCode mapLoginErrorCode(ApiException error) {
  final code = error.code;
  if (error.statusCode == 403 && code == 'EMAIL_NOT_VERIFIED') {
    return LoginErrorCode.emailNotVerified;
  }
  if (error.statusCode == 403 && code == 'ACCOUNT_DISABLED') {
    return LoginErrorCode.accountDisabled;
  }
  if (error.statusCode == 403 && code == 'USER_DELETED') {
    return LoginErrorCode.userDeleted;
  }
  if (error.statusCode == 401) {
    return LoginErrorCode.error401;
  }
  if (error.statusCode == 403) {
    return LoginErrorCode.error403;
  }
  return LoginErrorCode.generic;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

const accessTokenExpirySkewSeconds = 30;
const sessionBootstrapTimeout = Duration(seconds: 20);

/// Декодує exp з JWT без перевірки підпису (лише для client-side skew).
int? decodeJwtExp(String token) {
  final parts = token.split('.');
  if (parts.length < 2) {
    return null;
  }

  try {
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    final padding = payload.length % 4;
    if (padding > 0) {
      payload = payload.padRight(payload.length + (4 - padding), '=');
    }

    final decoded = utf8.decode(base64.decode(payload));
    final json = jsonDecode(decoded);
    if (json is Map<String, dynamic>) {
      return _readInt(json['exp']);
    }
  } on Object {
    return null;
  }
  return null;
}

bool isAccessTokenExpired(String? token) {
  if (token == null || token.isEmpty) {
    return true;
  }

  final exp = decodeJwtExp(token);
  if (exp == null) {
    return false;
  }

  final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  return exp <= nowSeconds + accessTokenExpirySkewSeconds;
}
