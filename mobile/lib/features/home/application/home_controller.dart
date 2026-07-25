import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/patient_api.dart';
import '../data/patient_profile_summary.dart';

enum HomeStatus { initial, loading, loaded, empty, error }

/// Loads the patient profile summary for the home screen.
///
/// Never throws to the UI and never logs tokens. Missing/empty responses map to
/// [HomeStatus.empty]; failures map to [HomeStatus.error] with a retry option.
class HomeController extends ChangeNotifier {
  HomeController(this._patientApi, this._storage);

  final PatientApi _patientApi;
  final SecureStorageService _storage;

  HomeStatus _status = HomeStatus.initial;
  PatientProfileSummary? _summary;

  HomeStatus get status => _status;
  PatientProfileSummary? get summary => _summary;

  Future<void> load() async {
    _status = HomeStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = HomeStatus.error;
        notifyListeners();
        return;
      }
      final profiles = await _patientApi.listPatients(token);
      if (profiles.isEmpty) {
        _summary = null;
        _status = HomeStatus.empty;
      } else {
        _summary = profiles.first;
        _status = HomeStatus.loaded;
      }
    } catch (_) {
      _status = HomeStatus.error;
    }
    notifyListeners();
  }
}
