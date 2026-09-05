import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class GeminiAssistantService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/gemini_chat.php';

  static Future<String> send({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('انتهت جلسة الدخول');
    }

    final response = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Accept': 'application/json; charset=UTF-8',
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'message': message,
            'history': history.takeLast(10).toList(),
          }),
        )
        .timeout(const Duration(seconds: 45));

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) throw Exception('استجابة الخادم غير صحيحة');
    final data = Map<String, dynamic>.from(decoded);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'تعذر الاتصال بالمساعد');
    }
    final answer = data['answer']?.toString().trim() ?? '';
    if (answer.isEmpty) throw Exception('لم يرجع المساعد إجابة');
    return answer;
  }
}

extension<T> on List<T> {
  Iterable<T> takeLast(int count) => skip(length > count ? length - count : 0);
}
