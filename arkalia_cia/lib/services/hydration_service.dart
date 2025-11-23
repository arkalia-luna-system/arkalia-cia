import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/hydration_tracking.dart';
import '../utils/error_helper.dart';
import 'calendar_service.dart';

/// Service de gestion de l'hydratation et rappels
class HydrationService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
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
      ErrorHelper.logError('HydrationService._initDatabase', e);
      if (kIsWeb) {
        throw Exception('Base de données non disponible sur le web. Utilisez le mode offline avec SharedPreferences.');
      }
      rethrow;
    }
  }

  Future<void> _createTables(Database db) async {
    // Table entrées hydratation
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hydration_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount INTEGER NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    // Table objectif hydratation
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hydration_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_goal INTEGER DEFAULT 2000,
        updated_at TEXT NOT NULL
      )
    ''');

    // Index pour recherche rapide
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_hydration_date 
      ON hydration_entries(date)
    ''');

    // Créer objectif par défaut si n'existe pas
    final existing = await db.query('hydration_goals');
    if (existing.isEmpty) {
      await db.insert('hydration_goals', HydrationGoal().toMap());
    }
  }

  // CRUD Entrées hydratation
  Future<int> insertHydrationEntry(HydrationEntry entry) async {
    final db = await database;
    return await db.insert('hydration_entries', entry.toMap());
  }

  Future<List<HydrationEntry>> getHydrationEntries(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'hydration_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'time ASC',
    );
    return List.generate(maps.length, (i) => HydrationEntry.fromMap(maps[i]));
  }

  Future<List<HydrationEntry>> getHydrationEntriesRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'hydration_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC, time ASC',
    );
    return List.generate(maps.length, (i) => HydrationEntry.fromMap(maps[i]));
  }

  Future<int> deleteHydrationEntry(int id) async {
    final db = await database;
    return await db.delete(
      'hydration_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Obtient la progression quotidienne
  Future<Map<String, dynamic>> getDailyProgress(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final goal = await getHydrationGoal();

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM hydration_entries WHERE date = ?',
      [dateStr],
    );

    final total = Sqflite.firstIntValue(result) ?? 0;
    final percentage = goal.dailyGoal > 0 ? (total / goal.dailyGoal * 100).round() : 0;
    final remaining = goal.dailyGoal - total;
    final glasses = (total / 250).round();

    return {
      'date': date,
      'total': total,
      'goal': goal.dailyGoal,
      'remaining': remaining > 0 ? remaining : 0,
      'percentage': percentage > 100 ? 100 : percentage,
      'glasses': glasses,
      'goal_glasses': goal.glasses,
      'is_goal_reached': total >= goal.dailyGoal,
    };
  }

  /// Enregistre une consommation
  Future<void> markAsDrank(int amount) async {
    final now = DateTime.now();
    final entry = HydrationEntry(
      date: now,
      amount: amount,
      time: now,
    );
    await insertHydrationEntry(entry);
  }

  /// Programme les rappels d'hydratation (toutes les 2h de 8h à 20h)
  Future<void> scheduleReminders() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Rappels de 8h à 20h, toutes les 2h
    for (int hour = 8; hour <= 20; hour += 2) {
      final reminderDate = DateTime(today.year, today.month, today.day, hour, 0);

      // Ne programmer que si l'heure n'est pas encore passée aujourd'hui
      if (reminderDate.isAfter(now)) {
        await CalendarService.addReminder(
          title: '💧 Hydratation',
          description: 'N\'oubliez pas de boire de l\'eau !',
          reminderDate: reminderDate,
          recurrence: 'daily',
        );
      }
    }
  }

  /// Vérifie si des rappels doivent être renforcés (si pas de prise enregistrée)
  Future<void> checkAndReinforceReminders() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final progress = await getDailyProgress(today);

    // Si moins de 25% de l'objectif atteint et on est après 14h, rappeler plus souvent
    if (progress['percentage'] as int < 25 && now.hour >= 14) {
      // Programmer un rappel supplémentaire dans 30 minutes
      final nextReminder = now.add(const Duration(minutes: 30));
      await CalendarService.scheduleNotification(
        title: '💧 Rappel hydratation',
        description: 'Vous n\'avez bu que ${progress['glasses']} verre(s) aujourd\'hui. '
            'Pensez à boire !',
        date: nextReminder,
      );
    }
  }

  // CRUD Objectif hydratation
  Future<HydrationGoal> getHydrationGoal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'hydration_goals',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HydrationGoal.fromMap(maps.first);
    }
    // Créer objectif par défaut
    final defaultGoal = HydrationGoal();
    await db.insert('hydration_goals', defaultGoal.toMap());
    return defaultGoal;
  }

  Future<void> updateHydrationGoal(HydrationGoal goal) async {
    final db = await database;
    await db.insert('hydration_goals', goal.toMap());
  }

  /// Obtient les statistiques sur une période
  Future<Map<String, dynamic>> getStatistics(DateTime startDate, DateTime endDate) async {
    final entries = await getHydrationEntriesRange(startDate, endDate);
    final goal = await getHydrationGoal();

    int totalAmount = 0;
    int daysWithEntries = 0;
    int daysGoalReached = 0;
    final dailyAmounts = <DateTime, int>{};

    for (final entry in entries) {
      totalAmount += entry.amount;
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyAmounts[date] = (dailyAmounts[date] ?? 0) + entry.amount;
    }

    daysWithEntries = dailyAmounts.length;
    for (final amount in dailyAmounts.values) {
      if (amount >= goal.dailyGoal) {
        daysGoalReached++;
      }
    }

    final averageDaily = daysWithEntries > 0 ? totalAmount ~/ daysWithEntries : 0;

    return {
      'total_amount': totalAmount,
      'average_daily': averageDaily,
      'days_with_entries': daysWithEntries,
      'days_goal_reached': daysGoalReached,
      'goal': goal.dailyGoal,
      'compliance_rate': daysWithEntries > 0
          ? (daysGoalReached / daysWithEntries * 100).round()
          : 0,
    };
  }
}

