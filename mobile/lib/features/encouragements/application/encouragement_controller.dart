import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/encouragement.dart';
import '../data/encouragements_api.dart';

enum EncouragementStatus { initial, loading, loaded, empty, error }

/// Loads the family encouragement messages received by the patient.
///
/// Never throws to the UI and never logs tokens. An empty list maps to
/// [EncouragementStatus.empty]; failures map to [EncouragementStatus.error].
class EncouragementController extends ChangeNotifier {
  EncouragementController(this._api, this._storage);

  final EncouragementsApi _api;
  final SecureStorageService _storage;

  EncouragementStatus _status = EncouragementStatus.initial;
  List<Encouragement> _items = const <Encouragement>[];

  EncouragementStatus get status => _status;
  List<Encouragement> get items => _items;

  Future<void> load() async {
    _status = EncouragementStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = EncouragementStatus.error;
        notifyListeners();
        return;
      }
      final list = await _api.listEncouragements(token);
      _items = list;
      _status =
          list.isEmpty ? EncouragementStatus.empty : EncouragementStatus.loaded;
    } catch (_) {
      _status = EncouragementStatus.error;
    }
    notifyListeners();
  }
}
