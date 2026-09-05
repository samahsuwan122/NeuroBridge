import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class FamilyAppointmentService {
  static const _url = 'https://toyoraljana.com/api_neuro/family_appointments.php';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    if (token == null) throw Exception('يجب تسجيل الدخول مجددًا');
    return {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is! Map) throw Exception('استجابة الخادم غير صحيحة');
    final result = Map<String, dynamic>.from(data);
    if (response.statusCode < 200 || response.statusCode >= 300 || result['success'] != true) {
      throw Exception(result['message']?.toString() ?? 'تعذر تنفيذ الطلب');
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> providers() async {
    final response = await http.get(Uri.parse('$_url?action=providers'), headers: await _headers()).timeout(const Duration(seconds: 25));
    final rows = _decode(response)['providers'] as List? ?? const [];
    return rows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> appointments(int patientId) async {
    final response = await http.get(Uri.parse('$_url?patient_id=$patientId'), headers: await _headers()).timeout(const Duration(seconds: 25));
    final rows = _decode(response)['appointments'] as List? ?? const [];
    return rows.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> create({required int patientId, required int providerId, required DateTime date, required TimeOfDay time, required String mode, required String reason}) async {
    final day = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final clock = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final response = await http.post(Uri.parse(_url), headers: await _headers(), body: jsonEncode({'patient_id': patientId, 'provider_id': providerId, 'preferred_date': day, 'preferred_time': clock, 'appointment_mode': mode, 'reason': reason})).timeout(const Duration(seconds: 25));
    _decode(response);
  }

  static Future<void> cancel({required int patientId, required int appointmentId}) async {
    final response = await http.patch(Uri.parse(_url), headers: await _headers(), body: jsonEncode({'patient_id': patientId, 'appointment_id': appointmentId, 'action': 'cancel'})).timeout(const Duration(seconds: 25));
    _decode(response);
  }
}
