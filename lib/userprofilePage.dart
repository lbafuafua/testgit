import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'HomePage.dart';
import 'database/ApiHelper.dart';

class ProfilePage extends StatefulWidget {
  final String userEmail;
  final String userNom;
  final String userPhoto;
  final String createdAt;
  final int userid;
  final List<Map<String, dynamic>> userData;

  const ProfilePage({
    Key? key,
    required this.userEmail,
    required this.userNom,
    required this.userPhoto,
    required this.createdAt,
    required this.userid,
    required this.userData,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentStep = 0;

  // Controllers for personal data
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  PhoneNumber _currentPhoneNumber = PhoneNumber(isoCode: 'CD');
  String? _selectedGender;

  String? _countryCode;
  String? _localNumber; // Pour la partie restante

  String _formatedPhoneNumber = '';

  List<Map<String, dynamic>> bloodGroups = [];
  List<Map<String, dynamic>> electrophoreses = [];
  int? selectedBloodGroupId;
  String? selectedBloodGroup;
  int? selectedElectrophoresisId;
  String? selectedElectrophoresis;
  bool isLoading = true; // Pour afficher un indicateur de chargement

  // Controllers for medical data
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  bool _acceptedTerms = false;

  int? _calculatedAge;

  @override
  void initState() {
    super.initState();
    if (widget.userData.isNotEmpty) {
      try {
        // Extraire les données utilisateur sous forme de Map
        final userDataMap = {
          for (var item in widget.userData) item['label']: item['value']
        };

        // Initialiser les champs avec les données utilisateur si disponibles
        _firstNameController.text = userDataMap["Prénom"] ?? "";
        _lastNameController.text = userDataMap["Nom"] ?? "";
        _dateOfBirthController.text = userDataMap["Date de naissance"] ?? "";
        _addressController.text = userDataMap["Adresse"] ?? "";
        _phoneController.text = userDataMap["Téléphone"] ?? "";
        _heightController.text = userDataMap["Taille"] ?? "";
        _allergiesController.text = userDataMap["Allergies"] ?? "";
        _conditionsController.text =
            userDataMap["Pathologies chroniques"] ?? "";
        _selectedGender = userDataMap["Sexe"];

        splitEmergencyContact(userDataMap["Téléphone"]);

        selectedBloodGroup = userDataMap["Groupe sanguin"];
        selectedElectrophoresis = userDataMap["Électrophorèse"];

        _initializePhoneNumber(_countryCode, _localNumber);
      } catch (e) {
        print("Erreur lors de l'initialisation des données utilisateur : $e");
      }
    }

    // Charger les groupes sanguins et électrophorèses
    _fetchBloodGroups().then((_) {
      if (selectedBloodGroup != null) {
        final group = bloodGroups.firstWhere(
            (g) => g['name'] == selectedBloodGroup,
            orElse: () => {});
        selectedBloodGroupId = group.isNotEmpty ? group['id'] : null;
      }
    });

    _fetchElectrophoresisOptions().then((_) {
      if (selectedElectrophoresis != null) {
        final electro = electrophoreses.firstWhere(
            (e) => e['type'] == selectedElectrophoresis,
            orElse: () => {});
        selectedElectrophoresisId = electro.isNotEmpty ? electro['id'] : null;
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _fetchBloodGroups() async {
    final url = ApiHelper.getBloodGroupsEndpoint();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bloodGroups = data
              .map((group) => {"id": group['id'], "name": group['name']})
              .toList();
        });
      } else {
        throw Exception("Erreur lors du chargement des groupes sanguins");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  Future<void> _fetchElectrophoresisOptions() async {
    final url = ApiHelper.getElectrophoresisEndpoint();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          electrophoreses = data
              .map((electro) => {"id": electro['id'], "type": electro['type']})
              .toList();
        });
      } else {
        throw Exception("Erreur lors du chargement des électrophorèses");
      }
    } catch (e) {
      print("Erreur : $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Sélectionnez votre date de naissance',
    );

    if (selectedDate != null) {
      setState(() {
        _dateOfBirthController.text =
            "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
        _calculatedAge = _calculateAge(selectedDate);
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userEmail: widget.userEmail,
                  userNom: widget.userNom,
                  userPhoto: widget.userPhoto,
                  userId: widget.userid,
                  userCreateat: widget.createdAt,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _previousStep,
              steps: _buildSteps(),
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Précédent'),
                      ),
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentStep == _buildSteps().length - 1
                          ? 'Terminer'
                          : 'Suivant'),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text("Informations personnelles"),
        content: Column(
          children: [
            _buildEditableField("Prénom", _firstNameController),
            _buildEditableField("Nom", _lastNameController),
            _buildGenderField(),
            _buildPhoneNumberField(),
            _buildEditableField("Adresse", _addressController),
            _buildDateOfBirthField(),
            if (_calculatedAge != null)
              Text("Âge : $_calculatedAge ans",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildEditableField("Taille (en cm)", _heightController,
                keyboardType: TextInputType.number),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text("Informations médicales (optionnelles)"),
        content: Column(
          children: [
            _buildBloodGroupField(),
            _buildElectrophoresisField(),
            _buildEditableField("Allergies", _allergiesController),
            _buildEditableField(
                "Pathologies chroniques", _conditionsController),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text("Récapitulatif"),
        content: _buildRecapitulatif(),
        isActive: _currentStep == 2,
      ),
      Step(
        title: const Text("Conditions d'utilisation"),
        content: Column(
          children: [
            const Text(
              "Veuillez lire et accepter les conditions suivantes :",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "1. Vos données seront utilisées uniquement dans le cadre des services fournis par l'application.\n"
              "2. Vous acceptez de fournir des informations exactes et à jour.\n"
              "3. Vous pouvez à tout moment modifier ou supprimer vos données.",
              style: TextStyle(color: Colors.black),
            ),
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    "J'accepte les conditions d'utilisation",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        isActive: _currentStep == 3,
      ),
    ];
  }

  Widget _buildRecapitulatif() {
    // Déterminer si les champs de saisie sont disponibles
    bool hasEditableFields = _firstNameController.text.isNotEmpty ||
        _lastNameController.text.isNotEmpty ||
        _dateOfBirthController.text.isNotEmpty ||
        _addressController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty;

    // Construire les données récapitulatives
    List<Map<String, dynamic>> recapData = hasEditableFields
        ? [
            {
              "label": "Prénom",
              "value": _firstNameController.text,
              "isPublic": _publicInfo["Prénom"]
            },
            {
              "label": "Nom",
              "value": _lastNameController.text,
              "isPublic": _publicInfo["Nom"]
            },
            {
              "label": "Sexe",
              "value": _selectedGender ?? "Non renseigné",
              "isPublic": _publicInfo["Sexe"]
            },
            {
              "label": "Téléphone",
              "value": _currentPhoneNumber.phoneNumber ?? "Non renseigné",
              "isPublic": _publicInfo["Téléphone"]
            },
            {
              "label": "Adresse",
              "value": _addressController.text,
              "isPublic": _publicInfo["Adresse"]
            },
            {
              "label": "Date de naissance",
              "value": _dateOfBirthController.text,
              "isPublic": _publicInfo["Date de naissance"]
            },
            {
              "label": "Taille",
              "value": _heightController.text,
              "isPublic": _publicInfo["Taille"]
            },
            {
              "label": "Groupe sanguin",
              "value": selectedBloodGroup ?? "Non renseigné",
              "isPublic": _publicInfo["Groupe sanguin"]
            },
            {
              "label": "Électrophorèse",
              "value": selectedElectrophoresis ?? "Non renseigné",
              "isPublic": _publicInfo["Électrophorèse"]
            },
            {
              "label": "Allergies",
              "value": _allergiesController.text,
              "isPublic": _publicInfo["Allergies"]
            },
            {
              "label": "Pathologies chroniques",
              "value": _conditionsController.text,
              "isPublic": _publicInfo["Pathologies chroniques"]
            },
          ]
        : widget.userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Activez ou désactivez les infos que vous souhaitez rendre publiques",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...recapData.map((item) {
          return _buildRecapRow(
            item['label'], // Le libellé de l'élément (e.g., "Prénom")
            item['value'], // La valeur de l'élément (e.g., "Jean")
            item['label'], // La clé correspondante
            userData: recapData,
            isEditableMode: hasEditableFields, // Indique le mode actuel
            onChanged: (value) {
              setState(() {});
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecapRow(String label, String value, String key,
      {required List<Map<String, dynamic>> userData,
      required ValueChanged<bool> onChanged,
      required bool isEditableMode}) {
    // Déterminer l'état `isPublic` en fonction du mode (editable ou non)
    bool isPublic = isEditableMode
        ? (_publicInfo[label] ?? false) // Dans le cas des champs de saisie
        : (userData.firstWhere((item) => item['label'] == key)['isPublic'] ??
            false); // Dans le cas de userData

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "$label : $value",
          ),
        ),
        Transform.scale(
          scale: 0.8, // Taille uniforme du Switch
          child: Switch(
            value: isPublic,
            onChanged: (value) {
              if (isEditableMode) {
                // Mettre à jour `_publicInfo` dans le mode champs de saisie
                _publicInfo[label] = value;
              } else {
                // Mettre à jour `userData` dans le mode userData
                int index = userData.indexWhere((item) => item['label'] == key);
                if (index != -1) {
                  userData[index]['isPublic'] = value;
                }
              }
              onChanged(value); // Appeler la fonction callback
            },
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey,
            activeTrackColor: Colors.blue.withOpacity(0.5),
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        )
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue,
      List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        items: items
            .map((value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBloodGroupField() {
    if (isLoading) {
      return CircularProgressIndicator(); // Afficher un indicateur de chargement
    }

    return DropdownButtonFormField<int>(
      value: selectedBloodGroupId,
      onChanged: (int? newValue) {
        setState(() {
          selectedBloodGroupId = newValue;
          selectedBloodGroup = bloodGroups
              .firstWhere((group) => group['id'] == newValue)['name'];
        });
      },
      items: bloodGroups.map((group) {
        return DropdownMenuItem<int>(
          value: group['id'],
          child: Text(group['name']),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: "Groupe sanguin",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildElectrophoresisField() {
    if (isLoading) {
      return const Center(
          child:
              CircularProgressIndicator()); // Afficher un indicateur de chargement
    }

    return DropdownButtonFormField<int>(
      value: selectedElectrophoresisId,
      onChanged: (int? newValue) {
        setState(() {
          selectedElectrophoresisId = newValue;
          // Trouver l'élément correspondant et récupérer son 'type'
          final selectedElectro = electrophoreses.firstWhere(
              (electro) => electro['id'] == newValue,
              orElse: () => {"type": null});
          selectedElectrophoresis = selectedElectro['type'] ?? '';
        });
      },
      items: electrophoreses.map((electro) {
        return DropdownMenuItem<int>(
          value: electro['id'],
          child: Text(electro['type'] ??
              'Type indisponible'), // Utiliser le champ 'type'
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: "Électrophorèse",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderField() {
    return _buildDropdownField("Sexe", _selectedGender, ["Homme", "Femme"],
        (value) {
      setState(() {
        _selectedGender = value;
      });
    });
  }

  Widget _buildPhoneNumberField() {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber phoneNumber) {
        setState(() {
          _currentPhoneNumber = phoneNumber;
          _countryCode = phoneNumber.dialCode; // Récupérer le code pays
          _localNumber = phoneNumber.phoneNumber
              ?.replaceFirst(phoneNumber.dialCode ?? '', '')
              .trim(); // Supprimer le code pays
        });

        print("Téléphone formaté : ($_countryCode)$_localNumber");
      },
      textFieldController: _phoneController,
      initialValue: _currentPhoneNumber, // Pré-remplir avec les données
      formatInput: true,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        setSelectorButtonAsPrefixIcon: true,
        showFlags: true,
      ),
      inputDecoration: const InputDecoration(
        labelText: "Téléphone",
        border: OutlineInputBorder(),
      ),
    );
  }

  void _initializePhoneNumber(String? codpays, String? tellocal) {
    if (codpays == null || tellocal == null) {
      print('Code pays ou numéro local invalide.');
      return;
    }

    try {
      _currentPhoneNumber = PhoneNumber(
        dialCode: codpays,
        phoneNumber: tellocal,
        isoCode: 'CD', // Adaptez à votre besoin
      );
      _phoneController.text = tellocal;
    } catch (e) {
      print("Erreur lors de l'initialisation du numéro de téléphone : $e");
    }
  }

  Widget _buildDateOfBirthField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: _dateOfBirthController,
          decoration: InputDecoration(
            labelText: 'Date de naissance',
            suffixIcon: const Icon(Icons.calendar_today),
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      if (_acceptedTerms) {
        submitPatientData(
          context,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          addressController: _addressController,
          medicalHistoryController: _conditionsController,
          allergiesController: _allergiesController,
          emergencyContactController: _formatedPhoneNumber,
          birthDateController: _dateOfBirthController,
          heightController: _heightController,
          selectedGender: _selectedGender,
          selectedBloodGroup: selectedBloodGroupId.toString(),
          selectedElectrophoresis: selectedElectrophoresisId.toString(),
          userId: widget.userid,
        );

        submitPublicPatientDataRecords();

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Profil enregistré avec succès !")),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Vous devez accepter les conditions pour continuer.")),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void submitPatientData(
    BuildContext context, {
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController addressController,
    required TextEditingController medicalHistoryController,
    required TextEditingController allergiesController,
    required String emergencyContactController,
    required TextEditingController birthDateController,
    required TextEditingController heightController,
    required String? selectedGender,
    required String? selectedBloodGroup,
    required String? selectedElectrophoresis,
    required int userId,
  }) async {
    // Préparation des données à envoyer
    Map<String, dynamic> patientData = {
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "address": addressController.text,
      "medical_history": medicalHistoryController.text,
      "allergies": allergiesController.text,
      "emergency_contact": _currentPhoneNumber.phoneNumber?.replaceAll(' ', ''),
      "gender": selectedGender,
      "birth_date": birthDateController.text,
      "height": double.tryParse(heightController.text),
      "user": userId, // ID de l'utilisateur
      "blood_group": selectedBloodGroupId,
      "electrophoresis": selectedElectrophoresisId,
    };

    ApiHelper apiHelper = ApiHelper(); // Créer une instance d'ApiHelper

    try {
      // Envoi des données au serveur

      print("JSON à envoyer : ${jsonEncode(patientData)}");

      String result = await apiHelper.sendPatientData(patientData);

      // Affichage du résultat avec un SnackBar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor:
              result.contains("succès") ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void submitPublicPatientDataRecords() async {
    List<Map<String, dynamic>> publicDataRecords =
        getPublicPatientDataRecords();

    print("Données publiques à envoyer : ${jsonEncode(publicDataRecords)}");

    ApiHelper apiHelper = ApiHelper();

    try {
      for (var record in publicDataRecords) {
        String result = await apiHelper.sendPublicDataRecord(record);
        print("JSON public à envoyer : ${jsonEncode(record)}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor:
                result.contains("succès") ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // États pour les cases à cocher
  Map<String, bool> _publicInfo = {
    "Prénom": true,
    "Nom": true,
    "Sexe": true,
    "Téléphone": false,
    "Adresse": false,
    "Date de naissance": false,
    "Taille": false,
    "Groupe sanguin": true,
    "Électrophorèse": false,
    "Allergies": false,
    "Pathologies chroniques": false,
  };

  List<Map<String, dynamic>> getPublicPatientDataRecords() {
    List<Map<String, dynamic>> publicDataRecords = [];

    void addRecord(String infoKey, String? value) {
      if (value != null && value.isNotEmpty && _publicInfo[infoKey] == true) {
        publicDataRecords.add({
          "user": 1, // ID de l'utilisateur
          "info": value,
        });
      }
    }

    addRecord("Prénom", _firstNameController.text);
    addRecord("Nom", _lastNameController.text);
    addRecord("Adresse", _addressController.text);
    addRecord("Pathologies chroniques", _conditionsController.text);
    addRecord("Allergies", _allergiesController.text);
    addRecord("Téléphone", _formatedPhoneNumber);
    addRecord("Sexe", _selectedGender);
    addRecord("Date de naissance", _dateOfBirthController.text);
    addRecord("Taille", _heightController.text);
    addRecord("Groupe sanguin", selectedBloodGroup);
    addRecord("Électrophorèse", selectedElectrophoresis);

    return publicDataRecords;
  }

  void splitEmergencyContact(String? emergencyContact) {
    if (emergencyContact == null || !emergencyContact.contains('(')) {
      print('Invalid contact format or null value');
      return;
    }

    final RegExp regex = RegExp(r'\((.*?)\)');
    final match = regex.firstMatch(emergencyContact);

    if (match != null) {
      final countryCode = match.group(1); // Contenu des parenthèses
      final restOfNumber = emergencyContact
          .replaceAll('($countryCode)', '')
          .trim(); // Supprime le code pays

      print('le Code pays: $countryCode');
      print('le Numéro: $restOfNumber');

      _countryCode = countryCode;
      _localNumber = restOfNumber; // Pour la partie restante
    } else {
      print('Format incorrect pour le numéro de téléphone.');
    }
  }
}
