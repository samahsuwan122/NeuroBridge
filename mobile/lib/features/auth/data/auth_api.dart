import '../../../core/network/api_client.dart';

/// Thin API layer for the auth endpoints.
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    final res = await _client.postJson('/auth/login', {
      'email_or_phone': emailOrPhone,
      'password': password,
    });
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> me(String token) async {
    final res = await _client.getJson('/auth/me', token: token);
    return (res.data as Map).cast<String, dynamic>();
  }
}
