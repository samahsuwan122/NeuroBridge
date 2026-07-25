import '../../../core/network/api_client.dart';
import 'game_definition.dart';

/// API layer for cognitive games.
class GamesApi {
  const GamesApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/games — returns the active games visible to the caller.
  Future<List<GameDefinition>> listGames(String token) async {
    final res = await _client.getJson('/games', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['games'] as List?) ?? const <dynamic>[];
    return list
        .map((dynamic e) =>
            GameDefinition.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
