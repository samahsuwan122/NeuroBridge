import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../home/data/patient_api.dart';
import '../data/memories_api.dart';
import '../data/memory_entry.dart';

enum MemoriesStatus { initial, loading, loaded, empty, error }

enum MemoryCreateStatus { idle, submitting, success, error }

/// Loads the caller's visible Memory Album entries and creates new ones.
///
/// Never throws to the UI and never logs tokens. A missing token, a missing
/// patient profile, or a backend error maps to an `error` status with retry
/// support. Creating uses `POST /api/v1/memories` (no file upload).
class MemoriesController extends ChangeNotifier {
  MemoriesController(this._api, this._patientApi, this._storage);

  final MemoriesApi _api;
  final PatientApi _patientApi;
  final SecureStorageService _storage;

  MemoriesStatus _status = MemoriesStatus.initial;
  List<MemoryEntry> _memories = const [];
  MemoryCreateStatus _createStatus = MemoryCreateStatus.idle;

  MemoriesStatus get status => _status;
  List<MemoryEntry> get memories => _memories;
  MemoryCreateStatus get createStatus => _createStatus;

  Future<void> load() async {
    _status = MemoriesStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = MemoriesStatus.error;
        notifyListeners();
        return;
      }
      _memories = await _api.listMemories(token);
      _status =
          _memories.isEmpty ? MemoriesStatus.empty : MemoriesStatus.loaded;
    } catch (_) {
      _status = MemoriesStatus.error;
    }
    notifyListeners();
  }

  /// Creates a memory for the caller's first visible patient profile.
  ///
  /// Returns true on success (and refreshes the list). Returns false — with
  /// [createStatus] == error — on a missing token/profile or a backend error.
  Future<bool> createMemory({
    required String title,
    String? description,
    String? personName,
    String? relationship,
    String? placeName,
    String? memoryDate,
    String? category,
    String? mediaType,
    String? mediaUrl,
  }) async {
    _createStatus = MemoryCreateStatus.submitting;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _createStatus = MemoryCreateStatus.error;
        notifyListeners();
        return false;
      }
      final profiles = await _patientApi.listPatients(token);
      if (profiles.isEmpty) {
        _createStatus = MemoryCreateStatus.error;
        notifyListeners();
        return false;
      }
      await _api.createMemory(
        token: token,
        patientProfileId: profiles.first.id,
        title: title,
        description: description,
        personName: personName,
        relationship: relationship,
        placeName: placeName,
        memoryDate: memoryDate,
        category: category,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
      );
      _createStatus = MemoryCreateStatus.success;
      notifyListeners();
      // Refresh the list so the new memory is visible when returning.
      await load();
      return true;
    } catch (_) {
      _createStatus = MemoryCreateStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Reset the create status (e.g. when opening the Add Memory form).
  void resetCreate() {
    _createStatus = MemoryCreateStatus.idle;
    notifyListeners();
  }
}
