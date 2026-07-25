import '../../../core/network/api_client.dart';

/// API layer for the patient's saved game results.
class ProgressApi {
  const ProgressApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/games/results — the caller's own results (role-scoped).
  ///
  /// Returns the raw result maps; the controller joins game titles separately.
  Future<List<Map<String, dynamic>>> listResults(String token) async {
    final res = await _client.getJson('/games/results', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['results'] as List?) ?? const <dynamic>[];
    return list
        .map((dynamic e) => (e as Map).cast<String, dynamic>())
        .toList();
  }
}
