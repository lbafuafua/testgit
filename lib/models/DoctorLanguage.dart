class DoctorLanguage {
  int doctorId; // Référence à Doctor
  int languageId; // Référence à Language

  DoctorLanguage({
    required this.doctorId,
    required this.languageId,
  });

  factory DoctorLanguage.fromJson(Map<String, dynamic> json) {
    return DoctorLanguage(
      doctorId: json['doctor_id'],
      languageId: json['language_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'language_id': languageId,
    };
  }
}
