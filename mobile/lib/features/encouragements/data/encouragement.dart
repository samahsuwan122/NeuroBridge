/// A single supportive family encouragement message received by the patient.
///
/// Family support content only — never medical advice, diagnosis, or
/// assessment.
class Encouragement {
  const Encouragement({
    required this.id,
    required this.message,
    this.createdAt,
  });

  final String id;
  final String message;
  final String? createdAt;

  factory Encouragement.fromJson(Map<String, dynamic> json) => Encouragement(
        id: (json['id'] ?? '').toString(),
        message: (json['message'] ?? '').toString(),
        createdAt: json['created_at']?.toString(),
      );
}
