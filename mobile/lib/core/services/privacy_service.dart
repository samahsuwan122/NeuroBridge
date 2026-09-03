import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class PrivacyService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/privacy.php';

  static Future<Map<String, dynamic>> load() async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('يرجى تسجيل الدخول');
    }

    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 25));

    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['privacy'] ?? const {});
    }

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }
    throw Exception(data['message'] ?? 'تعذر تحميل إعدادات الخصوصية');
  }

  static Future<void> save({
    required bool shareProgress,
    required bool shareMood,
    required bool shareAppointments,
    required bool allowEncouragement,
  }) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('يرجى تسجيل الدخول');
    }

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'share_progress': shareProgress,
        'share_mood': shareMood,
        'share_appointments': shareAppointments,
        'allow_encouragement': allowEncouragement,
      }),
    ).timeout(const Duration(seconds: 25));

    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) return;

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }
    throw Exception(data['message'] ?? 'تعذر حفظ إعدادات الخصوصية');
  }

  static Map<String, dynamic> _decode(http.Response response) {
    try {
      return Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } catch (_) {
      throw Exception('استجابة غير صالحة من الخادم');
    }
  }
}
