# 👨‍⚕️ PLAN 02 : HISTORIQUE MÉDECINS COMPLET

> **Référentiel complet des médecins avec historique des consultations**

---

## 🎯 **OBJECTIF**

Permettre à votre mère d'avoir **une liste complète** de tous ses médecins avec :
- Coordonnées complètes
- Historique des consultations
- Documents associés
- Recherche facile par nom, spécialité, date

---

## 📋 **BESOINS IDENTIFIÉS**

### **Besoin Principal**
- ✅ Liste complète de tous les médecins consultés
- ✅ Référencer chaque médecin (nom, spécialité, coordonnées)
- ✅ Historique des consultations par médecin
- ✅ Recherche facile (nom, spécialité, date)
- ✅ Association documents ↔ médecins

### **Fonctionnalités Requises**
- 📝 Ajout/modification médecins
- 📅 Historique consultations (date, motif, documents)
- 🔍 Recherche avancée médecins
- 📎 Liaison documents ↔ médecins
- 📊 Statistiques par médecin (nombre consultations, dernière visite)

---

## 🏗️ **ARCHITECTURE**

### **Base de Données**

```sql
-- Table médecins
CREATE TABLE doctors (
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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table consultations
CREATE TABLE consultations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    doctor_id INTEGER NOT NULL,
    date DATE NOT NULL,
    reason TEXT,  -- Motif consultation
    notes TEXT,
    documents TEXT,  -- JSON array des IDs documents associés
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

-- Index pour recherche rapide
CREATE INDEX idx_doctors_name ON doctors(last_name, first_name);
CREATE INDEX idx_doctors_specialty ON doctors(specialty);
CREATE INDEX idx_consultations_doctor ON consultations(doctor_id);
CREATE INDEX idx_consultations_date ON consultations(date);
```

### **Structure Fichiers**

```
arkalia_cia/
├── lib/
│   ├── screens/
│   │   ├── doctors_list_screen.dart          # Liste médecins
│   │   ├── doctor_detail_screen.dart         # Détail médecin + historique
│   │   └── add_edit_doctor_screen.dart       # Formulaire ajout/modif
│   ├── services/
│   │   └── doctor_service.dart              # Service gestion médecins
│   └── widgets/
│       ├── doctor_card_widget.dart           # Carte médecin
│       └── consultation_timeline_widget.dart # Timeline consultations
└── arkalia_cia_python_backend/
    └── api/
        └── doctors_api.py                   # API médecins
```

---

## 🔧 **IMPLÉMENTATION DÉTAILLÉE**

### **Étape 1 : Modèle Données**

**Fichier** : `arkalia_cia/lib/models/doctor.dart`

```dart
class Doctor {
  final int? id;
  final String firstName;
  final String lastName;
  final String? specialty;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? postalCode;
  final String country;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    this.id,
    required this.firstName,
    required this.lastName,
    this.specialty,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.postalCode,
    this.country = 'Belgique',
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'specialty': specialty,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      specialty: map['specialty'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      city: map['city'],
      postalCode: map['postal_code'],
      country: map['country'] ?? 'Belgique',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class Consultation {
  final int? id;
  final int doctorId;
  final DateTime date;
  final String? reason;
  final String? notes;
  final List<int> documentIds;
  final DateTime createdAt;

  Consultation({
    this.id,
    required this.doctorId,
    required this.date,
    this.reason,
    this.notes,
    List<int>? documentIds,
    DateTime? createdAt,
  }) : documentIds = documentIds ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'date': date.toIso8601String(),
      'reason': reason,
      'notes': notes,
      'documents': documentIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'],
      doctorId: map['doctor_id'],
      date: DateTime.parse(map['date']),
      reason: map['reason'],
      notes: map['notes'],
      documentIds: map['documents'] != null
          ? (map['documents'] as String)
              .split(',')
              .where((s) => s.isNotEmpty)
              .map((s) => int.parse(s))
              .toList()
          : [],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
```

---

### **Étape 2 : Service Gestion Médecins**

**Fichier** : `arkalia_cia/lib/services/doctor_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import '../models/doctor.dart';
import '../database/database_helper.dart';

class DoctorService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CRUD Médecins
  Future<int> insertDoctor(Doctor doctor) async {
    final db = await _dbHelper.database;
    return await db.insert('doctors', doctor.toMap());
  }

  Future<List<Doctor>> getAllDoctors() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      orderBy: 'last_name ASC, first_name ASC',
    );
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<Doctor?> getDoctorById(int id) async {
    final db = await _dbHelper.database;
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
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'last_name LIKE ? OR first_name LIKE ? OR specialty LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'last_name ASC',
    );
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'specialty = ?',
      whereArgs: [specialty],
      orderBy: 'last_name ASC',
    );
    return List.generate(maps.length, (i) => Doctor.fromMap(maps[i]));
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await _dbHelper.database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await _dbHelper.database;
    // Supprimer aussi les consultations associées (CASCADE)
    return await db.delete(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Consultations
  Future<int> insertConsultation(Consultation consultation) async {
    final db = await _dbHelper.database;
    return await db.insert('consultations', consultation.toMap());
  }

  Future<List<Consultation>> getConsultationsByDoctor(int doctorId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'consultations',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Consultation.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getDoctorStats(int doctorId) async {
    final db = await _dbHelper.database;
    
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
```

---

### **Étape 3 : Interface Liste Médecins**

**Fichier** : `arkalia_cia/lib/screens/doctors_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import '../widgets/doctor_card_widget.dart';
import 'doctor_detail_screen.dart';
import 'add_edit_doctor_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  @override
  _DoctorsListScreenState createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _doctorService.getAllDoctors();
      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement: $e')),
      );
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        final matchesSearch = _searchQuery.isEmpty ||
            doctor.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (doctor.specialty?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        final matchesSpecialty = _selectedSpecialty == null ||
            doctor.specialty == _selectedSpecialty;
        
        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Médecins'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditDoctorScreen(),
                ),
              );
              if (result == true) {
                _loadDoctors();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre recherche
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un médecin...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterDoctors();
                  },
                ),
                SizedBox(height: 8),
                // Filtre spécialité
                DropdownButton<String>(
                  value: _selectedSpecialty,
                  hint: Text('Toutes les spécialités'),
                  isExpanded: true,
                  items: _getSpecialties().map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value;
                      _filterDoctors();
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Liste médecins
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? Center(child: Text('Aucun médecin trouvé'))
                    : ListView.builder(
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return DoctorCardWidget(
                            doctor: doctor,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailScreen(
                                    doctorId: doctor.id!,
                                  ),
                                ),
                              );
                              _loadDoctors();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  List<String> _getSpecialties() {
    final specialties = _doctors
        .map((d) => d.specialty)
        .where((s) => s != null && s.isNotEmpty)
        .toSet()
        .toList();
    specialties.sort();
    return specialties;
  }
}
```

---

### **Étape 4 : Interface Détail Médecin**

**Fichier** : `arkalia_cia/lib/screens/doctor_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import '../models/consultation.dart';
import '../widgets/consultation_timeline_widget.dart';
import 'add_edit_doctor_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const DoctorDetailScreen({required this.doctorId});

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  Doctor? _doctor;
  List<Consultation> _consultations = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);
    try {
      final doctor = await _doctorService.getDoctorById(widget.doctorId);
      final consultations = await _doctorService.getConsultationsByDoctor(widget.doctorId);
      final stats = await _doctorService.getDoctorStats(widget.doctorId);
      
      setState(() {
        _doctor = doctor;
        _consultations = consultations;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _doctor == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Médecin')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_doctor!.fullName),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditDoctorScreen(doctor: _doctor),
                ),
              );
              if (result == true) {
                _loadDoctorData();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations médecin
            _buildDoctorInfo(),
            
            // Statistiques
            if (_stats != null) _buildStats(),
            
            // Historique consultations
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Historique des consultations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ConsultationTimelineWidget(consultations: _consultations),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _doctor!.fullName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (_doctor!.specialty != null) ...[
              SizedBox(height: 8),
              Text(
                _doctor!.specialty!,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
            if (_doctor!.phone != null) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.phone, size: 20),
                  SizedBox(width: 8),
                  Text(_doctor!.phone!),
                ],
              ),
            ],
            if (_doctor!.email != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 20),
                  SizedBox(width: 8),
                  Text(_doctor!.email!),
                ],
              ),
            ],
            if (_doctor!.address != null) ...[
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('${_doctor!.address}\n${_doctor!.city} ${_doctor!.postalCode ?? ''}'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '${_stats!['consultation_count']}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Consultations'),
              ],
            ),
            if (_stats!['last_visit'] != null)
              Column(
                children: [
                  Text(
                    'Dernière visite',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    _formatDate(_stats!['last_visit']),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
}
```

---

## ✅ **TESTS**

### **Tests Service**

```dart
// test/doctor_service_test.dart
void main() {
  group('DoctorService', () {
    test('insertDoctor ajoute un médecin', () async {
      final service = DoctorService();
      final doctor = Doctor(
        firstName: 'Jean',
        lastName: 'Dupont',
        specialty: 'Cardiologue',
      );
      final id = await service.insertDoctor(doctor);
      expect(id, greaterThan(0));
    });

    test('searchDoctors trouve par nom', () async {
      final service = DoctorService();
      final results = await service.searchDoctors('Dupont');
      expect(results.length, greaterThan(0));
    });
  });
}
```

---

## 🚀 **PERFORMANCE**

### **Optimisations**

1. **Index base de données** : Index sur nom, spécialité, date
2. **Cache liste médecins** : Mettre en cache liste complète
3. **Pagination** : Paginer si beaucoup de médecins
4. **Recherche asynchrone** : Recherche en temps réel sans bloquer UI

---

## 🔐 **SÉCURITÉ**

1. **Validation données** : Valider tous les champs avant insertion
2. **Sanitization** : Nettoyer entrées utilisateur
3. **Cascade delete** : Supprimer consultations si médecin supprimé
4. **Chiffrement** : Chiffrer données sensibles (email, téléphone)

---

## 📅 **TIMELINE**

### **Semaine 1 : Backend & Modèles**
- [ ] Jour 1 : Modèles Doctor et Consultation
- [ ] Jour 2 : Service DoctorService
- [ ] Jour 3 : Tests service
- [ ] Jour 4-5 : API backend (si nécessaire)

### **Semaine 2 : Frontend**
- [ ] Jour 1-2 : Liste médecins
- [ ] Jour 3 : Détail médecin + historique
- [ ] Jour 4 : Formulaire ajout/modification
- [ ] Jour 5 : Tests UI

---

## 📚 **RESSOURCES**

- **SQLite Flutter** : https://pub.dev/packages/sqflite
- **Design Material** : https://material.io/design

---

**Statut** : 📋 **PLAN VALIDÉ**  
**Priorité** : 🔴 **CRITIQUE**  
**Temps estimé** : 1-2 semaines

