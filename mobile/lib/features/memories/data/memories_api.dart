import '../../../core/network/api_client.dart';
import 'memory_entry.dart';

/// API layer for the Memory Album (read-only in this phase).
///
/// Uses authenticated GETs only. Tokens are passed per-request, never logged.
class MemoriesApi {
  const MemoriesApi(this._client);

  final ApiClient _client;

  /// GET /api/v1/memories — the caller's visible memories (role-scoped).
  Future<List<MemoryEntry>> listMemories(String token) async {
    final res = await _client.getJson('/memories', token: token);
    final data = (res.data as Map).cast<String, dynamic>();
    final list = (data['memories'] as List?) ?? const <dynamic>[];
    return list
        .map((dynamic e) =>
            MemoryEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// GET /api/v1/memories/{id} — a single memory the caller may view.
  Future<MemoryEntry> getMemory(String token, String memoryId) async {
    final res = await _client.getJson('/memories/$memoryId', token: token);
    return MemoryEntry.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
