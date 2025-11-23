import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/doctor.dart';

class DoctorService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'arkalia_cia.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTables(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Table médecins
    await db.execute('''
      CREATE TABLE IF NOT EXISTS doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        specialty TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        postal_code TEXT,
        country TEXT DEFAULT 'Belgique',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table consultations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS consultations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctor_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        reason TEXT,
        notes TEXT,
        documents TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
      )
    ''');

    // Index pour recherche rapide
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_doctors_name 
      ON doctors(last_name, first_name)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_doctors_specialty 
      ON doctors(specialty)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_consultations_doctor 
      ON consultations(doctor_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_consultations_date 
      ON consultations(date)
    ''');
  }

  // CRUD Médecins
  Future<int> insertDoctor(Doctor doctor) async {
    final db = await database;
    return await db.insert('doctors', doctor.toMap());
  }

  Future<List<Doctor>> getAllDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      orderBy: 'last_name ASC, first_name ASC',
    );
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<Doctor?> getDoctorById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Doctor.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Doctor>> searchDoctors(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'last_name LIKE ? OR first_name LIKE ? OR specialty LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'last_name ASC',
    );
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'specialty = ?',
      whereArgs: [specialty],
      orderBy: 'last_name ASC',
    );
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await database;
    final updatedDoctor = doctor.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'doctors',
      updatedDoctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await database;
    // Supprimer aussi les consultations associées (CASCADE)
    return await db.delete(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Consultations
  Future<int> insertConsultation(Consultation consultation) async {
    final db = await database;
    return await db.insert('consultations', consultation.toMap());
  }

  Future<List<Consultation>> getConsultationsByDoctor(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'consultations',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Consultation.fromMap(maps[i]));
  }

  /// Trouve des médecins similaires (détection de doublons)
  /// Compare nom + spécialité avec tolérance aux variations d'orthographe
  Future<List<Doctor>> findSimilarDoctors(Doctor doctor) async {
    final allDoctors = await getAllDoctors();
    
    final similarDoctors = <Doctor>[];
    
    for (final existingDoctor in allDoctors) {
      // Ignorer le même médecin
      if (existingDoctor.id == doctor.id) {
        continue;
      }
      
      // Comparer les noms (tolérance aux variations)
      final nameSimilarity = _calculateNameSimilarity(
        doctor.fullName.toLowerCase(),
        existingDoctor.fullName.toLowerCase(),
      );
      
      // Comparer les spécialités si présentes
      bool specialtyMatch = false;
      if (doctor.specialty != null && existingDoctor.specialty != null) {
        final specialtySimilarity = _calculateNameSimilarity(
          doctor.specialty!.toLowerCase(),
          existingDoctor.specialty!.toLowerCase(),
        );
        specialtyMatch = specialtySimilarity > 0.7;
      }
      
      // Si nom très similaire (>80%) ou nom similaire (>60%) + spécialité identique
      if (nameSimilarity > 0.8 || (nameSimilarity > 0.6 && specialtyMatch)) {
        similarDoctors.add(existingDoctor);
      }
    }
    
    return similarDoctors;
  }
  
  /// Calcule la similarité entre deux chaînes (algorithme simple)
  double _calculateNameSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;
    if (str1.isEmpty || str2.isEmpty) return 0.0;
    
    // Vérifier si l'un contient l'autre
    if (str1.contains(str2) || str2.contains(str1)) {
      return 0.9;
    }
    
    // Comparer les mots
    final words1 = str1.split(' ').where((w) => w.isNotEmpty).toList();
    final words2 = str2.split(' ').where((w) => w.isNotEmpty).toList();
    
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    int commonWords = 0;
    for (final word1 in words1) {
      for (final word2 in words2) {
        if (word1 == word2 || word1.contains(word2) || word2.contains(word1)) {
          commonWords++;
          break;
        }
      }
    }
    
    final maxWords = words1.length > words2.length ? words1.length : words2.length;
    return commonWords / maxWords;
  }

  Future<Map<String, dynamic>> getDoctorStats(int doctorId) async {
    final db = await database;
    
    // Nombre consultations
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM consultations WHERE doctor_id = ?',
      [doctorId],
    );
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    
    // Dernière consultation
    final lastResult = await db.query(
      'consultations',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'date DESC',
      limit: 1,
    );
    
    DateTime? lastVisit;
    if (lastResult.isNotEmpty) {
      lastVisit = DateTime.parse(lastResult.first['date'] as String);
    }
    
    return {
      'consultation_count': count,
      'last_visit': lastVisit?.toIso8601String(),
    };
  }

  /// Exporte tous les médecins au format JSON
  Future<String> exportDoctors() async {
    final doctors = await getAllDoctors();
    final consultations = <int, List<Consultation>>{};
    
    for (final doctor in doctors) {
      if (doctor.id != null) {
        consultations[doctor.id!] = await getConsultationsByDoctor(doctor.id!);
      }
    }
    
    final exportData = {
      'version': '1.0',
      'export_date': DateTime.now().toIso8601String(),
      'doctors': doctors.map((d) => d.toMap()).toList(),
      'consultations': consultations.entries.map((e) => {
        'doctor_id': e.key,
        'consultations': e.value.map((c) => c.toMap()).toList(),
      }).toList(),
    };
    
    return jsonEncode(exportData);
  }

  /// Importe des médecins depuis un JSON
  Future<void> importDoctors(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final doctorsData = data['doctors'] as List<dynamic>? ?? [];
      final consultationsData = data['consultations'] as List<dynamic>? ?? [];
      
      // Importer médecins
      for (final doctorMap in doctorsData) {
        final doctor = Doctor.fromMap(Map<String, dynamic>.from(doctorMap));
        // Ne pas utiliser l'ID existant pour éviter conflits
        final newDoctor = Doctor(
          firstName: doctor.firstName,
          lastName: doctor.lastName,
          specialty: doctor.specialty,
          phone: doctor.phone,
          email: doctor.email,
          address: doctor.address,
          city: doctor.city,
          postalCode: doctor.postalCode,
          country: doctor.country,
          notes: doctor.notes,
        );
        final newId = await insertDoctor(newDoctor);
        
        // Importer consultations pour ce médecin
        final doctorConsultations = consultationsData.firstWhere(
          (c) => c['doctor_id'] == (doctorMap['id'] as int?),
          orElse: () => <String, dynamic>{},
        );
        
        if (doctorConsultations.isNotEmpty && newId != 0) {
          final consultations = (doctorConsultations['consultations'] as List<dynamic>? ?? [])
              .map((c) {
                final consultationMap = Map<String, dynamic>.from(c);
                consultationMap['doctor_id'] = newId; // Utiliser le nouvel ID
                return Consultation.fromMap(consultationMap);
              })
              .toList();
          
          for (final consultation in consultations) {
            await insertConsultation(consultation);
          }
        }
      }
    } catch (e) {
      throw Exception('Erreur import médecins: $e');
    }
  }
}

