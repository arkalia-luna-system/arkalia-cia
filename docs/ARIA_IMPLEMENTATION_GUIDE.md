# Guide d'implémentation ARIA — Arkalia CIA

**Version** : 1.3.1  
**Dernière mise à jour** : Janvier 2025  
**Statut** : Production Ready

Guide pratique pour implémenter l'intégration ARIA étape par étape avec tous les détails techniques.

---

## Table des matières

1. [Checklist d'implémentation](#checklist-dimplémentation)
2. [Jour 1 : Module ARIA dans CIA](#jour-1-module-aria-dans-cia)
3. [Jour 2 : Intégration Backend](#jour-2-intégration-backend)
4. [Jour 3 : Tests et validation](#jour-3-tests-et-validation)
5. [Dépannage](#dépannage)
6. [Bonnes pratiques](#bonnes-pratiques)
7. [Voir aussi](#voir-aussi)

---

## Voir aussi

- **[ARIA_IMPLEMENTATION_GUIDE.md](./ARIA_IMPLEMENTATION_GUIDE.md)** — Guide complet d'intégration ARIA
- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** — Documentation API complète
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — Architecture système
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

## 📋 Implementation Checklist

### **📱 JOUR 1 : MODULE ARIA DANS CIA**

#### **✅ Étape 1.1 : Créer PainTrackerScreen**
```bash
# Créer le fichier
touch /Volumes/T7/arkalia-cia/arkalia_cia/lib/screens/pain_tracker_screen.dart
```

**Code à implémenter** :
```dart
import 'package:flutter/material.dart';
import '../services/pain_data_service.dart';

class PainTrackerScreen extends StatefulWidget {
  const PainTrackerScreen({super.key});

  @override
  State<PainTrackerScreen> createState() => _PainTrackerScreenState();
}

class _PainTrackerScreenState extends State<PainTrackerScreen> {
  double _painLevel = 0.0;
  String _selectedTrigger = '';
  String _selectedLocation = '';
  String _selectedAction = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi Douleur'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Curseur douleur 0-10
            _buildPainSlider(),
            const SizedBox(height: 20),

            // Sélection déclencheur
            _buildTriggerSelector(),
            const SizedBox(height: 20),

            // Sélection localisation
            _buildLocationSelector(),
            const SizedBox(height: 20),

            // Sélection action
            _buildActionSelector(),
            const SizedBox(height: 30),

            // Bouton sauvegarder
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPainSlider() {
    return Column(
      children: [
        Text(
          'Niveau de douleur: ${_painLevel.round()}/10',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _painLevel,
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: (value) {
            setState(() {
              _painLevel = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTriggerSelector() {
    final triggers = ['Marche', 'Stress', 'Écran', 'Position', 'Autre'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Déclencheur:', style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          children: triggers.map((trigger) {
            return FilterChip(
              label: Text(trigger),
              selected: _selectedTrigger == trigger,
              onSelected: (selected) {
                setState(() {
                  _selectedTrigger = selected ? trigger : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    final locations = ['Épaule droite', 'Jambe gauche', 'Dos', 'Tête', 'Autre'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Localisation:', style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          children: locations.map((location) {
            return FilterChip(
              label: Text(location),
              selected: _selectedLocation == location,
              onSelected: (selected) {
                setState(() {
                  _selectedLocation = selected ? location : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionSelector() {
    final actions = ['Repos', 'Médicament', 'Chaleur', 'Respiration', 'Rien'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Action prise:', style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          children: actions.map((action) {
            return FilterChip(
              label: Text(action),
              selected: _selectedAction == action,
              onSelected: (selected) {
                setState(() {
                  _selectedAction = selected ? action : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePainEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Sauvegarder',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _savePainEntry() async {
    if (_selectedTrigger.isEmpty || _selectedLocation.isEmpty || _selectedAction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      await PainDataService.savePainEntry(
        intensity: _painLevel.round(),
        trigger: _selectedTrigger,
        location: _selectedLocation,
        action: _selectedAction,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrée sauvegardée !')),
      );

      // Reset form
      setState(() {
        _painLevel = 0.0;
        _selectedTrigger = '';
        _selectedLocation = '';
        _selectedAction = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
```

#### **✅ Étape 1.2 : Créer PainDataService**
```bash
# Créer le service
touch /Volumes/T7/arkalia-cia/arkalia_cia/lib/services/pain_data_service.dart
```

**Code à implémenter** :
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PainDataService {
  static const String _baseUrl = 'http://localhost:8000/api/health';

  static Future<void> savePainEntry({
    required int intensity,
    required String trigger,
    required String location,
    required String action,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pain-entry'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'intensity': intensity,
        'physical_trigger': trigger,
        'location': location,
        'action_taken': action,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la sauvegarde');
    }
  }

  static Future<List<Map<String, dynamic>>> getPainEntries() async {
    final response = await http.get(Uri.parse('$_baseUrl/pain-entries'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception('Erreur lors du chargement des données');
  }
}
```

#### **✅ Étape 1.3 : Créer API Backend**
```bash
# Créer l'API
touch /Volumes/T7/arkalia-cia/arkalia_cia_python_backend/pain_api.py
```

**Code à implémenter** :
```python
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional
import sqlite3
import os

router = APIRouter()

class PainEntry(BaseModel):
    intensity: int
    physical_trigger: str
    location: str
    action_taken: str
    notes: Optional[str] = None
    timestamp: Optional[str] = None

class PainEntryResponse(BaseModel):
    id: int
    intensity: int
    physical_trigger: str
    location: str
    action_taken: str
    notes: Optional[str]
    timestamp: str

def get_db_connection():
    """Connexion à la base de données"""
    db_path = os.path.join(os.path.dirname(__file__), 'arkalia_cia.db')
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def init_pain_tables():
    """Initialiser les tables santé"""
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS pain_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            intensity INTEGER NOT NULL CHECK (intensity >= 0 AND intensity <= 10),
            physical_trigger TEXT NOT NULL,
            location TEXT NOT NULL,
            action_taken TEXT NOT NULL,
            notes TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')

    conn.commit()
    conn.close()

@router.post("/pain-entry", response_model=PainEntryResponse)
async def create_pain_entry(entry: PainEntry):
    """Créer une nouvelle entrée douleur"""
    init_pain_tables()

    conn = get_db_connection()
    cursor = conn.cursor()

    timestamp = entry.timestamp or datetime.now().isoformat()

    cursor.execute('''
        INSERT INTO pain_entries
        (intensity, physical_trigger, location, action_taken, notes, timestamp)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (
        entry.intensity,
        entry.physical_trigger,
        entry.location,
        entry.action_taken,
        entry.notes,
        timestamp
    ))

    entry_id = cursor.lastrowid
    conn.commit()
    conn.close()

    return PainEntryResponse(
        id=entry_id,
        intensity=entry.intensity,
        physical_trigger=entry.physical_trigger,
        location=entry.location,
        action_taken=entry.action_taken,
        notes=entry.notes,
        timestamp=timestamp
    )

@router.get("/pain-entries", response_model=List[PainEntryResponse])
async def get_pain_entries():
    """Récupérer toutes les entrées douleur"""
    init_pain_tables()

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('''
        SELECT * FROM pain_entries
        ORDER BY timestamp DESC
    ''')

    entries = cursor.fetchall()
    conn.close()

    return [
        PainEntryResponse(
            id=row['id'],
            intensity=row['intensity'],
            physical_trigger=row['physical_trigger'],
            location=row['location'],
            action_taken=row['action_taken'],
            notes=row['notes'],
            timestamp=row['timestamp']
        )
        for row in entries
    ]

@router.get("/health/status")
async def health_status():
    """Statut du module santé"""
    return {
        "status": "healthy",
        "module": "dolorix",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat()
    }
```

#### **✅ Étape 1.4 : Intégrer dans HomePage**
**Modifier** `/Volumes/T7/arkalia-cia/arkalia_cia/lib/screens/home_page.dart` :

```dart
// Ajouter l'import
import 'pain_tracker_screen.dart';

// Ajouter le bouton dans la GridView
_buildActionButton(
  context,
  icon: MdiIcons.heartPulse,
  title: 'Santé+',
  subtitle: 'Suivi douleur',
  color: Colors.red,
  onTap: () => _showPainTracker(context),
),

// Ajouter la méthode
void _showPainTracker(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const PainTrackerScreen()),
  );
}
```

---

## 🎮 **JOUR 2 : GAMIFICATION QUEST INTEGRATION**

### **✅ Étape 2.1 : Créer HealthQuestService**
```bash
touch /Volumes/T7/arkalia-cia/arkalia_cia/lib/services/health_quest_service.dart
```

**Code à implémenter** :
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HealthQuestService {
  static const String _achievementsKey = 'health_achievements';
  static const String _xpKey = 'health_xp';
  static const String _levelKey = 'health_level';

  // Achievements santé
  static const Map<String, Map<String, dynamic>> achievements = {
    'scientist': {
      'name': 'Scientifique',
      'description': '7 jours de tracking complet',
      'icon': '🔬',
      'xp_reward': 100,
      'requirement': 7, // jours
    },
    'detective': {
      'name': 'Détective',
      'description': 'Découverte d\'un pattern personnel',
      'icon': '🕵️',
      'xp_reward': 150,
      'requirement': 1, // pattern
    },
    'warrior': {
      'name': 'Guerrier',
      'description': '30 jours de suivi continu',
      'icon': '⚔️',
      'xp_reward': 500,
      'requirement': 30, // jours
    },
    'researcher': {
      'name': 'Chercheuse',
      'description': 'Export de données pour analyse',
      'icon': '📊',
      'xp_reward': 200,
      'requirement': 1, // export
    },
  };

  static Future<void> addXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXP = prefs.getInt(_xpKey) ?? 0;
    final newXP = currentXP + xp;

    await prefs.setInt(_xpKey, newXP);

    // Vérifier niveau
    await _checkLevelUp(newXP);
  }

  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  static Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  static Future<List<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey) ?? '[]';
    return List<String>.from(jsonDecode(achievementsJson));
  }

  static Future<bool> unlockAchievement(String achievementId) async {
    final unlocked = await getUnlockedAchievements();

    if (unlocked.contains(achievementId)) {
      return false; // Déjà débloqué
    }

    final prefs = await SharedPreferences.getInstance();
    unlocked.add(achievementId);

    await prefs.setString(_achievementsKey, jsonEncode(unlocked));

    // Ajouter XP
    final achievement = achievements[achievementId];
    if (achievement != null) {
      await addXP(achievement['xp_reward']);
    }

    return true; // Nouvel achievement débloqué
  }

  static Future<void> _checkLevelUp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLevel = prefs.getInt(_levelKey) ?? 1;

    // Calculer nouveau niveau (100 XP par niveau)
    final newLevel = (xp ~/ 100) + 1;

    if (newLevel > currentLevel) {
      await prefs.setInt(_levelKey, newLevel);
      // TODO: Afficher notification level up
    }
  }

  static Future<bool> checkAchievementProgress(String achievementId) async {
    final achievement = achievements[achievementId];
    if (achievement == null) return false;

    final requirement = achievement['requirement'] as int;

    switch (achievementId) {
      case 'scientist':
        // Vérifier 7 jours de tracking
        return await _checkConsecutiveDays(requirement);
      case 'detective':
        // Vérifier découverte de pattern
        return await _checkPatternDiscovery();
      case 'warrior':
        // Vérifier 30 jours de suivi
        return await _checkConsecutiveDays(requirement);
      case 'researcher':
        // Vérifier export de données
        return await _checkDataExport();
      default:
        return false;
    }
  }

  static Future<bool> _checkConsecutiveDays(int requiredDays) async {
    // TODO: Implémenter vérification jours consécutifs
    return false;
  }

  static Future<bool> _checkPatternDiscovery() async {
    // TODO: Implémenter vérification découverte pattern
    return false;
  }

  static Future<bool> _checkDataExport() async {
    // TODO: Implémenter vérification export données
    return false;
  }
}
```

---

## 🤖 **JOUR 3 : IA PERSONNELLE ARIA**

### **✅ Étape 3.1 : Créer AriaHealthService**
```bash
touch /Volumes/T7/arkalia-cia/arkalia_cia/lib/services/aria_health_service.dart
```

**Code à implémenter** :
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AriaHealthService {
  static const String _baseUrl = 'http://localhost:8000/api/health/aria';

  // IA loyale qui travaille POUR toi
  static Future<Map<String, dynamic>> analyzePainPattern({
    required int intensity,
    required String trigger,
    required String location,
    required String action,
    String? emotion,
    String? weather,
    double? sleepHours,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/analyze-pattern'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'intensity': intensity,
        'trigger': trigger,
        'location': location,
        'action': action,
        'emotion': emotion,
        'weather': weather,
        'sleep_hours': sleepHours,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erreur analyse ARIA');
  }

  static Future<String> getPersonalizedInsight() async {
    final response = await http.get(Uri.parse('$_baseUrl/personal-insight'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['insight'] ?? 'Aucun insight disponible';
    }

    throw Exception('Erreur insight ARIA');
  }

  static Future<List<String>> getPredictiveAlerts() async {
    final response = await http.get(Uri.parse('$_baseUrl/predictive-alerts'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['alerts'] ?? []);
    }

    throw Exception('Erreur alertes ARIA');
  }

  static Future<Map<String, dynamic>> generatePsyReport({
    required String reportType, // 'light', 'medium', 'complete', 'focus'
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/psy-report'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'report_type': reportType,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erreur génération rapport');
  }
}
```

---

## 📊 **JOUR 4 : DASHBOARD PERSONNEL**

### **✅ Étape 4.1 : Créer PersonalHealthLabScreen**
```bash
touch /Volumes/T7/arkalia-cia/arkalia_cia/lib/screens/personal_health_lab_screen.dart
```

**Code à implémenter** :
```dart
import 'package:flutter/material.dart';
import '../services/pain_data_service.dart';
import '../services/health_quest_service.dart';
import '../services/aria_health_service.dart';

class PersonalHealthLabScreen extends StatefulWidget {
  const PersonalHealthLabScreen({super.key});

  @override
  State<PersonalHealthLabScreen> createState() => _PersonalHealthLabScreenState();
}

class _PersonalHealthLabScreenState extends State<PersonalHealthLabScreen> {
  List<Map<String, dynamic>> _painEntries = [];
  String _personalInsight = '';
  List<String> _predictiveAlerts = [];
  int _currentXP = 0;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final entries = await PainDataService.getPainEntries();
      final insight = await AriaHealthService.getPersonalInsight();
      final alerts = await AriaHealthService.getPredictiveAlerts();
      final xp = await HealthQuestService.getXP();
      final level = await HealthQuestService.getLevel();

      setState(() {
        _painEntries = entries;
        _personalInsight = insight;
        _predictiveAlerts = alerts;
        _currentXP = xp;
        _currentLevel = level;
      });
    } catch (e) {
      print('Erreur chargement données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Laboratoire Santé'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zone 1: Mes Données
            _buildDataZone(),
            const SizedBox(height: 20),

            // Zone 2: Mes Découvertes
            _buildDiscoveriesZone(),
            const SizedBox(height: 20),

            // Zone 3: Mes Prédictions
            _buildPredictionsZone(),
            const SizedBox(height: 20),

            // Zone 4: Mes Rapports
            _buildReportsZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataZone() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.data_usage, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Mes Données',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Total entrées: ${_painEntries.length}'),
            Text('XP actuel: $_currentXP'),
            Text('Niveau: $_currentLevel'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentXP % 100) / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveriesZone() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Mes Découvertes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _personalInsight.isNotEmpty
                ? _personalInsight
                : 'ARIA analyse tes patterns...',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsZone() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Mes Prédictions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_predictiveAlerts.isEmpty)
              const Text('Aucune alerte prédictive pour le moment')
            else
              ..._predictiveAlerts.map((alert) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('• $alert'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsZone() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Mes Rapports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Générer un rapport pour ta psy:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildReportButton('Light', 'Résumé simple'),
                _buildReportButton('Medium', 'Détails modérés'),
                _buildReportButton('Complete', 'Données complètes'),
                _buildReportButton('Focus', 'Focus spécifique'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportButton(String type, String description) {
    return ElevatedButton(
      onPressed: () => _generateReport(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      child: Text(type),
    );
  }

  Future<void> _generateReport(String reportType) async {
    try {
      final report = await AriaHealthService.generatePsyReport(
        reportType: reportType.toLowerCase(),
      );

      // Afficher le rapport dans une modal
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Rapport $reportType'),
          content: SingleChildScrollView(
            child: Text(report['content'] ?? 'Rapport généré'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur génération rapport: $e')),
      );
    }
  }
}
```

---

## 🚀 **COMMANDES DE DÉPLOIEMENT**

### **Script de déploiement complet**
```bash
#!/bin/bash
# deploy_aria.sh

echo "🚀 Déploiement ARIA - Module Santé+ dans CIA"

# 1. Backup
echo "📦 Sauvegarde CIA existant..."
cp -r /Volumes/T7/arkalia-cia /Volumes/T7/arkalia-cia-backup-$(date +%Y%m%d)

# 2. Intégration composants
echo "🔧 Intégration composants..."
cd /Volumes/T7/arkalia-cia

# Récupérer Metrics Collector
cp -r /Volumes/T7/arkalia-metrics-collector/src/arkalia_metrics_collector ./health_metrics/

# Récupérer scripts automatisation
cp -r /Volumes/T7/base_template/scripts ./scripts/
cp -r /Volumes/T7/workspace-tools ./tools/

# 3. Tests
echo "🧪 Tests complets..."
make test-health-complete
make security-audit-health

# 4. Déploiement
echo "🚀 Déploiement..."
make deploy-health-module

echo "✅ ARIA déployé avec succès !"
echo "📱 Module Santé+ disponible dans CIA"
echo "🎮 Gamification Quest intégrée"
echo "🤖 ARIA IA personnelle active"
echo "📊 Laboratoire personnel opérationnel"
```

---

## 📚 Related Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
- **[API.md](API.md)** - API reference
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment procedures
- **[INDEX_DOCUMENTATION.md](INDEX_DOCUMENTATION.md)** - Full documentation index

---

---

## Voir aussi (fin)

- **[VUE_ENSEMBLE_PROJET.md](./VUE_ENSEMBLE_PROJET.md)** — Vue d'ensemble de l'écosystème Arkalia
- **[ANALYSE_COMPLETE_BESOINS_MERE.md](./ANALYSE_COMPLETE_BESOINS_MERE.md)** — Analyse des besoins
- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** — Documentation API complète
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** — Architecture système
- **[INDEX_DOCUMENTATION.md](./INDEX_DOCUMENTATION.md)** — Index complet de la documentation

---

*Dernière mise à jour : Janvier 2025*  
*Ce guide d'implémentation fournit des instructions étape par étape pour intégrer la fonctionnalité ARIA dans Arkalia CIA.*
