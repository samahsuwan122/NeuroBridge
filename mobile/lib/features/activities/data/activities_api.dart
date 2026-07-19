import '../../../core/network/api_client.dart';
import 'assigned_activity.dart';

/// API layer for care-team assigned activities.
class ActivitiesApi {
  const ActivitiesApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/activities/my — activities assigned to the current patient.
  Future<List<AssignedActivity>> listMine(String token) async {
    final res = await _client.getJson('/activities/my', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['activities'] as List?) ?? const <dynamic>[];
    return list
        .map((dynamic e) =>
            AssignedActivity.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// PATCH /api/v1/activities/{id}/complete — mark completed (or skipped).
  Future<AssignedActivity> setStatus(
    String token,
    String activityId, {
    String status = 'completed',
  }) async {
    final res = await _client.patchJson(
      '/activities/$activityId/complete',
      {'status': status},
      token: token,
    );
    return AssignedActivity.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
