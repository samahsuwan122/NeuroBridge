import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../data/game_definition.dart';
import '../data/games_api.dart';

enum GamesStatus { initial, loading, loaded, empty, error }

/// Loads the list of active games for the Games screen.
///
/// Never throws to the UI and never logs tokens. Empty responses map to
/// [GamesStatus.empty]; failures map to [GamesStatus.error] with a retry option.
class GamesController extends ChangeNotifier {
  GamesController(this._api, this._storage);

  final GamesApi _api;
  final SecureStorageService _storage;

  GamesStatus _status = GamesStatus.initial;
  List<GameDefinition> _games = const [];

  GamesStatus get status => _status;
  List<GameDefinition> get games => _games;

  Future<void> load() async {
    _status = GamesStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = GamesStatus.error;
        notifyListeners();
        return;
      }
      final games = await _api.listGames(token);
      _games = games;
      _status = games.isEmpty ? GamesStatus.empty : GamesStatus.loaded;
    } catch (_) {
      _status = GamesStatus.error;
    }
    notifyListeners();
  }
}
