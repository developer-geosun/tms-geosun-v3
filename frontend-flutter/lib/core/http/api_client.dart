import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'api_error.dart';

/// Фабрика Dio з базовими заголовками та JSON-конфігурацією.
class ApiClient {
  ApiClient(this._config) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          ...ngrokSkipBrowserWarningHeaders,
          ...appClientHeaders,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  final AppConfig _config;
  late final Dio _dio;

  Dio get dio => _dio;

  String get baseUrl => _config.apiUrl;

  void setAuthInterceptor(Interceptor interceptor) {
    _dio.interceptors.removeWhere((item) => item is AuthInterceptorMarker);
    _dio.interceptors.add(interceptor);
  }
}

/// Маркер для заміни auth-interceptor без видалення інших.
abstract class AuthInterceptorMarker implements Interceptor {}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config);
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiClientProvider).dio;
});
