import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ExerciseProgressService {
  static const _base = 'https://toyoraljana.com/api_neuro';
  static int? _activeExerciseId;

  static void beginExercise(int exerciseId) => _activeExerciseId = exerciseId;

  static Future<void> saveResult({
    required int score,
    required int totalQuestions,
    required int durationSeconds,
  }) async {
    final exerciseId = _activeExerciseId;
    if (exerciseId == null) return;
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) return;
    final response = await http.post(
      Uri.parse('$_base/save_attempt.php'),
      headers: {'Content-Type':'application/json; charset=UTF-8','Accept':'application/json','Authorization':'Bearer $token'},
      body: jsonEncode({'exercise_id':exerciseId,'score':score,'total_questions':totalQuestions,'duration_seconds':durationSeconds}),
    ).timeout(const Duration(seconds: 25));
    final data = Map<String,dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    if (response.statusCode != 200 || data['success'] != true) throw Exception(data['message'] ?? 'تعذر حفظ النتيجة');
    _activeExerciseId = null;
  }

  static Future<Map<String,dynamic>> loadDashboard() async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) throw Exception('يرجى تسجيل الدخول');
    final response = await http.get(Uri.parse('$_base/dashboard.php'), headers:{'Accept':'application/json','Authorization':'Bearer $token'}).timeout(const Duration(seconds:25));
    final data = Map<String,dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    if (response.statusCode == 200 && data['success'] == true) return Map<String,dynamic>.from(data['dashboard']);
    throw Exception(data['message'] ?? 'تعذر تحميل الإحصاءات');
  }
}
