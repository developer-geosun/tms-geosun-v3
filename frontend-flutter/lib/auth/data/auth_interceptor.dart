import 'package:dio/dio.dart';

import '../../core/http/api_client.dart';
import '../../core/http/api_error.dart';
import '../state/auth_controller.dart';

/// Додає Bearer access token і виконує одноразовий refresh при 401.
class AuthInterceptor extends QueuedInterceptor
    implements AuthInterceptorMarker {
  AuthInterceptor({required this.dio, required this.authController});

  final Dio dio;
  final AuthController authController;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = authController.currentAccessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.uri.toString();

    if (statusCode != 401 ||
        err.requestOptions.extra['skipAuth'] == true ||
        isAuthEndpointPath(path)) {
      return handler.next(err);
    }

    try {
      final newToken = await authController.refreshAccessToken();
      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch<dynamic>(request);
      return handler.resolve(response);
    } on ApiException catch (error) {
      if (error.isSessionRejected && authController.isSessionRestored) {
        await authController.clearSession();
      }
      return handler.next(err);
    } on Object {
      return handler.next(err);
    }
  }
}
