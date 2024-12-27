import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'database/ApiHelper.dart';

class DoctorSettingsPage extends StatefulWidget {
  final String userEmail;
  final String userNom;
  final String createdAt;
  final String userPhoto;
  final int userId;

  const DoctorSettingsPage({
    Key? key,
    required this.userEmail,
    required this.userNom,
    required this.createdAt,
    required this.userPhoto,
    required this.userId,
  }) : super(key: key);

  @override
  _DoctorSettingsPageState createState() => _DoctorSettingsPageState();
}

class _DoctorSettingsPageState extends State<DoctorSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers for form fields
  TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController onlineConsultationFeeController =
      TextEditingController();
  final TextEditingController inPersonConsultationFeeController =
      TextEditingController();
  TextEditingController experienceYearsController = TextEditingController();
  String selectedClinic = "";
  String biographyText = "";

  String? _selectedImagePath;

  // Dropdown for specialties and addresses
  List<String> specialties = ["Cardiologie", "Pédiatrie", "Dermatologie"];
  String? selectedSpeciality;
  List<String> countries = ["RDC", "Congo", "Angola"];
  String? selectedCountry;
  List<String> provinces = ["Kinshasa", "Katanga", "Kasaï"];
  String? selectedProvince;
  List<String> cities = ["Kinshasa", "Lubumbashi", "Mbuji-Mayi"];
  String? selectedCity;

  // Placeholder for switches
  bool onlineConsultationAvailable = false;
  bool twoFactorAuthEnabled = false;

  // Phone number
  PhoneNumber _currentPhoneNumber = PhoneNumber(isoCode: 'CD');
  String? _countryCode;
  String? _localNumber;

  @override
  void dispose() {
    // Libération des ressources des contrôleurs
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose(); // Appel à la méthode dispose de la classe parente
  }

  @override
  void initState() {
    super.initState();
    // Initialise le contrôleur avec l'email passé en paramètre
    nameController = TextEditingController(text: widget.userNom);
    emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  userId: widget.userId,
                  userCreateat: widget.createdAt,
                ),
              ),
            );
          },
        ),
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
      body: Stepper(
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

  Widget _buildPhotoSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _selectedImagePath != null
              ? FileImage(File(_selectedImagePath!))
              : const AssetImage('assets/placeholder.png') as ImageProvider,
        ),
      ],
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text(
          "Informations personnelles",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          children: [
            _buildPhotoSection(), // Affiche la section photo
            _buildTextField(
              "Nom complet",
              nameController,
              "Entrez votre nom complet",
              icon: Icons.photo_camera, // Icône personnalisée
              onIconPressed: () async {
                // Appeler la méthode pour ouvrir le popup
                await _showPhotoPicker(context);
              },
            ),
            _buildPhoneNumberField(),
            _buildTextField(
              "E-mail",
              emailController,
              "Entrez votre e-mail",
              keyboardType: TextInputType.emailAddress,
              icon: null,
            ),
            const SizedBox(height: 20),
            _buildDropdownField("Pays", countries, selectedCountry, (value) {
              setState(() {
                selectedCountry = value;
              });
            }),
            _buildDropdownField("Province", provinces, selectedProvince,
                (value) {
              setState(() {
                selectedProvince = value;
              });
            }),
            _buildDropdownField("Ville", cities, selectedCity, (value) {
              setState(() {
                selectedCity = value;
              });
            }),
            _buildTextField(
              "Adresse",
              addressController,
              "Entrez votre adresse complète",
              icon: null,
            ),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: const Text(
          "Informations professionnelles",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          children: [
            _buildDropdownField(
              "Spécialité médicale",
              specialties,
              selectedSpeciality,
              (value) {
                setState(() {
                  selectedSpeciality = value;
                });
              },
            ),
            _buildTextField(
              "Numéro d'ordre",
              registrationNumberController,
              "Entrez votre numéro",
              icon: null,
            ),
            _buildTextField(
              "Tarif cons. en ligne (\$)",
              onlineConsultationFeeController,
              "Entrez le tarif",
              icon: null,
            ),
            _buildTextField(
              "Tarif cons. en présentiel (\$)",
              inPersonConsultationFeeController,
              "Entrez le tarif",
              icon: null,
            ),
            _buildNumericField(
              "Années d'expérience",
              experienceYearsController,
              "Entrez vos années d'expérience",
            ),
            FutureBuilder<List<String>>(
              future:
                  fetchClinics(), // Méthode pour appeler l'API `medicalfacilities`
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text("Erreur de chargement des cliniques");
                } else {
                  return _buildDropdownField(
                    "Clinique",
                    snapshot.data ?? [],
                    selectedClinic,
                    (value) {
                      setState(() {
                        selectedClinic = value ?? '';
                      });
                    },
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                _showBiographyPopup();
              },
              child: const Text("Ajouter une biographie"),
            ),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      Step(
        title: const Text(
          "Disponibilités & Sécurité",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Consultation en ligne disponible"),
                value: onlineConsultationAvailable,
                onChanged: (value) {
                  setState(() {
                    onlineConsultationAvailable = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Double authentification (2FA)"),
                value: twoFactorAuthEnabled,
                onChanged: (value) {
                  setState(() {
                    twoFactorAuthEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep == 2,
      ),
      Step(
        title: const Text(
          "Récapitulatif",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Activez ou désactivez les infos que vous souhaitez rendre publiques",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ..._buildRecapFields().map((field) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: SwitchListTile(
                  title: Text(
                    "${field['label']}: ${field['value']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: field['isPublic'],
                  onChanged: (value) {
                    setState(() {
                      _publicInfo[field['label']] = value;
                    });
                  },
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              );
            }).toList(),
          ],
        ),
        isActive: _currentStep == 3,
      ),
    ];
  }

// Méthode pour générer les champs récapitulatifs
  List<Map<String, dynamic>> _buildRecapFields() {
    return [
      // Informations personnelles
      {
        "label": "Nom complet",
        "value": nameController.text.isNotEmpty
            ? nameController.text
            : "Non renseigné",
        "isPublic": _publicInfo["Nom complet"] ?? true,
      },
      {
        "label": "Téléphone",
        "value": phoneController.text.isNotEmpty
            ? phoneController.text
            : "Non renseigné",
        "isPublic": _publicInfo["Téléphone"] ?? true,
      },
      {
        "label": "E-mail",
        "value": emailController.text.isNotEmpty
            ? emailController.text
            : "Non renseigné",
        "isPublic": _publicInfo["E-mail"] ?? true,
      },
      {
        "label": "Adresse",
        "value": addressController.text.isNotEmpty
            ? addressController.text
            : "Non renseigné",
        "isPublic": _publicInfo["Adresse"] ?? true,
      },
      {
        "label": "Pays",
        "value": selectedCountry ?? "Non renseigné",
        "isPublic": _publicInfo["Pays"] ?? true,
      },
      {
        "label": "Province",
        "value": selectedProvince ?? "Non renseigné",
        "isPublic": _publicInfo["Province"] ?? true,
      },
      {
        "label": "Ville",
        "value": selectedCity ?? "Non renseigné",
        "isPublic": _publicInfo["Ville"] ?? true,
      },

      // Informations professionnelles
      {
        "label": "Spécialité médicale",
        "value": selectedSpeciality ?? "Non renseigné",
        "isPublic": _publicInfo["Spécialité médicale"] ?? true,
      },
      {
        "label": "Numéro d'ordre",
        "value": registrationNumberController.text.isNotEmpty
            ? registrationNumberController.text
            : "Non renseigné",
        "isPublic": _publicInfo["Numéro d'ordre"] ?? true,
      },
      {
        "label": "Tarif consultation en ligne (\$)",
        "value": onlineConsultationFeeController.text.isNotEmpty
            ? onlineConsultationFeeController.text
            : "Non renseigné",
        "isPublic": _publicInfo["Tarif consultation en ligne (\$)"] ?? true,
      },
      {
        "label": "Tarif consultation en présentiel (\$)",
        "value": inPersonConsultationFeeController.text.isNotEmpty
            ? inPersonConsultationFeeController.text
            : "Non renseigné",
        "isPublic":
            _publicInfo["Tarif consultation en présentiel (\$)"] ?? true,
      },
      {
        "label": "Années d'expérience",
        "value": experienceYearsController.text.isNotEmpty
            ? experienceYearsController.text
            : "Non renseigné",
        "isPublic": _publicInfo["Années d'expérience"] ?? true,
      },
      {
        "label": "Clinique",
        "value": selectedClinic ?? "Non renseigné",
        "isPublic": _publicInfo["Clinique"] ?? true,
      },
      {
        "label": "Biographie",
        "value": biographyText.isNotEmpty ? biographyText : "Non renseigné",
        "isPublic": _publicInfo["Biographie"] ?? true,
      },

      // Disponibilités et sécurité
      {
        "label": "Consultation en ligne",
        "value": onlineConsultationAvailable ? "Oui" : "Non",
        "isPublic": _publicInfo["Consultation en ligne"] ?? true,
      },
      {
        "label": "Double authentification",
        "value": twoFactorAuthEnabled ? "Oui" : "Non",
        "isPublic": _publicInfo["Double authentification"] ?? true,
      },
    ];
  }

  Widget _buildPhoneNumberField() {
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber phoneNumber) {
        setState(() {
          _currentPhoneNumber = phoneNumber;
          _countryCode = phoneNumber.dialCode;
          _localNumber = phoneNumber.phoneNumber
              ?.replaceFirst(phoneNumber.dialCode ?? '', '')
              .trim();
        });
      },
      textFieldController: phoneController,
      formatInput: true,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        setSelectorButtonAsPrefixIcon: true,
        showFlags: true,
      ),
      initialValue: _currentPhoneNumber,
      inputDecoration: const InputDecoration(
        labelText: "Téléphone",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumericField(
      String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        // Vérifiez si `value` est valide avant de l'utiliser
        value: (value != null && items.contains(value)) ? value : null,
        onChanged: onChanged,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Veuillez sélectionner une option.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onIconPressed,
    IconData? icon = Icons.photo, // Icône personnalisable, par défaut "photo"
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: icon != null
              ? IconButton(
                  icon: Icon(icon, color: Colors.grey),
                  onPressed: onIconPressed,
                )
              : null, // Si aucune icône n'est fournie, ne rien afficher
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Veuillez remplir ce champ.";
          }
          return null;
        },
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _buildSteps().length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<List<String>> fetchClinics() async {
    final url = ApiHelper.getmedicalfacilitiesEndpoint();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data.map((clinic) => clinic['name']));
    } else {
      throw Exception("Erreur lors de la récupération des cliniques");
    }
  }

  void _showBiographyPopup() {
    final TextEditingController bioController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter une biographie"),
          content: TextField(
            controller: bioController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: "Écrivez ici votre biographie...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  biographyText = bioController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPhotoPicker(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choisir depuis la galerie"),
              onTap: () async {
                pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _selectedImagePath = pickedFile!.path;
                  });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Prendre une photo"),
              onTap: () async {
                pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _selectedImagePath = pickedFile!.path;
                  });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Annuler"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      print("Chemin de l'image : ${pickedFile!.path}");
    }
  }

  Map<String, bool> _publicInfo = {
    // Informations personnelles
    "Nom complet": false,
    "Téléphone": false,
    "E-mail": false,
    "Adresse": false,
    "Pays": false,
    "Province": false,
    "Ville": false,

    // Informations professionnelles
    "Spécialité médicale": false,
    "Numéro d'ordre": false,
    "Tarif consultation en ligne (\$)": false,
    "Tarif consultation en présentiel (\$)": false,
    "Années d'expérience": false,
    "Clinique": false,
    "Biographie": false,

    // Disponibilités et sécurité
    "Consultation en ligne": false,
    "Double authentification": false,
  };
}
