import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class FamilyMemoriesService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/family_memories.php';

  static Future<List<Map<String, dynamic>>> load(int patientId) async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('يجب تسجيل الدخول مجددًا');
    }
    final response = await http.get(
      Uri.parse(_url).replace(queryParameters: {'patient_id': '$patientId'}),
      headers: {
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 25));
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) throw Exception('استجابة الخادم غير صحيحة');
    final data = Map<String, dynamic>.from(decoded);
    if (response.statusCode < 200 || response.statusCode >= 300 || data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'تعذر تحميل الذكريات');
    }
    final rows = data['memories'] as List? ?? const [];
    return rows.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
