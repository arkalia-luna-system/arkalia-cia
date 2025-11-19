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
}

