import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../games/data/games_api.dart';
import '../data/game_result_summary.dart';
import '../data/progress_api.dart';

enum ProgressStatus { initial, loading, loaded, empty, error }

/// Loads the patient's saved game results and joins each with its game title.
///
/// Never throws to the UI and never logs tokens. Missing token / backend errors
/// map to [ProgressStatus.error] with retry support.
class ProgressController extends ChangeNotifier {
  ProgressController(this._progressApi, this._gamesApi, this._storage);

  final ProgressApi _progressApi;
  final GamesApi _gamesApi;
  final SecureStorageService _storage;

  ProgressStatus _status = ProgressStatus.initial;
  List<GameResultSummary> _results = const [];

  ProgressStatus get status => _status;
  List<GameResultSummary> get results => _results;

  Future<void> load() async {
    _status = ProgressStatus.loading;
    notifyListeners();
    try {
      final token = await _storage.readAccessToken();
      if (token == null || token.isEmpty) {
        _status = ProgressStatus.error;
        notifyListeners();
        return;
      }
      final rawResults = await _progressApi.listResults(token);
      final games = await _gamesApi.listGames(token);
      final nameById = {for (final game in games) game.id: game.name};

      _results = rawResults.map((raw) {
        final gameId = (raw['game_definition_id'] ?? '').toString();
        // Fallback to the id when the game name is unavailable.
        final title = nameById[gameId] ?? gameId;
        return GameResultSummary.fromResultJson(raw, gameTitle: title);
      }).toList();

      _status =
          _results.isEmpty ? ProgressStatus.empty : ProgressStatus.loaded;
    } catch (_) {
      _status = ProgressStatus.error;
    }
    notifyListeners();
  }
}
