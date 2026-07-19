import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/activities_api.dart';
import '../data/assigned_activity.dart';

enum ActivitiesStatus { initial, loading, loaded, empty, error }

/// Loads the patient's care-team assigned activities and updates their status.
///
/// Never throws to the UI and never logs tokens.
class ActivitiesController extends ChangeNotifier {
  ActivitiesController(this._api, this._storage);

  final ActivitiesApi _api;
  final SecureStorageService _storage;

  ActivitiesStatus _status = ActivitiesStatus.initial;
  List<AssignedActivity> _items = const [];

  ActivitiesStatus get status => _status;
  List<AssignedActivity> get items => _items;

  /// The first not-yet-done activity, if any (shown as "today's activity").
  AssignedActivity? get nextPending {
    for (final a in _items) {
      if (a.isPending) return a;
    }
    return null;
  }

  Future<void> load() async {
    _status = ActivitiesStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = ActivitiesStatus.error;
        notifyListeners();
        return;
      }
      final items = await _api.listMine(token);
      _items = items;
      _status = items.isEmpty
          ? ActivitiesStatus.empty
          : ActivitiesStatus.loaded;
    } catch (_) {
      _status = ActivitiesStatus.error;
    }
    notifyListeners();
  }

  /// Mark an activity completed (or skipped). Returns true on success.
  Future<bool> setStatus(
    AssignedActivity activity, {
    String status = 'completed',
  }) async {
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) return false;
      final updated = await _api.setStatus(token, activity.id, status: status);
      _items = [
        for (final a in _items) if (a.id == updated.id) updated else a,
      ];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
