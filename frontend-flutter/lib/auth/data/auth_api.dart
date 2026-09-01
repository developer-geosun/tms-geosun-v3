import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/http/api_error.dart';
import '../domain/auth_models.dart';

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RefreshRequest {
  const RefreshRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

/// REST-клієнт auth endpoint-ів без codegen.
class AuthApi {
  AuthApi(this._dio, this._config);

  final Dio _dio;
  final AppConfig _config;

  Future<AuthTokens> login(LoginRequest request) async {
    return _postTokens(_config.authPath('/login'), data: request.toJson());
  }

  Future<AuthTokens> refresh(RefreshRequest request) async {
    return _postTokens(_config.authPath('/refresh'), data: request.toJson());
  }

  Future<void> logout({required String accessToken}) async {
    try {
      await _dio.post<void>(
        _config.authPath('/logout'),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          extra: const {'skipAuth': true},
        ),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthUser> me({required String accessToken}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.authPath('/me'),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          extra: const {'skipAuth': true},
        ),
      );
      return AuthUser.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<AuthTokens> _postTokens(
    String url, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: data,
        options: Options(extra: const {'skipAuth': true}),
      );
      final payload = response.data;
      if (payload == null) {
        throw const ApiException(statusCode: 0, message: 'Empty auth response');
      }
      if (_isApiErrorEnvelope(payload)) {
        throw ApiException(
          statusCode: _readInt(payload['status']) ?? 0,
          message: payload['message']?.toString() ?? 'Auth error',
          code: payload['code']?.toString(),
        );
      }
      return AuthTokens.fromJson(payload);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  bool _isApiErrorEnvelope(Map<String, dynamic> payload) {
    return payload.containsKey('status') &&
        payload.containsKey('message') &&
        !payload.containsKey('accessToken');
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
}
