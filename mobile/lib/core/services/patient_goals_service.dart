import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class PatientGoal {
  final int id;
  final String title;
  final String description;
  final String targetType;
  final double targetValue;
  final double currentValue;
  final int progressPercent;
  final String status;
  final String? dueDate;

  const PatientGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetValue,
    required this.currentValue,
    required this.progressPercent,
    required this.status,
    required this.dueDate,
  });

  factory PatientGoal.fromJson(Map<String, dynamic> json) {
    return PatientGoal(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? 'هدف',
      description: json['description']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? '',
      targetValue: _toDouble(json['target_value']),
      currentValue: _toDouble(json['current_value']),
      progressPercent: _toInt(json['progress_percent']),
      status: json['status']?.toString() ?? 'active',
      dueDate: json['due_date']?.toString(),
    );
  }

  String get statusTitle => switch (status) {
        'completed' => 'مكتمل',
        'paused' => 'متوقف مؤقتًا',
        _ => 'نشط',
      };

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PatientGoalsService {
  static const String _url =
      'https://toyoraljana.com/api_neuro/patient_goals.php';

  static Future<List<PatientGoal>> loadGoals() async {
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
      final rows = data['goals'] as List? ?? const [];
      return rows
          .whereType<Map>()
          .map((row) => PatientGoal.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList();
    }

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }

    throw Exception(data['message'] ?? 'تعذر تحميل الأهداف');
  }
}
