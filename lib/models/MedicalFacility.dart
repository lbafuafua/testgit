class MedicalFacility {
  int? id;
  String name;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  double? latitude;
  double? longitude;
  String? phoneNumber;
  String? email;
  String? photoUrl;
  String? createdAt;

  MedicalFacility({
    this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.photoUrl,
    this.createdAt,
  });

  factory MedicalFacility.fromJson(Map<String, dynamic> json) =>
      MedicalFacility(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        city: json['city'],
        state: json['state'],
        postalCode: json['postal_code'],
        country: json['country'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        phoneNumber: json['phone_number'],
        email: json['email'],
        photoUrl: json['photo_url'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'phone_number': phoneNumber,
        'email': email,
        'photo_url': photoUrl,
        'created_at': createdAt,
      };
}
