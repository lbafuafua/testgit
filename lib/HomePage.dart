import 'package:flutter/material.dart';
import 'search_doctor.dart';
import 'search_hospital.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'userprofilePage.dart';
import 'DoctorSettingsPage.dart';
import 'UserInfosPage.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String userNom;
  final String userPhoto;
  final String userEmail;
  final String userCreateat;

  HomePage({
    required this.userId,
    required this.userNom,
    required this.userPhoto,
    required this.userEmail,
    required this.userCreateat,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Liste des pages accessibles via le BottomNavigationBar
  final List<Widget> _pages = [
    SearchDoctorPage(), // Page de Docteur
    HospitalSearchPage(), // Page de l'Hôpital
    Page3(), // Page de la Pharmacie
    Page4(), // Page de l'Ambulance
    Page5(), // Page du Donneur de sang
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Déconnexion"),
          content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                exit(0); // Fermer l'application
              },
              child: Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF283593), Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    // Logique pour les notifications
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF283593), Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF283593), Colors.red],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.userPhoto != null &&
                              widget.userPhoto.isNotEmpty
                          ? FileImage(File(widget.userPhoto))
                          : AssetImage('assets/profile.jpg') as ImageProvider,
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.userNom,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.white),
                title: Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.white),
                title:
                    Text('Appointments', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.message, color: Colors.white),
                title: Text('Messages', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title:
                    Text('Mon compte', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ProfilePage(
                  //       userEmail: widget.userEmail,
                  //       userNom: widget.userNom,
                  //       userPhoto: widget.userPhoto,
                  //       createdAt: widget.userCreateat,
                  //       userid: widget.userId,
                  //     ),
                  //   ),
                  // );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInfosPage(
                        userEmail: widget.userEmail,
                        userNom: widget.userNom,
                        userPhoto: widget.userPhoto,
                        createdAt: widget.userCreateat,
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title:
                    Text('Parametrage', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorSettingsPage(
                        userEmail: widget.userEmail,
                        userNom: widget.userNom,
                        userPhoto: widget.userPhoto,
                        createdAt: widget.userCreateat,
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
              ),
              Divider(color: Colors.white),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80, // Hauteur augmentée pour agrandir la barre
        decoration: BoxDecoration(
          color: Colors.red, // Couleur de fond rouge
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital),
              label: 'Docteur',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy_sharp),
              label: 'Médicament',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital_outlined),
              label: 'Hôpital',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy),
              label: 'Pharmacie',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'Ambulance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism),
              label: 'Donneur de sang',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Page Pharmacie", style: TextStyle(fontSize: 24)),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Page Ambulance", style: TextStyle(fontSize: 24)),
    );
  }
}

class Page5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Page Donneur de sang", style: TextStyle(fontSize: 24)),
    );
  }
}
