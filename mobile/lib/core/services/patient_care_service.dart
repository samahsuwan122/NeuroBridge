import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class PatientCareService {
  static const String _url = 'https://toyoraljana.com/api_neuro/patient_care.php';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    if (token == null || token.isEmpty) throw Exception('يرجى تسجيل الدخول مجددًا');
    return {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw Exception('استجابة الخادم غير صحيحة');
    }
    if (decoded is! Map) throw Exception('استجابة الخادم غير صحيحة');
    final data = Map<String, dynamic>.from(decoded);
    if (response.statusCode < 200 || response.statusCode >= 300 || data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'تعذر تنفيذ الطلب');
    }
    return data;
  }

  static List<Map<String, dynamic>> _rows(Map<String, dynamic> data, String key) =>
      (data[key] as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

  static Future<List<Map<String, dynamic>>> providers({String? role}) async {
    final query = role == null ? 'action=providers' : 'action=providers&role=$role';
    final response = await http.get(Uri.parse('$_url?$query'), headers: await _headers()).timeout(const Duration(seconds: 25));
    return _rows(_decode(response), 'providers');
  }

  static Future<List<Map<String, dynamic>>> appointments() async {
    final response = await http.get(Uri.parse('$_url?action=appointments'), headers: await _headers()).timeout(const Duration(seconds: 25));
    return _rows(_decode(response), 'appointments');
  }

  static Future<Map<String, dynamic>> createAppointment({
    required int providerId, required DateTime date, required TimeOfDay time,
    required String mode, required String reason,
  }) async {
    final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final clock = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final response = await http.post(Uri.parse(_url), headers: await _headers(), body: jsonEncode({
      'action': 'appointment', 'provider_id': providerId, 'preferred_date': day,
      'preferred_time': clock, 'appointment_mode': mode, 'reason': reason,
    })).timeout(const Duration(seconds: 35));
    return _decode(response);
  }

  static Future<void> cancelAppointment(int appointmentId) async {
    final response = await http.patch(Uri.parse(_url), headers: await _headers(), body: jsonEncode({
      'action': 'cancel', 'appointment_id': appointmentId,
    })).timeout(const Duration(seconds: 25));
    _decode(response);
  }

  static Future<List<Map<String, dynamic>>> threads() async {
    final response = await http.get(Uri.parse('$_url?action=threads'), headers: await _headers()).timeout(const Duration(seconds: 25));
    return _rows(_decode(response), 'threads');
  }

  static Future<Map<String, dynamic>> thread(int id) async {
    final response = await http.get(Uri.parse('$_url?action=thread&thread_id=$id'), headers: await _headers()).timeout(const Duration(seconds: 25));
    return _decode(response);
  }

  static Future<int> sendMessage(int providerId, String message) async {
    final response = await http.post(Uri.parse(_url), headers: await _headers(), body: jsonEncode({
      'action': 'message', 'provider_id': providerId, 'message': message,
    })).timeout(const Duration(seconds: 25));
    return int.tryParse(_decode(response)['id']?.toString() ?? '') ?? 0;
  }

  static Future<void> reply(int threadId, String message) async {
    final response = await http.post(Uri.parse(_url), headers: await _headers(), body: jsonEncode({
      'action': 'reply', 'thread_id': threadId, 'message': message,
    })).timeout(const Duration(seconds: 25));
    _decode(response);
  }
}

