import 'package:flutter/material.dart';
import 'package:findone/database/DatabaseHelper.dart';
import 'HomePage.dart';
import 'SignupPage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database/ApiHelper.dart';
import 'userprofilePage.dart';
import 'package:flutter/scheduler.dart';

class LoginPage extends StatefulWidget {
  final String email;

  LoginPage({required this.email});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController emailController; // Initialisé dans initState
  final TextEditingController passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    // Initialise le contrôleur avec l'email passé en paramètre
    emailController = TextEditingController(text: widget.email);
  }

  ApiHelper apiHelper = ApiHelper(); // Créer une instance d'ApiHelper

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final userInfo = await apiHelper.loginUser(email, password);

    if (userInfo != null) {
      // Vérifier si les données patient existent
      final patientData = await apiHelper.getPatientData(userInfo['id']);
      String Utilisateur = userInfo['id'].toString();
      print(
          'voici le fichier json avaec données du patient( $Utilisateur ) : $patientData');

      if (patientData == null || patientData.isEmpty) {
        // Afficher un popup pour demander de compléter les informations
        bool consent = await _showConsentDialog();

        if (consent) {
          // Rediriger vers la page de profil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                userid: userInfo['id'],
                userEmail: userInfo['email'],
                userNom: userInfo['username'],
                userPhoto: userInfo['profile_picture'],
                createdAt: userInfo['createdAt'] ?? '',
                userData: [], // Aucune donnée initiale pour le profil
              ),
            ),
          );
        } else {
          // Si l'utilisateur refuse, rester sur la page de connexion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("Vous devez compléter vos informations pour continuer."),
            ),
          );
        }
      } else {
        // Si les données patient existent, rediriger vers la page d'accueil
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userId: userInfo['id'],
                  userNom: userInfo['username'],
                  userPhoto: userInfo['profile_picture'],
                  userEmail: userInfo['email'],
                  userCreateat: userInfo['createdAt'] ?? '',
                ),
              ),
            );
          }
        });
      }
    } else {
      // Afficher un message d'erreur en cas d'authentification échouée
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte inexistant ou informations incorrectes."),
        ),
      );
    }
  }

// Afficher une boîte de dialogue pour demander le consentement de l'utilisateur

  Future<bool> _showConsentDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Compléter vos informations"),
              content: const Text(
                "Il semble que vos informations de patient ne soient pas complètes. "
                "Souhaitez-vous compléter ces informations maintenant ?",
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Non"),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Consentement refusé
                  },
                ),
                ElevatedButton(
                  child: const Text("Oui"),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Consentement accordé
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Valeur par défaut si le dialogue est fermé sans réponse
  }

  Future<void> _authenticateWithFaceID() async {
    try {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à votre compte',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        Map<String, dynamic>? userInfo = await DatabaseHelper().getFirstUser();

        if (userInfo != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userId: userInfo['id'],
                userNom: userInfo['username'],
                userPhoto: userInfo['profile_picture'],
                userEmail: userInfo['email'],
                userCreateat: userInfo['createdAt'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Aucun utilisateur trouvé."),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentification échouée : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Prend toute la largeur de l'écran
        height: double.infinity, // Prend toute la hauteur de l'écran
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Color(0xFF283593)
            ], // Rouge en bas, bleu en haut
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 60), // Espace pour remonter l'image
                Image.asset(
                  'assets/logofo.png', // Chemin du logo
                  height: 100, // Taille ajustée pour mieux occuper l'espace
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 40), // Espace entre le logo et les champs
                _buildTextField(
                  emailController,
                  Icons.email,
                  'Email',
                  false,
                  readOnly: true, // Rend le champ non modifiable
                ),
                SizedBox(height: 20),
                _buildTextField(
                  passwordController,
                  Icons.lock,
                  'Password',
                  true,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600], // Rouge pour le bouton
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: _login,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: Text(
                    'Create an account',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Divider(color: Colors.white),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Fond blanc
                    foregroundColor: Color(0xFF283593), // Texte en bleu foncé
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  icon: Icon(Icons.face),
                  onPressed: _authenticateWithFaceID,
                  label: Text(
                    'Se connecter avec Face ID',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hintText,
    bool obscureText, {
    bool readOnly = false, // Paramètre pour rendre le champ en lecture seule
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly, // Appliquer lecture seule si nécessaire
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.red[600]), // Icône rouge
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9), // Fond blanc
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[700]),
      ),
    );
  }
}
