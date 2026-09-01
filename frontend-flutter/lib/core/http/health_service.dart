import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'api_client.dart';

/// Перевірка доступності backend через actuator health.
class HealthService {
  HealthService(this._dio, this._config);

  final Dio _dio;
  final AppConfig _config;

  static const Duration _timeout = Duration(seconds: 5);

  Future<bool> checkAvailability() async {
    try {
      final readiness = await _dio
          .get<Map<String, dynamic>>(
            _config.apiPath('/actuator/health/readiness'),
            options: Options(
              extra: const {'skipAuth': true},
              receiveTimeout: _timeout,
              sendTimeout: _timeout,
            ),
          )
          .timeout(_timeout);

      if (_isHealthy(readiness.data)) {
        return true;
      }
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) {
        return false;
      }
    } on Object {
      return false;
    }

    try {
      final health = await _dio
          .get<Map<String, dynamic>>(
            _config.apiPath('/actuator/health'),
            options: Options(
              extra: const {'skipAuth': true},
              receiveTimeout: _timeout,
              sendTimeout: _timeout,
            ),
          )
          .timeout(_timeout);

      return _isHealthy(health.data);
    } on Object {
      return false;
    }
  }

  bool _isHealthy(Map<String, dynamic>? payload) {
    return payload?['status']?.toString() == 'UP';
  }
}

final healthServiceProvider = Provider<HealthService>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = ref.watch(dioProvider);
  return HealthService(dio, config);
});

final backendAvailabilityProvider =
    NotifierProvider<BackendAvailabilityNotifier, bool?>(
      BackendAvailabilityNotifier.new,
    );

/// null = ще не перевірено; true/false — результат health-check.
class BackendAvailabilityNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  Future<void> checkOnStartup() async {
    final health = ref.read(healthServiceProvider);
    state = await health.checkAvailability();
  }
}
