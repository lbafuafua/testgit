import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'HomePage.dart';
import 'userprofilePage.dart';

class UserInfosPage extends StatefulWidget {
  final String userEmail;
  final String userNom;
  final String userPhoto;
  final String createdAt;
  final int userId; // ID de l'utilisateur

  const UserInfosPage(
      {Key? key,
      required this.userEmail,
      required this.userNom,
      required this.userPhoto,
      required this.createdAt,
      required this.userId})
      : super(key: key);

  @override
  _UserInfosPageState createState() => _UserInfosPageState();
}

class _UserInfosPageState extends State<UserInfosPage> {
  Map<String, dynamic> userInfo = {};
  Map<String, bool> publicInfo = {};
  Map<int, String> bloodGroupLabels = {};
  Map<int, String> electrophoresisLabels = {};
  bool isLoading = true;
  bool isReadOnly = true; // Mode lecture par défaut

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchUserInfo(),
      _fetchBloodGroups(),
      _fetchElectrophoresisOptions(),
    ]);
    await _fetchPublicInfo(); // Doit être appelé après le chargement des labels
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchUserInfo() async {
    final String apiUrl = "http://www.ceri-amcp.com:8082/api/patients/";
    try {
      final response = await http.get(Uri.parse("$apiUrl${widget.userId}/"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userInfo = data;
        });
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors du chargement des informations utilisateur : $e");
    }
  }

  Future<void> _fetchBloodGroups() async {
    final String apiUrl = "http://www.ceri-amcp.com:8082/api/groupesanguins/";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bloodGroupLabels = {for (var item in data) item['id']: item['name']};
        });
      } else {
        throw Exception("Erreur lors du chargement des groupes sanguins");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  Future<void> _fetchElectrophoresisOptions() async {
    final String apiUrl = "http://www.ceri-amcp.com:8082/api/electrophoreses/";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          electrophoresisLabels = {
            for (var item in data) item['id']: item['type']
          };
        });
      } else {
        throw Exception("Erreur lors du chargement des électrophorèses");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  Future<void> _fetchPublicInfo() async {
    final String apiUrl = "http://www.ceri-amcp.com:8082/api/userpublicinfos/";
    try {
      final response =
          await http.get(Uri.parse("$apiUrl?user=${widget.userId}"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          for (var info in data) {
            // Vérification pour le groupe sanguin
            if (userInfo['blood_group'] != null &&
                bloodGroupLabels[userInfo['blood_group']] == info['info']) {
              publicInfo["blood_group"] = true;
            }

            // Vérification pour l'électrophorèse
            if (userInfo['electrophoresis'] != null &&
                electrophoresisLabels[userInfo['electrophoresis']] ==
                    info['info']) {
              publicInfo["electrophoresis"] = true;
            }

            // Vérification pour les autres champs
            userInfo.forEach((key, value) {
              if (value != null && value.toString() == info['info']) {
                publicInfo[key] = true;
              }
            });
          }
        });
      } else {
        throw Exception("Erreur lors du chargement des informations publiques");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  Widget _buildRecapRow(String label, String value, String key, bool isPublic,
      Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "$label : $value",
            // style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Checkbox(
          value: isPublic,
          onChanged: null,
        ),
      ],
    );
  }

  void _toggleEditMode() {
    setState(() {
      isReadOnly = !isReadOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userEmail: widget.userEmail,
                  userNom: widget.userNom,
                  userPhoto: widget.userPhoto,
                  userId: widget.userId,
                  userCreateat: widget.createdAt,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              // Notifications logic
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF283593), Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      "Les infos cochées sont visibles du public ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(
                      color: Color.fromARGB(255, 103, 81, 80), thickness: 1),
                  const Text(
                    "Informations personnelles",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildRecapRow(
                          "Prénom",
                          userInfo['first_name'] ?? 'Non renseigné',
                          "first_name",
                          publicInfo["first_name"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["first_name"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Nom",
                          userInfo['last_name'] ?? 'Non renseigné',
                          "last_name",
                          publicInfo["last_name"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["last_name"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Sexe",
                          userInfo['gender'] ?? 'Non renseigné',
                          "gender",
                          publicInfo["gender"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["gender"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Téléphone",
                          userInfo['emergency_contact'] ?? 'Non renseigné',
                          "emergency_contact",
                          publicInfo["emergency_contact"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["emergency_contact"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Adresse",
                          userInfo['address'] ?? 'Non renseigné',
                          "address",
                          publicInfo["address"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["address"] = value ?? false;
                            });
                          },
                        ),
                        const Divider(
                            color: Color.fromARGB(255, 132, 115, 114),
                            thickness: 1),
                        const Text(
                          "Informations médicales",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                        _buildRecapRow(
                          "Date de naissance",
                          userInfo['birth_date'] ?? 'Non renseigné',
                          "birth_date",
                          publicInfo["birth_date"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["birth_date"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Taille",
                          userInfo['height']?.toString() ?? 'Non renseigné',
                          "height",
                          publicInfo["height"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["height"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Groupe sanguin",
                          bloodGroupLabels[userInfo['blood_group']] ??
                              'Non renseigné',
                          "blood_group",
                          publicInfo["blood_group"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["blood_group"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Électrophorèse",
                          electrophoresisLabels[userInfo['electrophoresis']] ??
                              'Non renseigné',
                          "electrophoresis",
                          publicInfo["electrophoresis"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["electrophoresis"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Allergies",
                          userInfo['allergies'] ?? 'Non renseigné',
                          "allergies",
                          publicInfo["allergies"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["allergies"] = value ?? false;
                            });
                          },
                        ),
                        _buildRecapRow(
                          "Pathologies chroniques",
                          userInfo['medical_history'] ?? 'Non renseigné',
                          "medical_history",
                          publicInfo["medical_history"] ?? false,
                          (value) {
                            setState(() {
                              publicInfo["medical_history"] = value ?? false;
                            });
                          },
                        ),
                        const Divider(
                            color: Color.fromARGB(255, 103, 81, 80),
                            thickness: 1),

                        // ElevatedButton(
                        //   onPressed: _toggleEditMode,
                        //   child: Text(isReadOnly ? "Modifier" : "Sauvegarder"),
                        // ),
                        ElevatedButton(
                          onPressed: () => _navigateToEditProfile(context),
                          child: const Text("Modifier"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Créer une liste avec toutes les données affichées
    final List<Map<String, dynamic>> userData = [
      {
        "label": "Prénom",
        "value": userInfo['first_name'] ?? 'Non renseigné',
        "isPublic": publicInfo["first_name"] ?? false,
      },
      {
        "label": "Nom",
        "value": userInfo['last_name'] ?? 'Non renseigné',
        "isPublic": publicInfo["last_name"] ?? false,
      },
      {
        "label": "Sexe",
        "value": userInfo['gender'] ?? 'Non renseigné',
        "isPublic": publicInfo["gender"] ?? false,
      },
      {
        "label": "Téléphone",
        "value": userInfo['emergency_contact'] ?? 'Non renseigné',
        "isPublic": publicInfo["emergency_contact"] ?? false,
      },
      {
        "label": "Adresse",
        "value": userInfo['address'] ?? 'Non renseigné',
        "isPublic": publicInfo["address"] ?? false,
      },
      {
        "label": "Date de naissance",
        "value": userInfo['birth_date'] ?? 'Non renseigné',
        "isPublic": publicInfo["birth_date"] ?? false,
      },
      {
        "label": "Taille",
        "value": userInfo['height']?.toString() ?? 'Non renseigné',
        "isPublic": publicInfo["height"] ?? false,
      },
      {
        "label": "Groupe sanguin",
        "value": bloodGroupLabels[userInfo['blood_group']] ?? 'Non renseigné',
        "isPublic": publicInfo["blood_group"] ?? false,
      },
      {
        "label": "Électrophorèse",
        "value": electrophoresisLabels[userInfo['electrophoresis']] ??
            'Non renseigné',
        "isPublic": publicInfo["electrophoresis"] ?? false,
      },
      {
        "label": "Allergies",
        "value": userInfo['allergies'] ?? 'Non renseigné',
        "isPublic": publicInfo["allergies"] ?? false,
      },
      {
        "label": "Pathologies chroniques",
        "value": userInfo['medical_history'] ?? 'Non renseigné',
        "isPublic": publicInfo["medical_history"] ?? false,
      },
    ];

    print("voici les données transferées : $userData");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          userEmail: widget.userEmail,
          userNom: widget.userNom,
          userPhoto: widget.userPhoto,
          createdAt: widget.createdAt,
          userid: widget.userId,
          userData: userData,
        ),
      ),
    );
  }

// Remplacez le bouton "Modifier" par cet appel
}
