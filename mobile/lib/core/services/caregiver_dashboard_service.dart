import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class CaregiverDashboardException implements Exception {
  final String message;
  final int? statusCode;

  const CaregiverDashboardException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() {
    return message;
  }
}

class CaregiverDashboardService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/'
      'caregiver_dashboard.php';

  static Future<Map<String, dynamic>> load({
    int? patientId,
  }) async {
    final String? token =
        await SessionService.getToken();

    if (token == null || token.trim().isEmpty) {
      throw const CaregiverDashboardException(
        'يجب تسجيل الدخول مجددًا',
        statusCode: 401,
      );
    }

    final Uri uri = patientId == null
        ? Uri.parse(_url)
        : Uri.parse(_url).replace(
            queryParameters: {
              'patient_id': patientId.toString(),
            },
          );

    try {
      final http.Response response =
          await http
              .get(
                uri,
                headers: {
                  'Accept':
                      'application/json; charset=UTF-8',
                  'Authorization':
                      'Bearer ${token.trim()}',
                },
              )
              .timeout(
                const Duration(seconds: 25),
              );

      final String responseText =
          utf8.decode(response.bodyBytes);

      if (responseText.trim().isEmpty) {
        throw CaregiverDashboardException(
          'الخادم أعاد استجابة فارغة',
          statusCode: response.statusCode,
        );
      }

      final dynamic decoded =
          jsonDecode(responseText);

      if (decoded is! Map) {
        throw CaregiverDashboardException(
          'استجابة الخادم ليست بالشكل الصحيح',
          statusCode: response.statusCode,
        );
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(decoded);

      if (
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true) {
        return data;
      }

      if (response.statusCode == 401) {
        await SessionService.clearSession();
      }

      final String message =
          data['message']?.toString().trim() ?? '';

      throw CaregiverDashboardException(
        message.isEmpty
            ? 'تعذر تحميل بيانات العائلة'
            : message,
        statusCode: response.statusCode,
      );
    } on CaregiverDashboardException {
      rethrow;
    } on FormatException {
      throw const CaregiverDashboardException(
        'الخادم لم يُرجع بيانات JSON صحيحة',
      );
    } on http.ClientException {
      throw const CaregiverDashboardException(
        'تعذر الاتصال بالخادم',
      );
    } catch (_) {
      throw const CaregiverDashboardException(
        'تعذر الاتصال بالخادم، تحقق من الإنترنت',
      );
    }
  }
}