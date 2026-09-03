import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey =
      'auth_token';

  static const String _userKey =
      'auth_user';

  static const String _rememberKey =
      'remember_me';

  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
    required bool rememberMe,
  }) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    /*
     * نوحّد شكل الدور قبل حفظ المستخدم.
     */
    final Map<String, dynamic> normalizedUser =
        Map<String, dynamic>.from(user);

    normalizedUser['role'] =
        normalizeRole(normalizedUser['role']);

    await preferences.setString(
      _tokenKey,
      token,
    );

    await preferences.setString(
      _userKey,
      jsonEncode(normalizedUser),
    );

    await preferences.setBool(
      _rememberKey,
      rememberMe,
    );
  }

  static Future<String?> getToken() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? token =
        preferences.getString(_tokenKey);

    if (token == null ||
        token.trim().isEmpty) {
      return null;
    }

    return token.trim();
  }

  static Future<Map<String, dynamic>?>
      getUser() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? savedUser =
        preferences.getString(_userKey);

    if (savedUser == null ||
        savedUser.trim().isEmpty) {
      return null;
    }

    try {
      final dynamic decodedUser =
          jsonDecode(savedUser);

      if (decodedUser is! Map) {
        return null;
      }

      final Map<String, dynamic> user =
          Map<String, dynamic>.from(
        decodedUser,
      );

      user['role'] =
          normalizeRole(user['role']);

      return user;
    } catch (_) {
      /*
       * إذا كانت بيانات الجلسة تالفة نحذفها
       * حتى لا تظهر صفحة فارغة.
       */
      await clearSession();
      return null;
    }
  }

  static Future<bool> shouldRemember() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    return preferences.getBool(
          _rememberKey,
        ) ??
        false;
  }

  static Future<void> updateUser(
    Map<String, dynamic> user,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final Map<String, dynamic> normalizedUser =
        Map<String, dynamic>.from(user);

    normalizedUser['role'] =
        normalizeRole(normalizedUser['role']);

    await preferences.setString(
      _userKey,
      jsonEncode(normalizedUser),
    );
  }

  static Future<void> clearSession() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await Future.wait([
      preferences.remove(_tokenKey),
      preferences.remove(_userKey),
      preferences.remove(_rememberKey),
    ]);
  }

  /*
   * توحيد أسماء الأدوار القادمة من PHP.
   */
  static String normalizeRole(
    dynamic value,
  ) {
    final String role = (value ?? '')
        .toString()
        .trim()
        .toLowerCase();

    switch (role) {
      case 'patient':
      case 'مريض':
        return 'patient';

      case 'caregiver':
      case 'family':
      case 'family_member':
      case 'care_giver':
      case 'عائلة':
      case 'فرد عائلة':
        return 'caregiver';

      default:
        return role;
    }
  }

  static bool isPatient(
    Map<String, dynamic>? user,
  ) {
    if (user == null) {
      return false;
    }

    return normalizeRole(user['role']) ==
        'patient';
  }

  static bool isFamily(
    Map<String, dynamic>? user,
  ) {
    if (user == null) {
      return false;
    }

    return normalizeRole(user['role']) ==
        'caregiver';
  }

  static Future<bool> hasValidSession() async {
    final String? token = await getToken();
    final Map<String, dynamic>? user =
        await getUser();

    if (token == null || user == null) {
      return false;
    }

    final String role =
        normalizeRole(user['role']);

    return role == 'patient' ||
        role == 'caregiver';
  }
}