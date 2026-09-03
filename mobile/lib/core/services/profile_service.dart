import 'dart:convert';

import 'package:http/http.dart' as http;

import 'session_service.dart';

class ProfileService {
  static const String _baseUrl =
      'https://toyoraljana.com/api_neuro';

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await SessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('يرجى تسجيل الدخول');
    }

    final response = await http
        .get(
          Uri.parse('$_baseUrl/profile.php'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(
          const Duration(seconds: 25),
        );

    final Map<String, dynamic> data =
        jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (response.statusCode == 200 &&
        data['success'] == true) {
      final user = Map<String, dynamic>.from(
        data['user'],
      );

      await SessionService.updateUser(user);

      return user;
    }

    if (response.statusCode == 401) {
      await SessionService.clearSession();
    }

    throw Exception(
      data['message'] ?? 'تعذر تحميل الملف الشخصي',
    );
  }

  static Future<void> logout() async {
    final token = await SessionService.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        await http
            .post(
              Uri.parse('$_baseUrl/logout.php'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(
              const Duration(seconds: 15),
            );
      } catch (_) {
        // نحذف الجلسة المحلية حتى لو تعذر الاتصال.
      }
    }

    await SessionService.clearSession();
  }

  static Future<Map<String, dynamic>> updateProfile({
  required String fullName,
  required String phone,
  required String birthDate,
  required String preferredLanguage,
}) async {
  final token = await SessionService.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('يرجى تسجيل الدخول');
  }

  final response = await http
      .post(
        Uri.parse('$_baseUrl/update_profile.php'),
        headers: {
          'Content-Type':
              'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'birth_date': birthDate.trim(),
          'preferred_language':
              preferredLanguage,
        }),
      )
      .timeout(
        const Duration(seconds: 25),
      );

  final Map<String, dynamic> data =
      jsonDecode(
    utf8.decode(response.bodyBytes),
  );

  if (response.statusCode == 200 &&
      data['success'] == true) {
    final updatedUser =
        Map<String, dynamic>.from(
      data['user'],
    );

    await SessionService.updateUser(
      updatedUser,
    );

    return updatedUser;
  }

  if (response.statusCode == 401) {
    await SessionService.clearSession();
  }

  throw Exception(
    data['message'] ?? 'تعذر تحديث المعلومات',
  );
}
}