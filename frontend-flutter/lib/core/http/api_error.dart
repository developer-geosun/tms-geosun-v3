import 'package:dio/dio.dart';

/// Помилка REST API з полем code (як у Spring GlobalExceptionHandler).
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.path,
  });

  final int statusCode;
  final String message;
  final String? code;
  final String? path;

  bool get isSessionRejected => statusCode == 401 || statusCode == 403;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        statusCode: _readInt(data['status']) ?? response?.statusCode ?? 0,
        message:
            data['message']?.toString() ?? error.message ?? 'Unknown error',
        code: data['code']?.toString(),
        path: data['path']?.toString(),
      );
    }

    return ApiException(
      statusCode: response?.statusCode ?? 0,
      message: error.message ?? 'Network error',
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

/// Заголовок для обходу interstitial-сторінки ngrok (як у Angular).
const Map<String, String> ngrokSkipBrowserWarningHeaders = {
  'ngrok-skip-browser-warning': 'true',
};

/// Ідентифікатор Flutter-клієнта для посилань у листах.
const Map<String, String> appClientHeaders = {'X-App-Client': 'flutter'};

bool isAuthEndpointPath(String path) {
  return path.contains('/auth/login') ||
      path.contains('/auth/register') ||
      path.contains('/auth/refresh') ||
      path.contains('/auth/logout') ||
      path.contains('/auth/verify-email') ||
      path.contains('/auth/forgot-password') ||
      path.contains('/auth/reset-password-info') ||
      path.contains('/auth/reset-password') ||
      path.contains('/auth/me');
}
