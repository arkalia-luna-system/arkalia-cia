import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../utils/error_helper.dart';
import '../utils/storage_helper.dart';
import 'calendar_service.dart';
import 'notification_service.dart';

/// Service de gestion des médicaments et rappels
class MedicationService {
  static Database? _database;
  static const String _medicationsKey = 'medications_web';
  static const String _medicationTakenKey = 'medication_taken_web';

  Future<Database?> get database async {
    if (kIsWeb) return null; // Sur le web, on n'utilise pas SQLite
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite non disponible sur le web');
    }
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'arkalia_cia.db');

      return await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            await _createTables(db);
          }
        },
      );
    } catch (e) {
      ErrorHelper.logError('MedicationService._initDatabase', e);
      rethrow;
    }
  }

  Future<void> _createTables(Database db) async {
    // Table médicaments
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT DEFAULT 'daily',
        times TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        notes TEXT
      )
    ''');

    // Table prises de médicaments
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medication_taken (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        taken INTEGER DEFAULT 0,
        taken_at TEXT,
        FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE CASCADE,
        UNIQUE(medication_id, date, time)
      )
    ''');

    // Index pour recherche rapide
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_medications_name 
      ON medications(name)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_medication_taken_date 
      ON medication_taken(date)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_medication_taken_medication 
      ON medication_taken(medication_id)
    ''');
  }

  // CRUD Médicaments
  Future<int> insertMedication(Medication medication) async {
    if (kIsWeb) {
      final medications = await _getMedicationsFromStorage();
      final medicationMap = medication.toMap();
      if (medicationMap['id'] == null) {
        medicationMap['id'] = DateTime.now().millisecondsSinceEpoch;
      }
      medications.add(medicationMap);
      await StorageHelper.saveList(_medicationsKey, medications);
      final id = medicationMap['id'] as int;
      // Programmer les rappels
      await scheduleReminders(medication.copyWith(id: id));
      return id;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final id = await db.insert('medications', medication.toMap());
    // Programmer les rappels
    await scheduleReminders(medication.copyWith(id: id));
    return id;
  }

  Future<List<Medication>> getAllMedications() async {
    if (kIsWeb) {
      final medications = await _getMedicationsFromStorage();
      return medications.map((map) => Medication.fromMap(_convertWebMapToSqliteMap(map))).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<List<Medication>> getActiveMedications() async {
    if (kIsWeb) {
      final allMedications = await getAllMedications();
      final now = DateTime.now();
      return allMedications.where((med) {
        if (med.startDate.isAfter(now)) return false;
        if (med.endDate != null && med.endDate!.isBefore(now)) return false;
        return true;
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'start_date <= ? AND (end_date IS NULL OR end_date >= ?)',
      whereArgs: [now.toIso8601String(), now.toIso8601String()],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
  }

  Future<Medication?> getMedicationById(int id) async {
    if (kIsWeb) {
      final medications = await _getMedicationsFromStorage();
      final medicationMap = medications.firstWhere(
        (map) => map['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      if (medicationMap.isEmpty) return null;
      return Medication.fromMap(_convertWebMapToSqliteMap(medicationMap));
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Medication.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMedication(Medication medication) async {
    if (kIsWeb) {
      final medications = await _getMedicationsFromStorage();
      final index = medications.indexWhere((map) => map['id'] == medication.id);
      if (index == -1) return 0;
      medications[index] = medication.toMap();
      await StorageHelper.saveList(_medicationsKey, medications);
      // Reprogrammer les rappels
      await scheduleReminders(medication);
      return 1;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final result = await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
    // Reprogrammer les rappels
    await scheduleReminders(medication);
    return result;
  }

  Future<int> deleteMedication(int id) async {
    // Annuler les notifications avant suppression
    await cancelMedicationNotifications(id);
    
    if (kIsWeb) {
      final medications = await _getMedicationsFromStorage();
      medications.removeWhere((map) => map['id'] == id);
      await StorageHelper.saveList(_medicationsKey, medications);
      // Supprimer aussi les prises associées
      final taken = await _getMedicationTakenFromStorage();
      taken.removeWhere((map) => map['medication_id'] == id);
      await StorageHelper.saveList(_medicationTakenKey, taken);
      return 1;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes helper pour le stockage web
  Future<List<Map<String, dynamic>>> _getMedicationsFromStorage() async {
    return await StorageHelper.getList(_medicationsKey);
  }

  Future<List<Map<String, dynamic>>> _getMedicationTakenFromStorage() async {
    return await StorageHelper.getList(_medicationTakenKey);
  }

  // Convertit le format web vers format SQLite
  Map<String, dynamic> _convertWebMapToSqliteMap(Map<String, dynamic> map) {
    final converted = Map<String, dynamic>.from(map);
    if (converted['id'] != null) {
      converted['id'] = converted['id'] is int 
          ? converted['id'] 
          : int.tryParse(converted['id'].toString()) ?? converted['id'];
    }
    return converted;
  }

  /// Programme les rappels pour un médicament
  Future<void> scheduleReminders(Medication medication) async {
    if (medication.id == null) return;

    final now = DateTime.now();
    final startDate = medication.startDate.isBefore(now) ? now : medication.startDate;
    // final endDate = medication.endDate ?? startDate.add(const Duration(days: 365));

    for (final time in medication.times) {
      // Créer le premier rappel
      final firstReminderDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        time.hour,
        time.minute,
      );

      if (firstReminderDate.isAfter(now)) {
        await CalendarService.addReminder(
          title: '💊 ${medication.name}',
          description: medication.dosage != null
              ? 'Dosage: ${medication.dosage}'
              : 'N\'oubliez pas votre médicament',
          reminderDate: firstReminderDate,
          recurrence: 'daily',
        );
        
        // Programmer aussi une notification push pour rappel
        await NotificationService.scheduleNotification(
          id: medication.id! * 1000 + time.hour * 60 + time.minute, // ID unique
          title: '💊 ${medication.name}',
          body: medication.dosage != null
              ? 'Dosage: ${medication.dosage}'
              : 'N\'oubliez pas votre médicament',
          scheduledDate: firstReminderDate,
        );
      }

      // Programmer rappels adaptatifs si non pris (30min après)
      // Ceci sera géré par la méthode markAsTaken
    }
  }

  /// Annule les notifications d'un médicament supprimé
  Future<void> cancelMedicationNotifications(int medicationId) async {
    final medication = await getMedicationById(medicationId);
    if (medication == null) return;
    
    // Annuler toutes les notifications pour ce médicament
    for (final time in medication.times) {
      final notificationId = medicationId * 1000 + time.hour * 60 + time.minute;
      await NotificationService.cancelNotification(notificationId);
    }
  }

  /// Marque un médicament comme pris
  Future<void> markAsTaken(int medicationId, DateTime date, TimeOfDay time) async {
    if (kIsWeb) {
      final taken = await _getMedicationTakenFromStorage();
      final dateStr = date.toIso8601String().split('T')[0];
      final timeStr = '${time.hour}:${time.minute}';
      
      final existingIndex = taken.indexWhere(
        (map) => map['medication_id'] == medicationId && 
                 map['date'] == dateStr && 
                 map['time'] == timeStr,
      );
      
      if (existingIndex != -1) {
        taken[existingIndex]['taken'] = 1;
        taken[existingIndex]['taken_at'] = DateTime.now().toIso8601String();
      } else {
        final entry = MedicationTaken(
          medicationId: medicationId,
          date: date,
          time: time,
          taken: true,
          takenAt: DateTime.now(),
        );
        final entryMap = entry.toMap();
        if (entryMap['id'] == null) {
          entryMap['id'] = DateTime.now().millisecondsSinceEpoch;
        }
        taken.add(entryMap);
      }
      await StorageHelper.saveList(_medicationTakenKey, taken);
      return;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final dateStr = date.toIso8601String().split('T')[0];
    final timeStr = '${time.hour}:${time.minute}';

    // Vérifier si l'entrée existe déjà
    final existing = await db.query(
      'medication_taken',
      where: 'medication_id = ? AND date = ? AND time = ?',
      whereArgs: [medicationId, dateStr, timeStr],
    );

    if (existing.isNotEmpty) {
      // Mettre à jour
      await db.update(
        'medication_taken',
        {
          'taken': 1,
          'taken_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Créer nouvelle entrée
      final entry = MedicationTaken(
        medicationId: medicationId,
        date: date,
        time: time,
        taken: true,
        takenAt: DateTime.now(),
      );
      await db.insert('medication_taken', entry.toMap());
    }
  }

  /// Obtient les médicaments non pris pour une date donnée
  Future<List<Map<String, dynamic>>> getMissedDoses(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final activeMedications = await getActiveMedications();
    final missed = <Map<String, dynamic>>[];

    if (kIsWeb) {
      final taken = await _getMedicationTakenFromStorage();
      for (final medication in activeMedications) {
        if (!medication.isActiveOnDate(date)) continue;

        for (final time in medication.times) {
          final timeStr = '${time.hour}:${time.minute}';
          final wasTaken = taken.any(
            (map) => map['medication_id'] == medication.id &&
                     map['date'] == dateStr &&
                     map['time'] == timeStr &&
                     map['taken'] == 1,
          );

          if (!wasTaken) {
            final reminderTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );

            if (reminderTime.isBefore(DateTime.now())) {
              missed.add({
                'medication': medication,
                'time': time,
                'reminder_time': reminderTime,
              });
            }
          }
        }
      }
      return missed;
    }

    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    for (final medication in activeMedications) {
      if (!medication.isActiveOnDate(date)) continue;

      for (final time in medication.times) {
        // Vérifier si pris
        final taken = await db.query(
          'medication_taken',
          where: 'medication_id = ? AND date = ? AND time = ? AND taken = 1',
          whereArgs: [medication.id, dateStr, '${time.hour}:${time.minute}'],
        );

        if (taken.isEmpty) {
          // Vérifier si l'heure est passée
          final reminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (reminderTime.isBefore(DateTime.now())) {
            missed.add({
              'medication': medication,
              'time': time,
              'reminder_time': reminderTime,
            });
          }
        }
      }
    }

    return missed;
  }

  /// Vérifie les interactions entre médicaments (basique)
  Future<List<String>> checkInteractions(List<Medication> medications) async {
    final warnings = <String>[];

    // Liste de médicaments connus avec interactions
    final interactionMap = {
      'aspirine': ['anticoagulant', 'ibuprofène'],
      'anticoagulant': ['aspirine', 'ibuprofène'],
      'ibuprofène': ['aspirine', 'anticoagulant'],
    };

    final medicationNames = medications.map((m) => m.name.toLowerCase()).toList();

    for (final medication in medications) {
      final name = medication.name.toLowerCase();
      if (interactionMap.containsKey(name)) {
        final conflicting = interactionMap[name]!;
        for (final conflict in conflicting) {
          if (medicationNames.contains(conflict)) {
            warnings.add(
              '⚠️ Interaction possible entre ${medication.name} et $conflict. '
              'Consultez votre médecin.',
            );
          }
        }
      }
    }

    return warnings;
  }

  /// Obtient le suivi de prise pour une période
  Future<Map<String, dynamic>> getMedicationTracking(
    int medicationId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (kIsWeb) {
      final taken = await _getMedicationTakenFromStorage();
      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];
      
      final filtered = taken.where((map) {
        final date = map['date'] as String?;
        return map['medication_id'] == medicationId &&
               date != null &&
               date >= startStr &&
               date <= endStr;
      }).toList();

      final takenCount = filtered.where((m) => m['taken'] == 1).length;
      final total = filtered.length;

      return {
        'taken': takenCount,
        'total': total,
        'percentage': total > 0 ? (takenCount / total * 100).round() : 0,
        'entries': filtered.map((m) => MedicationTaken.fromMap(_convertWebMapToSqliteMap(m))).toList(),
      };
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final maps = await db.query(
      'medication_taken',
      where: 'medication_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        medicationId,
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
    );

    final taken = maps.where((m) => m['taken'] == 1).length;
    final total = maps.length;

    return {
      'taken': taken,
      'total': total,
      'percentage': total > 0 ? (taken / total * 100).round() : 0,
      'entries': maps.map((m) => MedicationTaken.fromMap(m)).toList(),
    };
  }
}

