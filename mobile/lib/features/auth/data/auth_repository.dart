import 'package:dio/dio.dart';

import '../../../core/storage/secure_storage_service.dart';
import 'auth_api.dart';
import 'auth_user.dart';

/// Error raised by the auth repository. `code` is a stable string
/// ('invalid' or 'network') that the UI maps to a localized message.
class AuthException implements Exception {
  const AuthException(this.code);

  final String code;

  @override
  String toString() => 'AuthException($code)';
}

/// Coordinates the auth API and secure token storage.
class AuthRepository {
  const AuthRepository(this._api, this._storage);

  final AuthApi _api;
  final SecureStorageService _storage;

  /// Log in, store tokens securely, and return the authenticated user.
  Future<AuthUser> login(String emailOrPhone, String password) async {
    final Map<String, dynamic> data;
    try {
      data = await _api.login(emailOrPhone, password);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('invalid');
      }
      throw const AuthException('network');
    }

    final accessToken = data['access_token'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('invalid');
    }
    await _storage.saveAccessToken(accessToken);

    final refreshToken = data['refresh_token'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(refreshToken);
    }

    return AuthUser.fromResponse(data);
  }

  /// Return the current user if a stored token is still valid, else null.
  Future<AuthUser?> currentUser() async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    final data = await _api.me(token);
    return AuthUser.fromResponse(data);
  }

  Future<void> logout() => _storage.clear();
}
