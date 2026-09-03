import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class AccessibilityService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/preferences.php';

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

    final data = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(response.bodyBytes)),
    );

    if (response.statusCode == 200 && data['success'] == true) {
      return Map<String, dynamic>.from(data['preferences']);
    }

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }
    throw Exception(data['message'] ?? 'تعذر تحميل الإعدادات');
  }

  static Future<void> save({
    required double fontScale,
    required double volume,
    required bool reduceMotion,
    required bool highContrast,
    required bool textToSpeech,
    required bool disableTimer,
    required bool largeButtons,
    required bool simpleMode,
    required bool hideExtraInfo,
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
        'font_scale': fontScale,
        'volume': volume,
        'reduce_motion': reduceMotion,
        'high_contrast': highContrast,
        'text_to_speech': textToSpeech,
        'sound_enabled': volume > 0,
        'disable_timer': disableTimer,
        'large_buttons': largeButtons,
        'simple_mode': simpleMode,
        'hide_extra_info': hideExtraInfo,
      }),
    ).timeout(const Duration(seconds: 25));

    final data = Map<String, dynamic>.from(
      jsonDecode(utf8.decode(response.bodyBytes)),
    );

    if (response.statusCode == 200 && data['success'] == true) return;

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }
    throw Exception(data['message'] ?? 'تعذر حفظ الإعدادات');
  }
}
