class Patient {
  int? id;
  int userId; // Référence à un utilisateur
  String? firstName; // Prénom
  String? lastName; // Nom
  String? address; // Adresse
  String? gender; // "Homme", "Femme"
  int? bloodGroupId; // Référence à GroupSanguin
  int? electrophoresisId; // Référence à Electrophoresis
  String? medicalHistory;
  String? allergies;
  String? emergencyContact;
  DateTime? birthDate;
  double? height; // Taille en mètres ou centimètres

  Patient({
    this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.address,
    this.gender,
    this.bloodGroupId,
    this.electrophoresisId,
    this.medicalHistory,
    this.allergies,
    this.emergencyContact,
    this.birthDate,
    this.height,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      address: json['address'],
      gender: json['gender'],
      bloodGroupId: json['blood_group_id'],
      electrophoresisId: json['electrophoresis_id'],
      medicalHistory: json['medical_history'],
      allergies: json['allergies'],
      emergencyContact: json['emergency_contact'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      height: json['height']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'gender': gender,
      'blood_group_id': bloodGroupId,
      'electrophoresis_id': electrophoresisId,
      'medical_history': medicalHistory,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'birth_date': birthDate?.toIso8601String(),
      'height': height,
    };
  }
}
