import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../home/data/patient_api.dart';
import '../data/game_results_api.dart';

enum SubmitStatus { idle, submitting, saved, error }

/// Submits a completed game's performance result to the backend.
///
/// Resolves the patient's own profile id via the existing patients endpoint,
/// then posts the result. Never throws to the UI and never logs tokens.
class GameResultController extends ChangeNotifier {
  GameResultController(this._resultsApi, this._patientApi, this._storage);

  final GameResultsApi _resultsApi;
  final PatientApi _patientApi;
  final SecureStorageService _storage;

  SubmitStatus _status = SubmitStatus.idle;
  SubmitStatus get status => _status;

  Future<void> submit({
    required String gameId,
    required int score,
    required int maxScore,
    required int durationSeconds,
    required bool completed,
    required Map<String, dynamic> metrics,
  }) async {
    _status = SubmitStatus.submitting;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = SubmitStatus.error;
        notifyListeners();
        return;
      }
      final profiles = await _patientApi.listPatients(token);
      if (profiles.isEmpty) {
        _status = SubmitStatus.error;
        notifyListeners();
        return;
      }
      await _resultsApi.submitResult(
        token: token,
        gameId: gameId,
        patientProfileId: profiles.first.id,
        score: score,
        maxScore: maxScore,
        durationSeconds: durationSeconds,
        completed: completed,
        metrics: metrics,
      );
      _status = SubmitStatus.saved;
    } catch (_) {
      _status = SubmitStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = SubmitStatus.idle;
    notifyListeners();
  }
}
