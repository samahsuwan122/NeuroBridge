import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class NotificationService {
  static const _url = 'https://toyoraljana.com/api_neuro/notifications.php';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    if (token == null) throw Exception('يرجى تسجيل الدخول مجددًا');
    return {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final response = await http.get(Uri.parse(_url), headers: await _headers()).timeout(const Duration(seconds: 25));
    final data = Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    if (response.statusCode != 200 || data['success'] != true) throw Exception(data['message'] ?? 'تعذر تحميل الإشعارات');
    return (data['notifications'] as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> markRead(int id) async {
    final response = await http.patch(Uri.parse(_url), headers: await _headers(), body: jsonEncode({'id': id, 'action': 'read'})).timeout(const Duration(seconds: 25));
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('تعذر تحديث الإشعار');
  }

  static Future<void> markAllRead() async {
    final response = await http.patch(Uri.parse(_url), headers: await _headers(), body: jsonEncode({'action': 'read_all'})).timeout(const Duration(seconds: 25));
    if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('تعذر تحديث الإشعارات');
  }
}
