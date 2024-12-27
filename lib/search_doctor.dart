// Page 1 (Docteur)
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SearchDoctorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF283593),
      //   elevation: 0,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SearchBar(),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Rechercher un Médecin...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ImageCarousel(
                imageAssets: [
                  'assets/doctor.jpeg',
                  'assets/profile.jpg',
                ],
              ),
              SizedBox(height: 20),
              SpecialityIcons(),
              SizedBox(height: 20),
              Text(
                "Best Specialist",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SpecialistList(),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageCarousel extends StatelessWidget {
  final List<String> imageAssets;

  ImageCarousel({required this.imageAssets});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
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
      items: imageAssets.map((asset) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class SpecialityIcons extends StatelessWidget {
  final List<Map<String, dynamic>> specialities = [
    {"icon": Icons.medical_services, "label": "General"},
    {"icon": Icons.local_hospital, "label": "Dentist"},
    {"icon": Icons.remove_red_eye, "label": "Ophthalmology"},
    {"icon": Icons.fastfood, "label": "Nutrition"},
    {"icon": Icons.psychology, "label": "Neurology"},
    {"icon": Icons.child_care, "label": "Pediatric"},
    {"icon": Icons.radio, "label": "Radiology"},
    {"icon": Icons.more_horiz, "label": "More"},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: specialities.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade50,
              child:
                  Icon(specialities[index]["icon"], color: Color(0xFF283593)),
            ),
            SizedBox(height: 5),
            Text(
              specialities[index]["label"],
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        );
      },
    );
  }
}

class SpecialistList extends StatelessWidget {
  final List<Map<String, String>> specialists = [
    {"name": "Dr. Joseph Brostitto", "title": "MD, MS, MBBS"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: specialists.map((specialist) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/doctor.jpeg'),
          ),
          title: Text(specialist["name"]!),
          subtitle: Text(specialist["title"]!),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {},
        );
      }).toList(),
    );
  }
}
