import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/exercise.dart';
import 'session_service.dart';

class ExerciseService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/exercises.php';

  static Future<List<Exercise>> loadExercises() async {
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

    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } catch (_) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    if (response.statusCode == 200 && data['success'] == true) {
      final rows = data['exercises'] as List? ?? const [];
      return rows
          .whereType<Map>()
          .map((row) => Exercise.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }
    throw Exception(data['message'] ?? 'تعذر تحميل التمارين');
  }
}
