import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:findone/database/DatabaseHelper.dart';
import 'package:findone/models/user.dart';
import 'LoginPage.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false; // Indicateur de chargement

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signup() async {
    final username = usernameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      if (password == confirmPassword) {
        User newUser = User(
          username: username,
          email: email,
          password: password,
          profilePicture: _profileImage?.path ?? '',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          status: 'offline',
        );

        setState(() {
          _isLoading = true; // Affiche le chargement
        });

        try {
          // Création de l'utilisateur sur le serveur
          final response = await _createUserOnServer(newUser);

          if (response != null) {
            newUser.id = response['id'];
            newUser.status = 'online'; // Marquez l'utilisateur comme connecté

            // Remplacer l'utilisateur dans SQLite après succès
            await _replaceUserInSQLite(newUser);

            setState(() {
              _isLoading = false; // Cache le chargement
            });

            _showConfirmationDialog("Compte créé avec succès !");
          } else {
            setState(() {
              _isLoading = false; // Cache le chargement
            });
            _showConfirmationDialog(
                "Erreur lors de la création sur le serveur");
          }
        } catch (e) {
          setState(() {
            _isLoading = false; // Cache le chargement
          });
          _showConfirmationDialog("Erreur : ${e.toString()}");
        }
      } else {
        _showConfirmationDialog("Les mots de passe ne correspondent pas");
      }
    } else {
      _showConfirmationDialog("Veuillez remplir tous les champs");
    }
  }

  Future<Map<String, dynamic>?> _createUserOnServer(User user) async {
    try {
      final url = Uri.parse('http://www.ceri-amcp.com:8082/api/users/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': user.username,
          'email': user.email,
          'password': user.password,
          'profile_picture': user.profilePicture,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Utilisateur créé avec succès
      } else {
        print("Erreur serveur : ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erreur de connexion avec le serveur : $e");
      return null;
    }
  }

  Future<void> _replaceUserInSQLite(User user) async {
    final dbHelper = DatabaseHelper();
    try {
      await dbHelper.deleteAllUsers();
      await dbHelper.insertUser(user);
      print("Utilisateur remplacé dans SQLite");
    } catch (e) {
      print("Erreur lors du remplacement de l'utilisateur dans SQLite : $e");
    }
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Information"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le popup
                if (message == "Compte créé avec succès !") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        email: emailController
                            .text, // Passe l'email à la page de connexion
                      ),
                    ),
                  );
                }
              },
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
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Color(0xFF283593)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20),
                              Center(
                                child: Image.asset(
                                  'assets/logofo.png',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 40),
                              GestureDetector(
                                onTap: () => _showImageSourceDialog(),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.red[600],
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? Icon(Icons.camera_alt,
                                          color: Colors.white, size: 30)
                                      : null,
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildTextField(usernameController, Icons.person,
                                  'Nom d’utilisateur', false),
                              SizedBox(height: 20),
                              _buildTextField(
                                  emailController, Icons.email, 'Email', false),
                              SizedBox(height: 20),
                              _buildTextField(passwordController, Icons.lock,
                                  'Mot de passe', true),
                              SizedBox(height: 20),
                              _buildTextField(
                                  confirmPasswordController,
                                  Icons.lock,
                                  'Confirmer le mot de passe',
                                  true),
                              SizedBox(height: 20),
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                    ),
                                    onPressed: _signup,
                                    child: Text(
                                      'Créer un compte',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 60),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Merci de nous rejoindre!',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isLoading) // Affiche un indicateur de chargement
            Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon,
      String hintText, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.red[600]),
        hintText: hintText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sélectionnez la source de l'image"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: Text("Caméra"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: Text("Galerie"),
            ),
          ],
        );
      },
    );
  }
}
