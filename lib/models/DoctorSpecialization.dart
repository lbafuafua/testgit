class DoctorSpecialization {
  int doctorId; // Référence à Doctor
  int specializationId; // Référence à Specialization

  DoctorSpecialization({
    required this.doctorId,
    required this.specializationId,
  });

  factory DoctorSpecialization.fromJson(Map<String, dynamic> json) {
    return DoctorSpecialization(
      doctorId: json['doctor_id'],
      specializationId: json['specialization_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'specialization_id': specializationId,
    };
  }
}
