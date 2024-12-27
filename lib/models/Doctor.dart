class Doctor {
  int? id;
  int userId; // Référence à un utilisateur
  String licenseNumber; // Numéro de licence médicale
  int experienceYears; // Années d'expérience
  String? bio; // Biographie
  String? clinicAddress; // Adresse de la clinique principale
  String? phoneNumber; // Numéro de téléphone professionnel
  String? email; // Email professionnel
  String? profilePicture; // Photo de profil
  double? consultationFee; // Frais de consultation
  double? rating; // Note moyenne
  int? numberOfReviews; // Nombre d'avis

  Doctor({
    this.id,
    required this.userId,
    required this.licenseNumber,
    required this.experienceYears,
    this.bio,
    this.clinicAddress,
    this.phoneNumber,
    this.email,
    this.profilePicture,
    this.consultationFee,
    this.rating,
    this.numberOfReviews,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      userId: json['user_id'],
      licenseNumber: json['license_number'],
      experienceYears: json['experience_years'],
      bio: json['bio'],
      clinicAddress: json['clinic_address'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      consultationFee: json['consultation_fee']?.toDouble(),
      rating: json['rating']?.toDouble(),
      numberOfReviews: json['number_of_reviews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'experience_years': experienceYears,
      'bio': bio,
      'clinic_address': clinicAddress,
      'phone_number': phoneNumber,
      'email': email,
      'profile_picture': profilePicture,
      'consultation_fee': consultationFee,
      'rating': rating,
      'number_of_reviews': numberOfReviews,
    };
  }
}
