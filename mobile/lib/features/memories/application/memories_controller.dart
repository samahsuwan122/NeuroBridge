import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/memories_api.dart';
import '../data/memory_entry.dart';

enum MemoriesStatus { initial, loading, loaded, empty, error }

/// Loads the caller's visible Memory Album entries (read-only in this phase).
///
/// Never throws to the UI and never logs tokens. A missing token or a backend
/// error maps to [MemoriesStatus.error] with retry support.
class MemoriesController extends ChangeNotifier {
  MemoriesController(this._api, this._storage);

  final MemoriesApi _api;
  final SecureStorageService _storage;

  MemoriesStatus _status = MemoriesStatus.initial;
  List<MemoryEntry> _memories = const [];

  MemoriesStatus get status => _status;
  List<MemoryEntry> get memories => _memories;

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
}
