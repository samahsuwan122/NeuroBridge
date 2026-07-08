import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Thin wrapper around Dio for talking to the NeuroBridge backend.
///
/// Tokens are passed per-request and never logged.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: const {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<Response<dynamic>> postJson(
    String path,
    Map<String, dynamic> data, {
    String? token,
  }) {
    return _dio.post<dynamic>(
      '${AppConfig.apiPrefix}$path',
      data: data,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
  }

  Future<Response<dynamic>> getJson(String path, {String? token}) {
    return _dio.get<dynamic>(
      '${AppConfig.apiPrefix}$path',
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
  }
}
