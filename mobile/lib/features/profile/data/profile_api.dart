import '../../../core/network/api_client.dart';
import 'patient_profile_detail.dart';

/// API layer for the logged-in patient's own profile.
class ProfileApi {
  const ProfileApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/patients — role-scoped; a patient sees only their own profile.
  /// Returns the first profile, or null if none exists.
  Future<PatientProfileDetail?> getMyProfile(String token) async {
    final res = await _client.getJson('/patients', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['patients'] as List?) ?? const <dynamic>[];
    if (list.isEmpty) return null;
    return PatientProfileDetail.fromJson(
      (list.first as Map).cast<String, dynamic>(),
    );
  }
}
