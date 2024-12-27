class User {
  int? id; // Suppression du 'final' pour permettre la modification
  String username;
  String email;
  String password;
  String? profilePicture;
  String createdAt;
  String updatedAt;
  String status;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'offline',
  });

  // Convertir un utilisateur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profile_picture': profilePicture,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
    };
  }

  // Créer un utilisateur à partir d'une Map (par exemple depuis SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      profilePicture: map['profile_picture'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      status: map['status'] as String,
    );
  }
}
