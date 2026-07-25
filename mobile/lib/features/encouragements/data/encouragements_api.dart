import '../../../core/network/api_client.dart';
import 'encouragement.dart';

/// API layer for family encouragement messages received by the patient.
class EncouragementsApi {
  const EncouragementsApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/encouragements — supportive messages visible to the caller.
  ///
  /// The backend scopes results by role (a patient sees only messages received
  /// on their own profile; a family member sees their linked patient's).
  Future<List<Encouragement>> listEncouragements(String token) async {
    final res = await _client.getJson('/encouragements', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['encouragements'] as List?) ?? const <dynamic>[];
    return list
        .map((dynamic e) =>
            Encouragement.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
