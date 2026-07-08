import '../../../core/network/api_client.dart';

/// API layer for submitting cognitive-game results.
///
/// Sends game-performance data only — no diagnosis or medical interpretation.
class GameResultsApi {
  const GameResultsApi(this._client);

  final ApiClient _client;

  /// POST /api/v1/games/{gameId}/results (authenticated, patient's own profile).
  Future<void> submitResult({
    required String token,
    required String gameId,
    required String patientProfileId,
    required int score,
    required int maxScore,
    required int durationSeconds,
    required bool completed,
    required Map<String, dynamic> metrics,
  }) async {
    await _client.postJson(
      '/games/$gameId/results',
      {
        'patient_profile_id': patientProfileId,
        'score': score,
        'max_score': maxScore,
        'duration_seconds': durationSeconds,
        'completed': completed,
        'metrics': metrics,
      },
      token: token,
    );
  }
}
