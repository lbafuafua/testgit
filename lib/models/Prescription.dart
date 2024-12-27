class Prescription {
  int? id;
  int userId;
  int doctorId;
  Map<String, dynamic> medication;
  String? instructions;
  String? issuedAt;

  Prescription({
    this.id,
    required this.userId,
    required this.doctorId,
    required this.medication,
    this.instructions,
    this.issuedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'],
        userId: json['user_id'],
        doctorId: json['doctor_id'],
        medication: json['medication'],
        instructions: json['instructions'],
        issuedAt: json['issued_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'doctor_id': doctorId,
        'medication': medication,
        'instructions': instructions,
        'issued_at': issuedAt,
      };
}
