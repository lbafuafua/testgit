class Appointment {
  int? id;
  int userId;
  int doctorId;
  int facilityId;
  String appointmentDate;
  String status;

  Appointment({
    this.id,
    required this.userId,
    required this.doctorId,
    required this.facilityId,
    required this.appointmentDate,
    this.status = 'pending',
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'],
        userId: json['user_id'],
        doctorId: json['doctor_id'],
        facilityId: json['facility_id'],
        appointmentDate: json['appointment_date'],
        status: json['status'] ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'doctor_id': doctorId,
        'facility_id': facilityId,
        'appointment_date': appointmentDate,
        'status': status,
      };
}
