import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/exercise.dart';
import 'session_service.dart';

class TodayPlanItem {
  final Exercise exercise;
  final bool completed;
  final int bestScore;

  const TodayPlanItem({
    required this.exercise,
    required this.completed,
    required this.bestScore,
  });

  factory TodayPlanItem.fromJson(Map<String, dynamic> json) {
    return TodayPlanItem(
      exercise: Exercise.fromJson(json),
      completed: json['completed'] == true ||
          json['completed'] == 1 ||
          json['completed']?.toString() == '1',
      bestScore: int.tryParse(json['best_score']?.toString() ?? '') ?? 0,
    );
  }
}

class TodayPlanData {
  final List<TodayPlanItem> items;
  final int completed;
  final int total;
  final int progress;
  final int remainingMinutes;

  const TodayPlanData({
    required this.items,
    required this.completed,
    required this.total,
    required this.progress,
    required this.remainingMinutes,
  });
}

class TodayPlanService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/today_plan.php';

  static Future<TodayPlanData> load() async {
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

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'تعذر تحميل خطة اليوم');
    }

    final rows = data['plan'] as List? ?? const [];
    final summary = Map<String, dynamic>.from(data['summary'] ?? const {});
    int number(String key) =>
        int.tryParse(summary[key]?.toString() ?? '') ?? 0;

    return TodayPlanData(
      items: rows
          .whereType<Map>()
          .map((row) => TodayPlanItem.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList(),
      completed: number('completed'),
      total: number('total'),
      progress: number('progress'),
      remainingMinutes: number('remaining_minutes'),
    );
  }
}
