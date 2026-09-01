import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/http/api_client.dart';
import '../../../core/http/api_error.dart';
import '../domain/directory_models.dart';

/// REST-клієнт адмін-довідників країн, валют і курсів НБУ.
class DirectoriesApi {
  DirectoriesApi(this._dio, this._config);

  final Dio _dio;
  final AppConfig _config;

  Future<List<CountryReference>> listCountries({String? search}) async {
    final payload = await _getList(
      '/api/v1/admin/country-reference',
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return payload.map(CountryReference.fromJson).toList();
  }

  Future<List<CurrencyReference>> listCurrencies({bool activeOnly = false}) {
    return _getList(
      '/api/v1/admin/currencies',
      query: {'activeOnly': activeOnly.toString()},
    ).then((payload) => payload.map(CurrencyReference.fromJson).toList());
  }

  Future<CurrencyReference> updateCurrency({
    required String code,
    required bool isActive,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        _config.apiPath(
          '/api/v1/admin/currencies/${Uri.encodeComponent(code)}',
        ),
        data: {'isActive': isActive},
      );
      return CurrencyReference.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<NbuRatesSnapshot> getNbuRates({String? rateDate}) async {
    final payload = await _getObject(
      '/api/v1/admin/currencies/nbu-rates',
      query: {
        if (rateDate != null && rateDate.trim().isNotEmpty)
          'rateDate': rateDate.trim(),
      },
    );
    return NbuRatesSnapshot.fromJson(payload);
  }

  Future<NbuRatesSnapshot> syncNbuRates() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.apiPath('/api/v1/admin/currencies/nbu-rates/sync'),
      );
      return NbuRatesSnapshot.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> _getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _config.apiPath(path),
        queryParameters: query,
      );
      final data = response.data;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _getObject(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.apiPath(path),
        queryParameters: query,
      );
      return response.data ?? const {};
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

final directoriesApiProvider = Provider<DirectoriesApi>((ref) {
  return DirectoriesApi(ref.watch(dioProvider), ref.watch(appConfigProvider));
});
