import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HospitalSearchPage extends StatelessWidget {
  final List<String> hospitalImages = [
    'assets/HJ.jpg',
    'assets/MDN.jpg',
    // 'assets/hospital3.jpg',
    // Ajoutez d'autres images d'hôpitaux
  ];

  final List<Map<String, String>> hospitals = [
    {"name": "HJ HOSPITAL", "location": "Avenue Centrale, Ville"},
    {
      "name": "MEDECINS DE NUIT SARL",
      "location": "Boulevard de la Santé, Ville"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF283593),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone de recherche
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Rechercher un hôpital...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Carrousel d'images des hôpitaux
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  scrollDirection: Axis.horizontal,
                  viewportFraction: 1.0,
                ),
                items: hospitalImages.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Liste des hôpitaux de référence
              Text(
                "Hôpitaux de Référence",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: hospitals.map((hospital) {
                  return Card(
                    child: ListTile(
                      leading:
                          Icon(Icons.local_hospital, color: Color(0xFF283593)),
                      title: Text(hospital["name"]!),
                      subtitle: Text(hospital["location"]!),
                      trailing: Icon(Icons.location_on, color: Colors.red),
                      onTap: () {
                        // Afficher la carte avec la localisation de l’hôpital
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HospitalMapPage(
                                hospitalName: hospital["name"]!),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HospitalMapPage extends StatelessWidget {
  final String hospitalName;

  HospitalMapPage({required this.hospitalName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF283593),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            {}
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Logique pour les notifications
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Carte de localisation de $hospitalName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "La carte sera intégrée ici.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
