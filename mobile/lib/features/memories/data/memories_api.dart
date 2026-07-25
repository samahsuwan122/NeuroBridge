import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'memory_entry.dart';
import 'memory_image.dart';

/// API layer for the Memory Album.
///
/// Tokens are passed per-request and never logged; local file paths are never
/// logged (images are sent as in-memory bytes).
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

  /// POST /api/v1/memories/{memoryId}/media — upload a real image.
  ///
  /// Sends the picked image as multipart field `file` (jpeg/png/webp). Returns
  /// the updated memory (media_type="image", media_url=/media/...). Callers
  /// should validate type/size first; the backend also enforces both.
  Future<MemoryEntry> uploadMemoryImage({
    required String token,
    required String memoryId,
    required PickedMemoryImage image,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        image.bytes,
        filename: image.filename,
        contentType: _mediaTypeFor(image),
      ),
    });
    final res = await _client.postMultipart(
      '/memories/$memoryId/media',
      form,
      token: token,
    );
    return MemoryEntry.fromJson((res.data as Map).cast<String, dynamic>());
  }

  DioMediaType _mediaTypeFor(PickedMemoryImage image) {
    final mt = image.mimeType?.toLowerCase();
    final ext = image.extension;
    if (mt == 'image/png' || ext == 'png') return DioMediaType('image', 'png');
    if (mt == 'image/webp' || ext == 'webp') {
      return DioMediaType('image', 'webp');
    }
    // Default to JPEG for jpg/jpeg (already validated as an allowed type).
    return DioMediaType('image', 'jpeg');
  }
}
