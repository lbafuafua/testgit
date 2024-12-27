import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'database/DatabaseHelper.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleStartupLogic();
  }

  // Fonction principale pour gérer le démarrage

  Future<void> _handleStartupLogic() async {
    // Vérifie si un utilisateur existe dans la base de données SQLite
    final userEmail = await _getUserFromDatabase();

    if (userEmail != null) {
      // Un utilisateur a été trouvé
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            email: userEmail, // Passe l'email à la page de connexion
          ),
        ),
      );
    } else {
      // Pas d'utilisateur, vérifiez la connexion Internet
      final hasInternet = await _checkInternetConnection();

      if (hasInternet) {
        // Connexion Internet disponible, afficher un message de bienvenue
        _showWelcomeDialog();
      } else {
        // Pas de connexion Internet
        _showNoInternetDialog();
      }
    }
  }

  // Fonction pour récupérer l'utilisateur depuis SQLite
  Future<String?> _getUserFromDatabase() async {
    try {
      Map<String, dynamic>? userInfo = await DatabaseHelper().getFirstUser();
      if (userInfo != null) {
        return userInfo['email'] as String?;
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    }
    return null; // Aucun utilisateur trouvé
  }

  Future<bool> _checkInternetConnection() async {
    try {
      // Vérifiez si un réseau est disponible (WiFi ou Mobile)
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print("Aucun réseau disponible");
        return false; // Aucun réseau disponible
      }

      // Vérifiez l'accès réel à Internet avec une requête HTTP
      return await _testInternetAccess();
    } catch (e) {
      print("Erreur de vérification d'Internet : $e");
      return false; // Internet inaccessible
    }
  }

  Future<bool> _testInternetAccess() async {
    const String testUrl = 'https://www.google.com/generate_204';

    try {
      final response = await http.get(Uri.parse(testUrl)).timeout(
            Duration(seconds: 5), // Timeout après 5 secondes
          );
      if (response.statusCode == 204) {
        print("Connexion Internet détectée via $testUrl");
        return true; // Connexion Internet disponible
      } else {
        print("Code de statut inattendu : ${response.statusCode}");
        return false; // Code HTTP inattendu
      }
    } catch (e) {
      print("Erreur lors de la requête HTTP : $e");

      return false; // Erreur de requête
    }
  }

  // Affiche un message de bienvenue dans un popup
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Empêche la fermeture du popup en cliquant à l'extérieur
      builder: (context) {
        return AlertDialog(
          title: Text("Bienvenue sur FindOne"),
          content: Text(
            "Merci de vouloir découvrir FindOne ! "
            "Nous sommes ravis de vous accueillir. "
            "Créer un compte pour profiter pleinement de nos services.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le popup
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SignupPage(), // Redirection vers Signup
                  ),
                );
              },
              child: Text("Créer un compte"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le popup sans redirection
              },
              child: Text("Pas maintenant"),
            ),
          ],
        );
      },
    );
  }

  // Affiche un avertissement en cas de manque de connexion Internet
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pas d'Internet"),
          content:
              Text("Veuillez vérifier votre connexion Internet et réessayer."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF283593), Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety,
                size: 100.0,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "FindOne",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
