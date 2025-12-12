import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/pathology.dart';
import '../models/pathology_tracking.dart';
import '../utils/error_helper.dart';
import '../utils/storage_helper.dart';
import 'calendar_service.dart';
import 'pathology_color_service.dart';
import 'pathology_category_service.dart';

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
        version: 4,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 4) {
            // Migration : ajouter colonnes category et subcategory
            try {
              await db.execute('ALTER TABLE pathologies ADD COLUMN category TEXT');
              await db.execute('ALTER TABLE pathologies ADD COLUMN subcategory TEXT');
            } catch (e) {
              // Colonnes peuvent déjà exister, ignorer l'erreur
            }
            if (oldVersion < 3) {
              await _createTables(db);
            }
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
        category TEXT,
        subcategory TEXT,
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
      color: PathologyColorService.getColorForPathology('Endométriose'),
      category: PathologyCategoryService.getCategoryForPathology('Endométriose'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Endométriose'),
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
      color: PathologyColorService.getColorForPathology('Cancer'),
      category: PathologyCategoryService.getCategoryForPathology('Cancer'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Cancer'),
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
      color: PathologyColorService.getColorForPathology('Myélome'),
      category: PathologyCategoryService.getCategoryForPathology('Myélome'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Myélome'),
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
      color: PathologyColorService.getColorForPathology('Ostéoporose'),
      category: PathologyCategoryService.getCategoryForPathology('Ostéoporose'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Ostéoporose'),
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
      color: PathologyColorService.getColorForPathology('Arthrite'),
      category: PathologyCategoryService.getCategoryForPathology('Arthrite'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Arthrite'),
    );
  }

  /// Crée un template pour l'arthrite
  static Pathology createArthritisRheumatoidTemplate() {
    return Pathology(
      name: 'Arthrite rhumatoïde',
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
      color: PathologyColorService.getColorForPathology('Arthrite rhumatoïde'),
      category: PathologyCategoryService.getCategoryForPathology('Arthrite rhumatoïde'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Arthrite rhumatoïde'),
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
      color: PathologyColorService.getColorForPathology('Tendinite'),
      category: PathologyCategoryService.getCategoryForPathology('Tendinite'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Tendinite'),
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
      color: PathologyColorService.getColorForPathology('Spondylarthrite'),
      category: PathologyCategoryService.getCategoryForPathology('Spondylarthrite'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Spondylarthrite'),
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
      color: PathologyColorService.getColorForPathology('Parkinson'),
      category: PathologyCategoryService.getCategoryForPathology('Parkinson'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Parkinson'),
    );
  }

  /// Crée un template pour Alzheimer
  static Pathology createAlzheimerTemplate() {
    return Pathology(
      name: 'Alzheimer',
      description: 'Suivi de la maladie d\'Alzheimer avec mémoire et cognition',
      symptoms: [
        'Perte de mémoire',
        'Troubles du langage',
        'Désorientation',
        'Changements d\'humeur',
      ],
      treatments: [
        'Médicaments anticholinestérasiques',
        'Thérapie cognitive',
        'Activités stimulantes',
      ],
      exams: [
        'IRM cérébrale',
        'Tests neuropsychologiques',
        'Consultation neurologue',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Alzheimer'),
      category: PathologyCategoryService.getCategoryForPathology('Alzheimer'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Alzheimer'),
    );
  }

  /// Crée un template pour l'anémie
  static Pathology createAnemiaTemplate() {
    return Pathology(
      name: 'Anémie',
      description: 'Suivi de l\'anémie avec fatigue et carences',
      symptoms: [
        'Fatigue',
        'Pâleur',
        'Essoufflement',
        'Vertiges',
      ],
      treatments: [
        'Supplémentation en fer',
        'Vitamine B12',
        'Acide folique',
      ],
      exams: [
        'Numération formule sanguine',
        'Ferritine',
        'Vitamine B12',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00'],
        ),
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Anémie'),
      category: PathologyCategoryService.getCategoryForPathology('Anémie'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Anémie'),
    );
  }

  /// Crée un template pour l'asthme
  static Pathology createAsthmaTemplate() {
    return Pathology(
      name: 'Asthme',
      description: 'Suivi de l\'asthme avec crises et traitement de fond',
      symptoms: [
        'Essoufflement',
        'Sifflements',
        'Toux',
        'Oppression thoracique',
      ],
      treatments: [
        'Corticoïdes inhalés',
        'Bronchodilatateurs',
        'Traitement de crise',
      ],
      exams: [
        'Spirométrie',
        'Peak flow',
        'Tests allergologiques',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Asthme'),
      category: PathologyCategoryService.getCategoryForPathology('Asthme'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Asthme'),
    );
  }

  /// Crée un template pour le diabète
  static Pathology createDiabetesTemplate() {
    return Pathology(
      name: 'Diabète',
      description: 'Suivi du diabète avec glycémie et traitements',
      symptoms: [
        'Soif excessive',
        'Urination fréquente',
        'Fatigue',
        'Vision floue',
      ],
      treatments: [
        'Insuline',
        'Médicaments antidiabétiques',
        'Régime alimentaire',
      ],
      exams: [
        'Glycémie',
        'HbA1c',
        'Bilan rénal',
        'Examen des pieds',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '12:00', '18:00', '22:00'],
        ),
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Diabète'),
      category: PathologyCategoryService.getCategoryForPathology('Diabète'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Diabète'),
    );
  }

  /// Crée un template pour la dépression
  static Pathology createDepressionTemplate() {
    return Pathology(
      name: 'Dépression',
      description: 'Suivi de la dépression avec humeur et traitement',
      symptoms: [
        'Tristesse persistante',
        'Perte d\'intérêt',
        'Fatigue',
        'Troubles du sommeil',
      ],
      treatments: [
        'Antidépresseurs',
        'Psychothérapie',
        'Activité physique',
      ],
      exams: [
        'Consultation psychiatre',
        'Consultation psychologue',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'weekly',
          times: ['14:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Dépression'),
      category: PathologyCategoryService.getCategoryForPathology('Dépression'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Dépression'),
    );
  }

  /// Crée un template pour l'eczéma
  static Pathology createEczemaTemplate() {
    return Pathology(
      name: 'Eczéma',
      description: 'Suivi de l\'eczéma avec poussées et soins cutanés',
      symptoms: [
        'Démangeaisons',
        'Rougeurs',
        'Sécheresse cutanée',
        'Desquamation',
      ],
      treatments: [
        'Corticoïdes locaux',
        'Émollients',
        'Antihistaminiques',
      ],
      exams: [
        'Consultation dermatologue',
        'Tests allergologiques',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Eczéma'),
      category: PathologyCategoryService.getCategoryForPathology('Eczéma'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Eczéma'),
    );
  }

  /// Crée un template pour la fibromyalgie
  static Pathology createFibromyalgiaTemplate() {
    return Pathology(
      name: 'Fibromyalgie',
      description: 'Suivi de la fibromyalgie avec douleurs et fatigue',
      symptoms: [
        'Douleurs diffuses',
        'Fatigue chronique',
        'Troubles du sommeil',
        'Troubles cognitifs',
      ],
      treatments: [
        'Antalgiques',
        'Antidépresseurs',
        'Kinésithérapie',
      ],
      exams: [
        'Consultation rhumatologue',
        'Bilan douleur',
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
      color: PathologyColorService.getColorForPathology('Fibromyalgie'),
      category: PathologyCategoryService.getCategoryForPathology('Fibromyalgie'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Fibromyalgie'),
    );
  }

  /// Crée un template pour l'hypertension
  static Pathology createHypertensionTemplate() {
    return Pathology(
      name: 'Hypertension',
      description: 'Suivi de l\'hypertension artérielle avec tension et traitement',
      symptoms: [
        'Maux de tête',
        'Vertiges',
        'Palpitations',
      ],
      treatments: [
        'Inhibiteurs ACE',
        'Diurétiques',
        'Bêta-bloquants',
      ],
      exams: [
        'Mesure tension artérielle',
        'Électrocardiogramme',
        'Bilan rénal',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00'],
        ),
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Hypertension'),
      category: PathologyCategoryService.getCategoryForPathology('Hypertension'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Hypertension'),
    );
  }

  /// Crée un template pour l'hypothyroïdie
  static Pathology createHypothyroidismTemplate() {
    return Pathology(
      name: 'Hypothyroïdie',
      description: 'Suivi de l\'hypothyroïdie avec hormones et traitement',
      symptoms: [
        'Fatigue',
        'Prise de poids',
        'Frilosité',
        'Ralentissement',
      ],
      treatments: [
        'Lévothyroxine',
      ],
      exams: [
        'TSH',
        'T4 libre',
        'Consultation endocrinologue',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00'],
        ),
        'exam': ReminderConfig(
          type: 'exam',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Hypothyroïdie'),
      category: PathologyCategoryService.getCategoryForPathology('Hypothyroïdie'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Hypothyroïdie'),
    );
  }

  /// Crée un template pour la migraine
  static Pathology createMigraineTemplate() {
    return Pathology(
      name: 'Migraine',
      description: 'Suivi des migraines avec crises et traitements',
      symptoms: [
        'Maux de tête intenses',
        'Nausées',
        'Sensibilité à la lumière',
        'Aura visuelle',
      ],
      treatments: [
        'Triptans',
        'Antalgiques',
        'Traitement de fond',
      ],
      exams: [
        'Consultation neurologue',
        'IRM cérébrale',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Migraine'),
    );
  }

  /// Crée un template pour la polyarthrite rhumatoïde
  static Pathology createRheumatoidArthritisTemplate() {
    return Pathology(
      name: 'Polyarthrite rhumatoïde',
      description: 'Suivi de la polyarthrite rhumatoïde avec douleurs articulaires',
      symptoms: [
        'Douleurs articulaires',
        'Raideur matinale',
        'Gonflement',
        'Déformation',
      ],
      treatments: [
        'Traitements de fond',
        'Anti-inflammatoires',
        'Corticoïdes',
      ],
      exams: [
        'Radiographie',
        'Analyses sanguines',
        'Échographie articulaire',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Polyarthrite rhumatoïde'),
      category: PathologyCategoryService.getCategoryForPathology('Arthrite rhumatoïde'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Arthrite rhumatoïde'),
    );
  }

  /// Crée un template pour le psoriasis
  static Pathology createPsoriasisTemplate() {
    return Pathology(
      name: 'Psoriasis',
      description: 'Suivi du psoriasis avec poussées et traitements',
      symptoms: [
        'Plaques rouges',
        'Desquamation',
        'Démangeaisons',
        'Douleurs articulaires',
      ],
      treatments: [
        'Corticoïdes locaux',
        'Traitements systémiques',
        'Photothérapie',
      ],
      exams: [
        'Consultation dermatologue',
        'Bilan articulaire',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Psoriasis'),
      category: PathologyCategoryService.getCategoryForPathology('Psoriasis'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Psoriasis'),
    );
  }

  /// Crée un template pour le reflux gastro-œsophagien
  static Pathology createGerdTemplate() {
    return Pathology(
      name: 'Reflux gastro-œsophagien',
      description: 'Suivi du RGO avec brûlures et traitement',
      symptoms: [
        'Brûlures d\'estomac',
        'Régurgitations',
        'Douleurs thoraciques',
        'Toux chronique',
      ],
      treatments: [
        'Inhibiteurs de la pompe à protons',
        'Anti-H2',
        'Antiacides',
      ],
      exams: [
        'Endoscopie digestive',
        'pH-métrie',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Reflux gastro-œsophagien'),
      category: PathologyCategoryService.getCategoryForPathology('Reflux gastro-œsophagien'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Reflux gastro-œsophagien'),
    );
  }

  /// Crée un template pour la sclérose en plaques
  static Pathology createMultipleSclerosisTemplate() {
    return Pathology(
      name: 'Sclérose en plaques',
      description: 'Suivi de la sclérose en plaques avec poussées et traitement',
      symptoms: [
        'Troubles visuels',
        'Fatigue',
        'Troubles moteurs',
        'Troubles sensitifs',
      ],
      treatments: [
        'Traitements de fond',
        'Corticoïdes',
        'Kinésithérapie',
      ],
      exams: [
        'IRM cérébrale',
        'Ponction lombaire',
        'Consultation neurologue',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Sclérose en plaques'),
      category: PathologyCategoryService.getCategoryForPathology('Sclérose en plaques'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Sclérose en plaques'),
    );
  }

  /// Crée un template pour le syndrome du côlon irritable
  static Pathology createIbsTemplate() {
    return Pathology(
      name: 'Syndrome du côlon irritable',
      description: 'Suivi du syndrome du côlon irritable avec symptômes digestifs',
      symptoms: [
        'Douleurs abdominales',
        'Ballonnements',
        'Diarrhée',
        'Constipation',
      ],
      treatments: [
        'Régime alimentaire',
        'Probiotiques',
        'Antispasmodiques',
      ],
      exams: [
        'Consultation gastro-entérologue',
        'Coloscopie',
      ],
      reminders: {
        'medication': ReminderConfig(
          type: 'medication',
          frequency: 'daily',
          times: ['08:00', '20:00'],
        ),
        'consultation': ReminderConfig(
          type: 'consultation',
          frequency: 'monthly',
          times: ['09:00'],
        ),
      },
      color: PathologyColorService.getColorForPathology('Syndrome du côlon irritable'),
      category: PathologyCategoryService.getCategoryForPathology('Syndrome du côlon irritable'),
      subcategory: PathologyCategoryService.getSubcategoryForPathology('Syndrome du côlon irritable'),
    );
  }

  // === MÉTHODES DE GROUPEMENT ET FILTRAGE ===

  /// Groupe les pathologies par catégorie
  Future<Map<String, List<Pathology>>> getPathologiesByCategory() async {
    final allPathologies = await getAllPathologies();
    final grouped = <String, List<Pathology>>{};
    
    for (final pathology in allPathologies) {
      final category = pathology.category ?? 'Autres';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(pathology);
    }
    
    // Trier les pathologies dans chaque catégorie
    for (final category in grouped.keys) {
      grouped[category]!.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return grouped;
  }

  /// Filtre les pathologies par catégorie
  Future<List<Pathology>> getPathologiesByCategoryFilter(String? category) async {
    if (category == null) {
      return await getAllPathologies();
    }
    final allPathologies = await getAllPathologies();
    return allPathologies.where((p) => p.category == category).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Filtre les pathologies par sous-catégorie
  Future<List<Pathology>> getPathologiesBySubcategoryFilter(String? subcategory) async {
    if (subcategory == null) {
      return await getAllPathologies();
    }
    final allPathologies = await getAllPathologies();
    return allPathologies.where((p) => p.subcategory == subcategory).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Retourne toutes les catégories disponibles (avec compteur)
  Future<Map<String, int>> getCategoriesWithCount() async {
    final allPathologies = await getAllPathologies();
    final categories = <String, int>{};
    
    for (final pathology in allPathologies) {
      final category = pathology.category ?? 'Autres';
      categories[category] = (categories[category] ?? 0) + 1;
    }
    
    return categories;
  }

  /// Liste tous les templates disponibles (triés par ordre alphabétique)
  static List<Pathology> getAllTemplates() {
    final templates = [
      createAlzheimerTemplate(),
      createAnemiaTemplate(),
      createArthritisTemplate(),
      createArthritisRheumatoidTemplate(),
      createAsthmaTemplate(),
      createCancerTemplate(),
      createDepressionTemplate(),
      createDiabetesTemplate(),
      createEczemaTemplate(),
      createEndometriosisTemplate(),
      createFibromyalgiaTemplate(),
      createGerdTemplate(),
      createHypertensionTemplate(),
      createHypothyroidismTemplate(),
      createIbsTemplate(),
      createMigraineTemplate(),
      createMultipleSclerosisTemplate(),
      createMyelomaTemplate(),
      createOsteoporosisTemplate(),
      createParkinsonTemplate(),
      createPsoriasisTemplate(),
      createRheumatoidArthritisTemplate(),
      createSpondylitisTemplate(),
      createTendinitisTemplate(),
    ];
    
    // Trier par ordre alphabétique
    templates.sort((a, b) => a.name.compareTo(b.name));
    return templates;
  }
}

