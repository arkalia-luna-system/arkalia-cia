import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/pathology.dart';
import '../models/pathology_tracking.dart';
import '../utils/error_helper.dart';
import '../utils/storage_helper.dart';
import 'calendar_service.dart';

/// Service de gestion des pathologies et de leur suivi
class PathologyService {
  static Database? _database;
  static const String _pathologiesKey = 'pathologies_web';
  static const String _pathologyTrackingKey = 'pathology_tracking_web';

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
      ErrorHelper.logError('PathologyService._initDatabase', e);
      rethrow;
    }
  }

  Future<void> _createTables(Database db) async {
    // Table pathologies
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pathologies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        symptoms TEXT,
        treatments TEXT,
        exams TEXT,
        reminders TEXT,
        color INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table tracking entries
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pathology_tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pathology_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        data TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (pathology_id) REFERENCES pathologies(id) ON DELETE CASCADE
      )
    ''');

    // Index pour recherche rapide
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_pathologies_name 
      ON pathologies(name)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tracking_pathology 
      ON pathology_tracking(pathology_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_tracking_date 
      ON pathology_tracking(date)
    ''');
  }

  // === CRUD PATHOLOGIES ===

  Future<int> insertPathology(Pathology pathology) async {
    if (kIsWeb) {
      final pathologies = await _getPathologiesFromStorage();
      final remindersJson = jsonEncode(
        pathology.reminders.map((key, value) => MapEntry(key, value.toMap())),
      );
      final map = pathology.toMap();
      map['reminders'] = remindersJson;
      if (map['id'] == null) {
        map['id'] = DateTime.now().millisecondsSinceEpoch;
      }
      pathologies.add(map);
      await StorageHelper.saveList(_pathologiesKey, pathologies);
      return map['id'] as int;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final remindersJson = jsonEncode(
      pathology.reminders.map((key, value) => MapEntry(key, value.toMap())),
    );
    final map = pathology.toMap();
    map['reminders'] = remindersJson;
    return await db.insert('pathologies', map);
  }

  Future<List<Pathology>> getAllPathologies() async {
    if (kIsWeb) {
      final pathologies = await _getPathologiesFromStorage();
      return pathologies.map((map) {
        try {
          final converted = _convertWebMapToSqliteMap(map);
          // Pathology.fromMap() gère maintenant les reminders en String JSON ou Map
          return Pathology.fromMap(converted);
        } catch (e) {
          // En cas d'erreur, retourner une pathologie vide plutôt que de planter
          return Pathology(
            id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
            name: map['name']?.toString() ?? 'Pathologie inconnue',
            description: map['description']?.toString(),
            reminders: {},
          );
        }
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'pathologies',
      orderBy: 'name ASC',
    );
    return maps.map((map) {
      // Parser les reminders depuis JSON
      if (map['reminders'] != null) {
        try {
          final remindersData = jsonDecode(map['reminders'] as String) as Map<String, dynamic>;
          final reminders = <String, ReminderConfig>{};
          remindersData.forEach((key, value) {
            reminders[key] = ReminderConfig.fromMap(
              Map<String, dynamic>.from(value),
            );
          });
          map['reminders'] = reminders;
        } catch (e) {
          map['reminders'] = <String, ReminderConfig>{};
        }
      }
      return Pathology.fromMap(map);
    }).toList();
  }

  Future<Pathology?> getPathologyById(int id) async {
    if (kIsWeb) {
      final pathologies = await _getPathologiesFromStorage();
      final pathologyMap = pathologies.firstWhere(
        (map) {
          final mapId = map['id'];
          if (mapId is int) return mapId == id;
          if (mapId is String) return int.tryParse(mapId) == id;
          return mapId?.toString() == id.toString();
        },
        orElse: () => <String, dynamic>{},
      );
      if (pathologyMap.isEmpty) return null;
      try {
        final converted = _convertWebMapToSqliteMap(pathologyMap);
        // Pathology.fromMap() gère maintenant les reminders en String JSON ou Map
        return Pathology.fromMap(converted);
      } catch (e) {
        // En cas d'erreur, retourner null plutôt que de planter
        return null;
      }
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'pathologies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    // Parser les reminders depuis JSON
    if (map['reminders'] != null) {
      try {
        final remindersData = jsonDecode(map['reminders'] as String) as Map<String, dynamic>;
        final reminders = <String, ReminderConfig>{};
        remindersData.forEach((key, value) {
          reminders[key] = ReminderConfig.fromMap(
            Map<String, dynamic>.from(value),
          );
        });
        map['reminders'] = reminders;
      } catch (e) {
        map['reminders'] = <String, ReminderConfig>{};
      }
    }
    return Pathology.fromMap(map);
  }

  Future<int> updatePathology(Pathology pathology) async {
    if (kIsWeb) {
      final pathologies = await _getPathologiesFromStorage();
      final index = pathologies.indexWhere((map) => map['id'] == pathology.id);
      if (index == -1) return 0;
      final updatedPathology = pathology.copyWith(updatedAt: DateTime.now());
      final remindersJson = jsonEncode(
        updatedPathology.reminders.map((key, value) => MapEntry(key, value.toMap())),
      );
      final map = updatedPathology.toMap();
      map['reminders'] = remindersJson;
      pathologies[index] = map;
      await StorageHelper.saveList(_pathologiesKey, pathologies);
      return 1;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final updatedPathology = pathology.copyWith(updatedAt: DateTime.now());
    final remindersJson = jsonEncode(
      updatedPathology.reminders.map((key, value) => MapEntry(key, value.toMap())),
    );
    final map = updatedPathology.toMap();
    map['reminders'] = remindersJson;
    return await db.update(
      'pathologies',
      map,
      where: 'id = ?',
      whereArgs: [pathology.id],
    );
  }

  Future<int> deletePathology(int id) async {
    if (kIsWeb) {
      final pathologies = await _getPathologiesFromStorage();
      pathologies.removeWhere((map) => map['id'] == id);
      await StorageHelper.saveList(_pathologiesKey, pathologies);
      // Supprimer aussi les tracking associés
      final tracking = await _getPathologyTrackingFromStorage();
      tracking.removeWhere((map) => map['pathology_id'] == id);
      await StorageHelper.saveList(_pathologyTrackingKey, tracking);
      return 1;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    return await db.delete(
      'pathologies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes helper pour le stockage web
  Future<List<Map<String, dynamic>>> _getPathologiesFromStorage() async {
    return await StorageHelper.getList(_pathologiesKey);
  }

  Future<List<Map<String, dynamic>>> _getPathologyTrackingFromStorage() async {
    return await StorageHelper.getList(_pathologyTrackingKey);
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

  // === CRUD TRACKING ===

  Future<int> insertTracking(PathologyTracking tracking) async {
    if (kIsWeb) {
      final trackingList = await _getPathologyTrackingFromStorage();
      final map = tracking.toMap();
      map['data'] = jsonEncode(tracking.data);
      if (map['id'] == null) {
        map['id'] = DateTime.now().millisecondsSinceEpoch;
      }
      trackingList.add(map);
      await StorageHelper.saveList(_pathologyTrackingKey, trackingList);
      return map['id'] as int;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final map = tracking.toMap();
    map['data'] = jsonEncode(tracking.data);
    return await db.insert('pathology_tracking', map);
  }

  Future<List<PathologyTracking>> getTrackingByPathology(
    int pathologyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kIsWeb) {
      final tracking = await _getPathologyTrackingFromStorage();
      var filtered = tracking.where((map) => map['pathology_id'] == pathologyId).toList();
      
      if (startDate != null) {
        final startStr = startDate.toIso8601String();
        filtered = filtered.where((map) {
          final date = map['date'] as String?;
          return date != null && date.compareTo(startStr) >= 0;
        }).toList();
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String();
        filtered = filtered.where((map) {
          final date = map['date'] as String?;
          return date != null && date.compareTo(endStr) <= 0;
        }).toList();
      }
      
      filtered.sort((a, b) {
        final dateA = a['date'] as String? ?? '';
        final dateB = b['date'] as String? ?? '';
        return dateB.compareTo(dateA); // DESC
      });
      
      return filtered.map((map) {
        final converted = _convertWebMapToSqliteMap(map);
        // Parser data depuis JSON
        if (converted['data'] != null && converted['data'] is String) {
          try {
            converted['data'] = jsonDecode(converted['data'] as String);
          } catch (e) {
            converted['data'] = {};
          }
        }
        return PathologyTracking.fromMap(converted);
      }).toList();
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    String where = 'pathology_id = ?';
    List<dynamic> whereArgs = [pathologyId];

    if (startDate != null) {
      where += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'pathology_tracking',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) {
      // Parser data depuis JSON
      if (map['data'] != null) {
        try {
          map['data'] = jsonDecode(map['data'] as String);
        } catch (e) {
          map['data'] = {};
        }
      }
      return PathologyTracking.fromMap(map);
    }).toList();
  }

  Future<PathologyTracking?> getTrackingById(int id) async {
    if (kIsWeb) {
      final tracking = await _getPathologyTrackingFromStorage();
      final trackingMap = tracking.firstWhere(
        (map) => map['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      if (trackingMap.isEmpty) return null;
      final converted = _convertWebMapToSqliteMap(trackingMap);
      // Parser data depuis JSON
      if (converted['data'] != null && converted['data'] is String) {
        try {
          converted['data'] = jsonDecode(converted['data'] as String);
        } catch (e) {
          converted['data'] = {};
        }
      }
      return PathologyTracking.fromMap(converted);
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'pathology_tracking',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    
    final map = maps.first;
    // Parser data depuis JSON
    if (map['data'] != null) {
      try {
        map['data'] = jsonDecode(map['data'] as String);
      } catch (e) {
        map['data'] = {};
      }
    }
    return PathologyTracking.fromMap(map);
  }

  Future<int> updateTracking(PathologyTracking tracking) async {
    if (kIsWeb) {
      final trackingList = await _getPathologyTrackingFromStorage();
      final index = trackingList.indexWhere((map) => map['id'] == tracking.id);
      if (index == -1) return 0;
      final map = tracking.toMap();
      map['data'] = jsonEncode(tracking.data);
      trackingList[index] = map;
      await StorageHelper.saveList(_pathologyTrackingKey, trackingList);
      return 1;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    final map = tracking.toMap();
    map['data'] = jsonEncode(tracking.data);
    return await db.update(
      'pathology_tracking',
      map,
      where: 'id = ?',
      whereArgs: [tracking.id],
    );
  }

  Future<int> deleteTracking(int id) async {
    if (kIsWeb) {
      final tracking = await _getPathologyTrackingFromStorage();
      tracking.removeWhere((map) => map['id'] == id);
      await StorageHelper.saveList(_pathologyTrackingKey, tracking);
      return 1;
    }
    final db = await database;
    if (db == null) {
      throw UnsupportedError('Base de données non disponible');
    }
    return await db.delete(
      'pathology_tracking',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // === STATISTIQUES ===

  Future<Map<String, dynamic>> getPathologyStats(
    int pathologyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final tracking = await getTrackingByPathology(
      pathologyId,
      startDate: startDate,
      endDate: endDate,
    );

    if (tracking.isEmpty) {
      return {
        'total_entries': 0,
        'average_pain_level': 0.0,
        'symptoms_frequency': <String, int>{},
      };
    }

    // Calculer moyenne douleur si présent
    double totalPain = 0.0;
    int painCount = 0;
    final symptomsCount = <String, int>{};

    for (final entry in tracking) {
      // Douleur
      if (entry.data.containsKey('painLevel')) {
        final pain = entry.data['painLevel'];
        if (pain is int || pain is double) {
          totalPain += (pain as num).toDouble();
          painCount++;
        }
      }

      // Symptômes
      if (entry.data.containsKey('symptoms')) {
        final symptoms = entry.data['symptoms'];
        if (symptoms is List) {
          for (final symptom in symptoms) {
            final symptomStr = symptom.toString();
            symptomsCount[symptomStr] = (symptomsCount[symptomStr] ?? 0) + 1;
          }
        }
      }
    }

    return {
      'total_entries': tracking.length,
      'average_pain_level': painCount > 0 ? totalPain / painCount : 0.0,
      'symptoms_frequency': symptomsCount,
      'first_entry': tracking.last.date.toIso8601String(),
      'last_entry': tracking.first.date.toIso8601String(),
    };
  }

  // === RAPPELS ===

  Future<void> scheduleReminders(Pathology pathology) async {
    // Sur le web, CalendarService n'est pas disponible
    if (kIsWeb) {
      return;
    }
    
    for (final entry in pathology.reminders.entries) {
      final reminderConfig = entry.value;
      final title = '[Pathologie] ${pathology.name} - ${reminderConfig.type}';
      
      // Programmer les rappels selon la fréquence
      if (reminderConfig.times.isNotEmpty) {
        for (final timeStr in reminderConfig.times) {
          // Parser l'heure (format HH:mm)
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            final hour = int.tryParse(parts[0]) ?? 8;
            final minute = int.tryParse(parts[1]) ?? 0;
            final now = DateTime.now();
            var reminderDate = DateTime(now.year, now.month, now.day, hour, minute);
            
            if (reminderDate.isBefore(now)) {
              reminderDate = reminderDate.add(const Duration(days: 1));
            }

            try {
              await CalendarService.addReminder(
                title: title,
                description: pathology.description ?? '',
                reminderDate: reminderDate,
                recurrence: reminderConfig.frequency == 'daily' ? 'daily' : null,
              );
            } catch (e) {
              // Ignorer les erreurs de calendrier
            }
          }
        }
      }
    }
  }

  // === TEMPLATES PRÉDÉFINIS ===

  /// Crée un template pour l'endométriose
  static Pathology createEndometriosisTemplate() {
    return Pathology(
      name: 'Endométriose',
      description: 'Suivi de l\'endométriose avec cycle, douleurs et saignements',
      symptoms: [
        'Douleurs pelviennes',
        'Règles douloureuses',
        'Saignements',
        'Fatigue',
      ],
      treatments: [
        'Hormonothérapie',
        'Chirurgie',
        'Antalgiques',
      ],
      exams: [
        'Échographie pelvienne',
        'IRM pelvienne',
        'Laparoscopie',
      ],
      reminders: {
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
        'cycle': ReminderConfig(
          type: 'cycle',
          frequency: 'monthly',
          times: ['08:00'],
        ),
      },
      color: Colors.pink,
    );
  }

  /// Crée un template pour le cancer
  static Pathology createCancerTemplate() {
    return Pathology(
      name: 'Cancer',
      description: 'Suivi des traitements et examens pour le cancer',
      symptoms: [
        'Fatigue',
        'Nausées',
        'Douleurs',
        'Perte d\'appétit',
      ],
      treatments: [
        'Chimiothérapie',
        'Radiothérapie',
        'Chirurgie',
      ],
      exams: [
        'Scanner',
        'IRM',
        'Biopsie',
        'Analyses sanguines',
      ],
      reminders: {
        'treatment': ReminderConfig(
          type: 'treatment',
          frequency: 'weekly',
          times: ['08:00'],
        ),
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: Colors.red,
    );
  }

  /// Crée un template pour le myélome
  static Pathology createMyelomaTemplate() {
    return Pathology(
      name: 'Myélome',
      description: 'Suivi du myélome avec analyses biologiques et douleurs osseuses',
      symptoms: [
        'Douleurs osseuses',
        'Fatigue',
        'Infections',
      ],
      treatments: [
        'Chimiothérapie',
        'Greffe',
      ],
      exams: [
        'IRM',
        'Biopsie médullaire',
        'Analyses sanguines',
      ],
      reminders: {
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
        'treatment': ReminderConfig(
          type: 'treatment',
          frequency: 'weekly',
          times: ['08:00'],
        ),
      },
      color: Colors.purple,
    );
  }

  /// Crée un template pour l'ostéoporose
  static Pathology createOsteoporosisTemplate() {
    return Pathology(
      name: 'Ostéoporose',
      description: 'Suivi de l\'ostéoporose avec activité physique et examens',
      symptoms: [
        'Douleurs',
        'Fractures',
      ],
      treatments: [
        'Biphosphonates',
        'Calcium',
        'Vitamine D',
      ],
      exams: [
        'Densitométrie osseuse',
      ],
      reminders: {
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'yearly',
          times: ['09:00'],
        ),
        'activity': ReminderConfig(
          type: 'activity',
          frequency: 'daily',
          times: ['10:00'],
        ),
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
      },
      color: Colors.grey,
    );
  }

  /// Crée un template pour l'arthrose
  static Pathology createArthritisTemplate() {
    return Pathology(
      name: 'Arthrose',
      description: 'Suivi de l\'arthrose avec douleurs articulaires et mobilité',
      symptoms: [
        'Douleurs articulaires',
        'Raideur',
        'Gonflement',
      ],
      treatments: [
        'Anti-inflammatoires',
        'Antalgiques',
        'Kinésithérapie',
      ],
      exams: [
        'Radiographie',
        'Échographie articulaire',
        'IRM',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'therapy': ReminderConfig(
          type: 'therapy',
          frequency: 'weekly',
          times: ['14:00'],
        ),
      },
      color: Colors.orange,
    );
  }

  /// Crée un template pour l'arthrite
  static Pathology createArthritisRheumatoidTemplate() {
    return Pathology(
      name: 'Arthrite',
      description: 'Suivi de l\'arthrite avec douleurs et traitements',
      symptoms: [
        'Douleurs articulaires',
        'Raideur',
        'Gonflement',
      ],
      treatments: [
        'Anti-inflammatoires',
        'Traitements de fond',
        'Kinésithérapie',
      ],
      exams: [
        'Radiographie',
        'Échographie articulaire',
        'IRM',
        'Analyses sanguines',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'therapy': ReminderConfig(
          type: 'therapy',
          frequency: 'weekly',
          times: ['14:00'],
        ),
      },
      color: Colors.deepOrange,
    );
  }

  /// Crée un template pour la tendinite
  static Pathology createTendinitisTemplate() {
    return Pathology(
      name: 'Tendinite',
      description: 'Suivi de la tendinite avec douleurs et rééducation',
      symptoms: [
        'Douleurs articulaires',
        'Raideur',
        'Gonflement',
      ],
      treatments: [
        'Anti-inflammatoires',
        'Repos',
        'Kinésithérapie',
      ],
      exams: [
        'Échographie articulaire',
        'IRM',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'therapy': ReminderConfig(
          type: 'therapy',
          frequency: 'weekly',
          times: ['14:00'],
        ),
      },
      color: Colors.amber,
    );
  }

  /// Crée un template pour la spondylarthrite
  static Pathology createSpondylitisTemplate() {
    return Pathology(
      name: 'Spondylarthrite',
      description: 'Suivi de la spondylarthrite avec douleurs et mobilité',
      symptoms: [
        'Douleurs articulaires',
        'Raideur',
        'Gonflement',
      ],
      treatments: [
        'Anti-inflammatoires',
        'Traitements de fond',
        'Kinésithérapie',
      ],
      exams: [
        'Radiographie',
        'IRM',
        'Analyses sanguines',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'therapy': ReminderConfig(
          type: 'therapy',
          frequency: 'weekly',
          times: ['14:00'],
        ),
      },
      color: Colors.brown,
    );
  }

  /// Crée un template pour Parkinson
  static Pathology createParkinsonTemplate() {
    return Pathology(
      name: 'Parkinson',
      description: 'Suivi de la maladie de Parkinson avec symptômes et médicaments',
      symptoms: [
        'Tremblements',
        'Rigidité',
        'Bradykinésie',
        'Troubles de l\'équilibre',
      ],
      treatments: [
        'Lévodopa',
        'Autres traitements',
      ],
      exams: [
        'Consultation neurologue',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '12:00', '18:00', '22:00'],
        ),
        'therapy': ReminderConfig(
          type: 'therapy',
          frequency: 'weekly',
          times: ['14:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: Colors.indigo,
    );
  }

  /// Liste tous les templates disponibles
  static List<Pathology> getAllTemplates() {
    return [
      createEndometriosisTemplate(),
      createCancerTemplate(),
      createMyelomaTemplate(),
      createOsteoporosisTemplate(),
      createArthritisTemplate(),
      createArthritisRheumatoidTemplate(),
      createTendinitisTemplate(),
      createSpondylitisTemplate(),
      createParkinsonTemplate(),
    ];
  }
}

