/// A safe, display-only view of a Memory Album entry.
///
/// Supportive, family-engagement content only (a real-life memory: a title,
/// a short story, a person, a relationship, a place, a date, a category). It
/// has NO diagnostic fields and is never analyzed, scored, or interpreted.
///
/// `mediaType`/`mediaUrl` are placeholders — this phase does not display real
/// images or perform uploads.
class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.title,
    this.patientProfileId,
    this.uploadedByUserId,
    this.description,
    this.personName,
    this.relationship,
    this.placeName,
    this.memoryDate,
    this.category,
    this.mediaType,
    this.mediaUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? patientProfileId;
  final String? uploadedByUserId;
  final String? description;
  final String? personName;
  final String? relationship;
  final String? placeName;
  final DateTime? memoryDate;
  final String? category;
  final String? mediaType;
  final String? mediaUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MemoryEntry.fromJson(Map<String, dynamic> json) {
    return MemoryEntry(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      patientProfileId: json['patient_profile_id'] as String?,
      uploadedByUserId: json['uploaded_by_user_id'] as String?,
      description: json['description'] as String?,
      personName: json['person_name'] as String?,
      relationship: json['relationship'] as String?,
      placeName: json['place_name'] as String?,
      memoryDate: _parseDate(json['memory_date']),
      category: json['category'] as String?,
      mediaType: json['media_type'] as String?,
      mediaUrl: json['media_url'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  String? get memoryDateDisplay =>
      memoryDate == null ? null : _formatDate(memoryDate!);

  String? get createdAtDisplay =>
      createdAt == null ? null : _formatDate(createdAt!.toLocal());

  /// The best date to show on a list card (memory date, else created date).
  String? get listDateDisplay => memoryDateDisplay ?? createdAtDisplay;

  /// "Name · relationship" when both exist, else whichever is present.
  String? get personDisplay {
    final name = personName ?? '';
    final rel = relationship ?? '';
    if (name.isEmpty && rel.isEmpty) return null;
    if (name.isNotEmpty && rel.isNotEmpty) return '$name · $rel';
    return name.isNotEmpty ? name : rel;
  }

  /// True when this memory has an uploaded/linked image to display.
  bool get hasImage => mediaType == 'image' && (mediaUrl?.isNotEmpty ?? false);

  /// Full URL for the image, or null when there is none.
  ///
  /// - `http(s)://…` URLs are used as-is.
  /// - Relative paths (e.g. `/media/memory_uploads/x.png`) are combined with
  ///   [baseUrl] (the backend origin, no trailing slash) without double slashes.
  String? resolvedImageUrl(String baseUrl) {
    final url = mediaUrl;
    if (url == null || url.isEmpty) return null;
    final lower = url.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return url;
    final base =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }
}
