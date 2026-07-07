import '../../../core/network/api_client.dart';
import 'patient_profile_summary.dart';

/// API layer for patient profile data used by the home screen.
class PatientApi {
  const PatientApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/patients — returns the patient profiles visible to the caller.
  ///
  /// The backend scopes results by role (a patient sees only their own profile;
  /// a family member sees only linked profiles).
  Future<List<PatientProfileSummary>> listPatients(String token) async {
    final res = await _client.getJson('/patients', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['patients'] as List?) ?? const <dynamic>[];
    return list
        .map((dynamic e) =>
            PatientProfileSummary.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
