import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String _baseApiUrl = "http://www.ceri-amcp.com:8082/api/";

  /// Retourne la racine des API
  static String getBaseApiUrl() {
    return _baseApiUrl;
  }

  /// Retourne l'endpoint pour les patients
  static String getPatientsEndpoint() {
    return "${_baseApiUrl}patients/";
  }

  /// Retourne l'endpoint pour les groupes sanguins
  static String getBloodGroupsEndpoint() {
    return "${_baseApiUrl}groupesanguins/";
  }

  /// Retourne l'endpoint pour les électrophorèses
  static String getElectrophoresisEndpoint() {
    return "${_baseApiUrl}electrophoreses/";
  }

  /// Retourne l'endpoint pour les infos publiques
  ///
  static String getUserpublicinfosEndpoint() {
    return "${_baseApiUrl}userpublicinfos/";
  }
  // Ajoutez d'autres endpoints si nécessaire

  static String getUserEndpoint() {
    return "${_baseApiUrl}users/";
  }

  static String getmedicalfacilitiesEndpoint() {
    return "${_baseApiUrl}medicalfacilities/";
  }

  Future<String> sendPatientData(Map<String, dynamic> patientData) async {
    String apiUrl = getPatientsEndpoint();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(patientData),
      );

      if (response.statusCode == 201) {
        return "Données envoyées avec succès !";
      } else {
        return "Erreur : ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Erreur réseau : $e";
    }
  }

  Future<String> sendPublicDataRecord(Map<String, dynamic> record) async {
    String apiUrl = ApiHelper.getUserpublicinfosEndpoint();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(record),
      );

      if (response.statusCode == 201) {
        return "Données envoyées avec succès : ${record['info']}";
      } else {
        return "Erreur : ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Erreur réseau : $e";
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final url = Uri.parse(ApiHelper.getUserEndpoint());

    try {
      // Récupérer toutes les données
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Décoder la réponse
        final List<dynamic> users = jsonDecode(response.body);

        // Filtrer les utilisateurs par email et password
        final user = users.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
          orElse: () => null,
        );

        return user; // Retourne l'utilisateur correspondant ou null
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.body}'); // Gestion des erreurs
      }
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPatientData(int userId) async {
    final url = Uri.parse(getPatientsEndpoint()); // URL avec l'ID utilisateur

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Ajoutez un header Authorization si nécessaire pour un token
          // 'Authorization': 'Bearer <votre_token>'
        },
      );

      if (response.statusCode == 200) {
        // Les données patient existent

        // Décoder la réponse
        final List<dynamic> patient = jsonDecode(response.body);

        // Filtrer les utilisateurs par email et password
        final pat = patient.firstWhere(
          (p) => p['user'] == userId,
          orElse: () => null,
        );

        return pat;
      } else if (response.statusCode == 404) {
        // Aucun patient trouvé pour cet utilisateur
        return null;
      } else {
        throw Exception(
            'Erreur lors de la récupération des données patient : ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau : $e');
      return null; // Retourne null en cas d'erreur
    }
  }
}
