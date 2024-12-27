import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:findone/models/user.dart';
import 'package:findone/models/MedicalFacility.dart';
import 'package:findone/models/Appointment.dart';
import 'package:findone/models/ChatRoom.dart';
import 'package:findone/models/Doctor.dart';
import 'package:findone/models/Message.dart';
import 'package:findone/models/MedicalRecord.dart';
import 'package:findone/models/Prescription.dart';
import 'package:findone/models/Notification.dart';
import 'package:findone/models/File.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'findone.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        profile_picture TEXT,
        created_at TEXT,
        updated_at TEXT,
        status TEXT DEFAULT 'offline'
      );
    ''');
    await db.execute('''
      CREATE TABLE MedicalFacilities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT,
        city TEXT,
        state TEXT,
        postal_code TEXT,
        country TEXT,
        latitude REAL,
        longitude REAL,
        phone_number TEXT,
        email TEXT,
        photo_url TEXT,
        created_at TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE ChatRooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        created_at TEXT,
        type TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE Messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_room_id INTEGER,
        sender_id INTEGER,
        message_content TEXT,
        sent_at TEXT,
        message_type TEXT DEFAULT 'text',
        status TEXT DEFAULT 'sent',
        FOREIGN KEY(chat_room_id) REFERENCES ChatRooms(id),
        FOREIGN KEY(sender_id) REFERENCES Users(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE UserChatRoom (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        chat_room_id INTEGER,
        role TEXT DEFAULT 'member',
        FOREIGN KEY(user_id) REFERENCES Users(id),
        FOREIGN KEY(chat_room_id) REFERENCES ChatRooms(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE MedicalRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        record_type TEXT NOT NULL,
        data TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(user_id) REFERENCES Users(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE Appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        doctor_id INTEGER,
        facility_id INTEGER,
        appointment_date TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY(user_id) REFERENCES Users(id),
        FOREIGN KEY(doctor_id) REFERENCES Users(id),
        FOREIGN KEY(facility_id) REFERENCES MedicalFacilities(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE Notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        content TEXT,
        created_at TEXT,
        status TEXT DEFAULT 'unread',
        FOREIGN KEY(user_id) REFERENCES Users(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE Files (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uploaded_by INTEGER,
        chat_room_id INTEGER,
        file_url TEXT NOT NULL,
        uploaded_at TEXT,
        file_type TEXT NOT NULL,
        FOREIGN KEY(uploaded_by) REFERENCES Users(id),
        FOREIGN KEY(chat_room_id) REFERENCES ChatRooms(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE Doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        specialization TEXT NOT NULL,
        experience_years INTEGER CHECK (experience_years >= 0),
        bio TEXT,
        FOREIGN KEY(user_id) REFERENCES Users(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE Prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        doctor_id INTEGER,
        medication TEXT NOT NULL,
        instructions TEXT,
        issued_at TEXT,
        FOREIGN KEY(user_id) REFERENCES Users(id),
        FOREIGN KEY(doctor_id) REFERENCES Doctors(id)
      );
    ''');
  }

  // Méthode générique pour insertion
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  // Méthode générique pour sélection
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }

  // Méthode générique pour mise à jour
  Future<int> update(String table, Map<String, dynamic> values, String where,
      List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // Méthode générique pour suppression
  Future<int> delete(
      String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Méthodes spécifiques pour chaque modèle

  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert(
      'Users',
      user.toMap(), // Convertir User en Map ici
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async =>
      await queryAllRows('Users');
  Future<int> updateUser(User user) async =>
      await update('Users', user.toMap(), 'id = ?', [user.id]);
  Future<int> deleteUser(int id) async => await delete('Users', 'id = ?', [id]);

  Future<int> insertMedicalFacility(MedicalFacility facility) async =>
      await insert('MedicalFacilities', facility.toJson());
  Future<List<Map<String, dynamic>>> getAllMedicalFacilities() async =>
      await queryAllRows('MedicalFacilities');
  Future<int> updateMedicalFacility(MedicalFacility facility) async =>
      await update(
          'MedicalFacilities', facility.toJson(), 'id = ?', [facility.id]);
  Future<int> deleteMedicalFacility(int id) async =>
      await delete('MedicalFacilities', 'id = ?', [id]);

  Future<int> insertChatRoom(ChatRoom chatRoom) async =>
      await insert('ChatRooms', chatRoom.toJson());
  Future<List<Map<String, dynamic>>> getAllChatRooms() async =>
      await queryAllRows('ChatRooms');
  Future<int> updateChatRoom(ChatRoom chatRoom) async =>
      await update('ChatRooms', chatRoom.toJson(), 'id = ?', [chatRoom.id]);
  Future<int> deleteChatRoom(int id) async =>
      await delete('ChatRooms', 'id = ?', [id]);

  Future<int> insertMessage(Message message) async =>
      await insert('Messages', message.toJson());
  Future<List<Map<String, dynamic>>> getAllMessages() async =>
      await queryAllRows('Messages');
  Future<int> updateMessage(Message message) async =>
      await update('Messages', message.toJson(), 'id = ?', [message.id]);
  Future<int> deleteMessage(int id) async =>
      await delete('Messages', 'id = ?', [id]);

  Future<int> insertMedicalRecord(MedicalRecord record) async =>
      await insert('MedicalRecords', record.toJson());
  Future<List<Map<String, dynamic>>> getAllMedicalRecords() async =>
      await queryAllRows('MedicalRecords');
  Future<int> updateMedicalRecord(MedicalRecord record) async =>
      await update('MedicalRecords', record.toJson(), 'id = ?', [record.id]);
  Future<int> deleteMedicalRecord(int id) async =>
      await delete('MedicalRecords', 'id = ?', [id]);

  Future<int> insertAppointment(Appointment appointment) async =>
      await insert('Appointments', appointment.toJson());
  Future<List<Map<String, dynamic>>> getAllAppointments() async =>
      await queryAllRows('Appointments');
  Future<int> updateAppointment(Appointment appointment) async => await update(
      'Appointments', appointment.toJson(), 'id = ?', [appointment.id]);
  Future<int> deleteAppointment(int id) async =>
      await delete('Appointments', 'id = ?', [id]);

  Future<int> insertNotification(Notification notification) async =>
      await insert('Notifications', notification.toJson());
  Future<List<Map<String, dynamic>>> getAllNotifications() async =>
      await queryAllRows('Notifications');
  Future<int> updateNotification(Notification notification) async =>
      await update(
          'Notifications', notification.toJson(), 'id = ?', [notification.id]);
  Future<int> deleteNotification(int id) async =>
      await delete('Notifications', 'id = ?', [id]);

  Future<int> insertFile(File file) async =>
      await insert('Files', file.toJson());
  Future<List<Map<String, dynamic>>> getAllFiles() async =>
      await queryAllRows('Files');
  Future<int> updateFile(File file) async =>
      await update('Files', file.toJson(), 'id = ?', [file.id]);
  Future<int> deleteFile(int id) async => await delete('Files', 'id = ?', [id]);

  Future<int> insertDoctor(Doctor doctor) async =>
      await insert('Doctors', doctor.toJson());
  Future<List<Map<String, dynamic>>> getAllDoctors() async =>
      await queryAllRows('Doctors');
  Future<int> updateDoctor(Doctor doctor) async =>
      await update('Doctors', doctor.toJson(), 'id = ?', [doctor.id]);
  Future<int> deleteDoctor(int id) async =>
      await delete('Doctors', 'id = ?', [id]);

  Future<int> insertPrescription(Prescription prescription) async =>
      await insert('Prescriptions', prescription.toJson());
  Future<List<Map<String, dynamic>>> getAllPrescriptions() async =>
      await queryAllRows('Prescriptions');
  Future<int> updatePrescription(Prescription prescription) async =>
      await update(
          'Prescriptions', prescription.toJson(), 'id = ?', [prescription.id]);
  Future<int> deletePrescription(int id) async =>
      await delete('Prescriptions', 'id = ?', [id]);

  // Méthode pour récupérer toutes les notifications hors ligne
  Future<List<Notification>> getOfflineNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Notifications');

    return List.generate(maps.length, (i) {
      return Notification.fromJson(maps[i]);
    });
  }

  Future<Map<String, dynamic>?> getUserInfo(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first; // Retourner les informations de l'utilisateur
    } else {
      return null; // Aucun utilisateur trouvé
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String useremail) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? ',
      whereArgs: [useremail],
    );

    if (result.isNotEmpty) {
      return result.first; // Retourner les informations de l'utilisateur
    } else {
      return null; // Aucun utilisateur trouvé
    }
  }

  Future<Map<String, dynamic>?> getFirstUser() async {
    final db = await database;

    // Exécute une requête pour récupérer le premier utilisateur
    final List<Map<String, dynamic>> result = await db.query('users',
        limit: 1 // Récupère uniquement le premier enregistrement
        );

    if (result.isNotEmpty) {
      return result.first; // Retourne les informations du premier utilisateur
    } else {
      return null; // Aucun utilisateur trouvé
    }
  }

  // Méthode pour supprimer tous les utilisateurs
  Future<int> deleteAllUsers() async {
    Database db = await database;
    return await db.delete('users');
  }
}
