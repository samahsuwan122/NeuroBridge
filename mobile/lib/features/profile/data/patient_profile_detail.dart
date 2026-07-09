/// A safe, read-only view of the patient's own profile.
///
/// Basic profile fields only — no diagnosis, notes, medical_center_id, or any
/// medical interpretation.
class PatientProfileDetail {
  const PatientProfileDetail({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.createdAt,
  });

  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime? createdAt;

  factory PatientProfileDetail.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    return PatientProfileDetail(
      id: (json['id'] ?? '').toString(),
      fullName: user?['full_name'] as String?,
      email: user?['email'] as String?,
      phone: user?['phone'] as String?,
      dateOfBirth: _parseDate(json['date_of_birth']),
      gender: json['gender'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  String? get dateOfBirthDisplay =>
      dateOfBirth == null ? null : _formatDate(dateOfBirth!);

  String? get memberSinceDisplay =>
      createdAt == null ? null : _formatDate(createdAt!.toLocal());

  String? get emergencyContactDisplay {
    final name = emergencyContactName ?? '';
    final phone = emergencyContactPhone ?? '';
    if (name.isEmpty && phone.isEmpty) return null;
    if (name.isNotEmpty && phone.isNotEmpty) return '$name · $phone';
    return name.isNotEmpty ? name : phone;
  }
}
