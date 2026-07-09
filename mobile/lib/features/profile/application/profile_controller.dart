import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/patient_profile_detail.dart';
import '../data/profile_api.dart';

enum ProfileStatus { initial, loading, loaded, empty, error }

/// Loads the logged-in patient's own profile (read-only).
///
/// Never throws to the UI and never logs tokens. Missing token / backend error
/// maps to [ProfileStatus.error] with retry support; no profile maps to empty.
class ProfileController extends ChangeNotifier {
  ProfileController(this._api, this._storage);

  final ProfileApi _api;
  final SecureStorageService _storage;

  ProfileStatus _status = ProfileStatus.initial;
  PatientProfileDetail? _profile;

  ProfileStatus get status => _status;
  PatientProfileDetail? get profile => _profile;

  Future<void> load() async {
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = ProfileStatus.error;
        notifyListeners();
        return;
      }
      final profile = await _api.getMyProfile(token);
      if (profile == null) {
        _profile = null;
        _status = ProfileStatus.empty;
      } else {
        _profile = profile;
        _status = ProfileStatus.loaded;
      }
    } catch (_) {
      _status = ProfileStatus.error;
    }
    notifyListeners();
  }
}
