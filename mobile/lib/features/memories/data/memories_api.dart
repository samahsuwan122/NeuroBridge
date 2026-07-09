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

  /// POST /api/v1/memories — create a memory for [patientProfileId].
  ///
  /// Supportive/family-engagement content only. `mediaUrl` is a text placeholder
  /// (no real file upload in this phase). Empty optional fields are omitted.
  Future<MemoryEntry> createMemory({
    required String token,
    required String patientProfileId,
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
    final payload = <String, dynamic>{
      'patient_profile_id': patientProfileId,
      'title': title.trim(),
    };
    void put(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) payload[key] = value.trim();
    }

    put('description', description);
    put('person_name', personName);
    put('relationship', relationship);
    put('place_name', placeName);
    put('memory_date', memoryDate);
    put('category', category);
    put('media_type', mediaType);
    put('media_url', mediaUrl);

    final res = await _client.postJson('/memories', payload, token: token);
    return MemoryEntry.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
