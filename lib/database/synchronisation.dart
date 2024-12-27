import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:findone/models/Notification.dart';
import 'package:findone/database/DatabaseHelper.dart';

class NotificationService {
  final String baseUrl = 'https://votre-api.com/api';
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Méthode pour synchroniser les notifications avec le backend
  Future<void> syncNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'));

      if (response.statusCode == 200) {
        List<dynamic> serverNotifications = jsonDecode(response.body);

        for (var item in serverNotifications) {
          Notification notification = Notification.fromJson(item);

          // Stockez chaque notification en local
          await dbHelper.insertNotification(notification);
        }
      }
    } catch (e) {
      print("Erreur de synchronisation des notifications : $e");
    }
  }

  // Méthode pour obtenir les notifications (hors ligne + en ligne)
  Future<List<Notification>> getNotifications() async {
    try {
      await syncNotifications();
      return await dbHelper.getOfflineNotifications();
    } catch (e) {
      // En cas d'échec, ne récupérer que les données locales
      print("Erreur réseau, utilisation des notifications hors ligne");
      return await dbHelper.getOfflineNotifications();
    }
  }
}
