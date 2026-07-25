/// A lightweight view of a patient profile for the home summary card.
///
/// Contains only non-diagnostic profile fields.
class PatientProfileSummary {
  const PatientProfileSummary({
    required this.id,
    this.patientName,
    this.medicalCenterId,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  final String id;
  final String? patientName;
  final String? medicalCenterId;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  factory PatientProfileSummary.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    return PatientProfileSummary(
      id: (json['id'] ?? '').toString(),
      patientName: user?['full_name'] as String?,
      medicalCenterId: json['medical_center_id']?.toString(),
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
    );
  }

  bool get hasEmergencyContact =>
      (emergencyContactName?.isNotEmpty ?? false) ||
      (emergencyContactPhone?.isNotEmpty ?? false);

  String get emergencyContactDisplay {
    final name = emergencyContactName ?? '';
    final phone = emergencyContactPhone ?? '';
    if (name.isNotEmpty && phone.isNotEmpty) return '$name · $phone';
    return name.isNotEmpty ? name : phone;
  }
}
