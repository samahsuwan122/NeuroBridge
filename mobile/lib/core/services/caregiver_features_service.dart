import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'session_service.dart';

class CaregiverFeaturesService {
  static const _url = 'https://toyoraljana.com/api_neuro/caregiver_features.php';
  static const _dashboardUrl =
      'https://toyoraljana.com/api_neuro/caregiver_dashboard.php';
  static const _patientKey = 'caregiver_selected_patient_id';

  static Future<Map<String, String>> _headers() async {
    final token = await SessionService.getToken();
    if (token == null) throw Exception('يرجى تسجيل الدخول مجددًا');
    return {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $token'};
  }

  static Future<void> selectPatient(int id) async =>
      (await SharedPreferences.getInstance()).setInt(_patientKey, id);
  static Future<int?> selectedPatientId() async =>
      (await SharedPreferences.getInstance()).getInt(_patientKey);

  static Future<int?> _resolvePatientId() async {
    final saved = await selectedPatientId();
    if (saved != null && saved > 0) return saved;

    final response = await http
        .get(Uri.parse(_dashboardUrl), headers: await _headers())
        .timeout(const Duration(seconds: 25));
    final dashboard = _decode(response);

    final patient = dashboard['patient'];
    if (patient is Map && patient['id'] != null) {
      final id = int.tryParse(patient['id'].toString());
      if (id != null && id > 0) {
        await selectPatient(id);
        return id;
      }
    }

    final linkedPatients = dashboard['linked_patients'];
    if (linkedPatients is List && linkedPatients.isNotEmpty) {
      final first = linkedPatients.first;
      if (first is Map && first['id'] != null) {
        final id = int.tryParse(first['id'].toString());
        if (id != null && id > 0) {
          await selectPatient(id);
          return id;
        }
      }
    }

    return null;
  }

  static Future<Map<String, dynamic>> get(String action, {int? patientId}) async {
    final id = patientId ??
        (action == 'profile' ? await selectedPatientId() : await _resolvePatientId());
    final uri = Uri.parse(_url).replace(queryParameters: {
      'action': action,
      if (id != null) 'patient_id': '$id',
    });
    return _decode(await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 25)));
  }

  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> body) async {
    final id = body['patient_id'] ??
        (action == 'link' ? await selectedPatientId() : await _resolvePatientId());
    return _decode(await http.post(Uri.parse(_url), headers: await _headers(), body: jsonEncode({
      'action': action,
      if (id != null) 'patient_id': id,
      ...body,
    })).timeout(const Duration(seconds: 25)));
  }

  static Future<Map<String, dynamic>> addMemory({
    required String title,
    String? date,
    String? location,
    String? people,
    String? description,
    String visibility = 'family',
    Uint8List? image,
    String? imageName,
  }) => post('add_memory', {
    'title': title, 'memory_date': date, 'location': location, 'people': people,
    'description': description, 'visibility': visibility,
    if (image != null) 'image_base64': base64Encode(image),
    if (imageName != null) 'image_name': imageName,
  });

  static Future<Map<String, dynamic>> sendEncouragement({
    required String message,
    Uint8List? media,
    String? mediaName,
    String? mediaType,
    int? mediaDuration,
  }) => post('encouragement', {
    'message': message,
    if (media != null) 'media_base64': base64Encode(media),
    if (mediaName != null) 'media_name': mediaName,
    if (mediaType != null) 'media_type': mediaType,
    if (mediaDuration != null) 'media_duration': mediaDuration,
  });

  static Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try { decoded = jsonDecode(utf8.decode(response.bodyBytes)); } catch (_) { throw Exception('الخادم لم يرجع JSON صحيحًا'); }
    if (decoded is! Map) throw Exception('استجابة الخادم غير صحيحة');
    final data = Map<String, dynamic>.from(decoded);
    if (response.statusCode < 200 || response.statusCode >= 300 || data['success'] != true) {
      throw Exception(data['message']?.toString() ?? 'تعذر تنفيذ الطلب');
    }
    return data;
  }
}