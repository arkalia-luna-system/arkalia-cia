# 🚀 PLAN 00 : ONBOARDING INTELLIGENT & HISTORIQUE AUTOMATIQUE

> **Première connexion : import automatique intelligent pour créer historique complet dès le départ**

---

## 🎯 **OBJECTIF**

Permettre à **tout utilisateur** (pas seulement votre mère) de :
- **Première connexion** : Onboarding intelligent qui propose d'importer automatiquement ses données
- **Import automatique** depuis portails santé (eHealth, Andaman 7, MaSanté)
- **Création historique intelligent** qui extrait **uniquement l'essentiel**
- **Interface ultra-simple** : tout se fait automatiquement, utilisateur valide juste

---

## 📋 **BESOINS IDENTIFIÉS**

### **Besoin Principal**
- ✅ **Première connexion** : Proposer import automatique données
- ✅ **Import portails santé** : eHealth, Andaman 7, MaSanté (avec consentement)
- ✅ **Historique intelligent** : Extraire uniquement l'essentiel (médecins, examens importants, dates clés)
- ✅ **Même si ça prend du temps** : C'est pour avoir historique complet dès le départ
- ✅ **Interface simple** : Utilisateur valide, tout se fait automatiquement

### **Fonctionnalités Requises**
- 🔐 Authentification portails santé (eHealth, etc.)
- 📥 Import automatique données essentielles
- 🧠 Extraction intelligente (ne garder que l'essentiel)
- 📊 Création historique structuré automatique
- ✅ Validation utilisateur avant import
- ⏱️ Barre progression pendant import

---

## 🏗️ **ARCHITECTURE**

### **Flow Onboarding**

```
Première Connexion
├── Étape 1 : Bienvenue + Explication
├── Étape 2 : Proposer import automatique
│   ├── Option 1 : Import depuis portails santé
│   ├── Option 2 : Import manuel PDF
│   └── Option 3 : Commencer vide (skip)
├── Étape 3 : Authentification portails (si choisi)
├── Étape 4 : Import automatique avec progression
├── Étape 5 : Extraction intelligente données essentielles
└── Étape 6 : Validation historique créé
```

### **Structure Fichiers**

```
arkalia_cia/
├── lib/
│   ├── screens/
│   │   ├── onboarding/
│   │   │   ├── welcome_screen.dart           # Écran bienvenue
│   │   │   ├── import_choice_screen.dart     # Choix import
│   │   │   ├── portal_auth_screen.dart       # Auth portails
│   │   │   └── import_progress_screen.dart   # Progression import
│   │   └── main_screen.dart                  # App principale
│   ├── services/
│   │   ├── onboarding_service.dart           # Service onboarding
│   │   ├── portal_import_service.dart        # Import portails
│   │   └── intelligent_extractor.dart       # Extraction intelligente
│   └── widgets/
│       └── onboarding_progress_widget.dart  # Widget progression
└── arkalia_cia_python_backend/
    ├── onboarding/
    │   ├── portal_connector.py               # Connexion portails
    │   ├── data_importer.py                 # Import données
    │   └── intelligent_extractor.py         # Extraction essentiel
    └── api/
        └── onboarding_api.py                # API onboarding
```

---

## 🔧 **IMPLÉMENTATION DÉTAILLÉE**

### **Étape 1 : Écran Bienvenue**

**Fichier** : `arkalia_cia/lib/screens/onboarding/welcome_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'import_choice_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Icône
              Icon(
                Icons.health_and_safety,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              
              SizedBox(height: 32),
              
              // Titre
              Text(
                'Bienvenue dans Arkalia CIA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16),
              
              // Description
              Text(
                'Votre assistant santé personnel\n'
                'Tout au même endroit, sécurisé et intelligent',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 48),
              
              // Avantages
              _buildFeature(
                Icons.cloud_download,
                'Import automatique',
                'Récupérez vos données depuis vos portails santé',
              ),
              
              SizedBox(height: 16),
              
              _buildFeature(
                Icons.security,
                '100% sécurisé',
                'Toutes vos données restent sur votre appareil',
              ),
              
              SizedBox(height: 16),
              
              _buildFeature(
                Icons.auto_awesome,
                'Intelligent',
                'Création automatique de votre historique médical',
              ),
              
              Spacer(),
              
              // Bouton continuer
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImportChoiceScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56),
                  padding: EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(
                  'Commencer',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

### **Étape 2 : Choix Import**

**Fichier** : `arkalia_cia/lib/screens/onboarding/import_choice_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'portal_auth_screen.dart';
import 'import_progress_screen.dart';
import '../../services/onboarding_service.dart';

class ImportChoiceScreen extends StatefulWidget {
  @override
  _ImportChoiceScreenState createState() => _ImportChoiceScreenState();
}

class _ImportChoiceScreenState extends State<ImportChoiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import de vos données'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer votre historique médical',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Nous pouvons importer automatiquement vos données depuis vos portails santé pour créer votre historique complet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Option 1 : Import portails santé
              _buildImportOption(
                icon: Icons.cloud_download,
                title: 'Import automatique depuis portails santé',
                description: 'eHealth, Andaman 7, MaSanté\n'
                    'Création automatique historique intelligent',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortalAuthScreen(),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 16),
              
              // Option 2 : Import manuel PDF
              _buildImportOption(
                icon: Icons.upload_file,
                title: 'Importer mes documents PDF',
                description: 'Sélectionner vos PDF médicaux\n'
                    'Extraction automatique données essentielles',
                color: Colors.green,
                onTap: () {
                  // Rediriger vers import PDF
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImportProgressScreen(
                        importType: ImportType.manualPDF,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 16),
              
              // Option 3 : Commencer vide
              _buildImportOption(
                icon: Icons.add_circle_outline,
                title: 'Commencer sans import',
                description: 'Créer votre historique manuellement\n'
                    'Vous pourrez importer plus tard',
                color: Colors.grey,
                onTap: () {
                  _skipImport();
                },
              ),
              
              Spacer(),
              
              // Note importante
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'L\'import peut prendre quelques minutes, mais vous aurez un historique complet dès le départ.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _skipImport() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

---

### **Étape 3 : Authentification Portails**

**Fichier** : `arkalia_cia/lib/screens/onboarding/portal_auth_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'import_progress_screen.dart';
import '../../services/portal_import_service.dart';

class PortalAuthScreen extends StatefulWidget {
  @override
  _PortalAuthScreenState createState() => _PortalAuthScreenState();
}

class _PortalAuthScreenState extends State<PortalAuthScreen> {
  final PortalImportService _importService = PortalImportService();
  Set<String> _selectedPortals = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _portals = [
    {
      'id': 'ehealth',
      'name': 'eHealth (Réseau Santé Wallon)',
      'icon': Icons.health_and_safety,
      'color': Colors.blue,
      'description': 'Portail gouvernemental belge',
    },
    {
      'id': 'andaman7',
      'name': 'Andaman 7',
      'icon': Icons.phone_android,
      'color': Colors.green,
      'description': 'Application santé belge',
    },
    {
      'id': 'masante',
      'name': 'MaSanté',
      'icon': Icons.local_hospital,
      'color': Colors.red,
      'description': 'Portail santé belge',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion portails santé'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionnez vos portails santé',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Nous importerons uniquement les données essentielles pour créer votre historique.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Liste portails
              Expanded(
                child: ListView.builder(
                  itemCount: _portals.length,
                  itemBuilder: (context, index) {
                    final portal = _portals[index];
                    final isSelected = _selectedPortals.contains(portal['id']);
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedPortals.add(portal['id']);
                            } else {
                              _selectedPortals.remove(portal['id']);
                            }
                          });
                        },
                        title: Text(
                          portal['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(portal['description']),
                        secondary: Icon(
                          portal['icon'],
                          color: portal['color'],
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Bouton continuer
              ElevatedButton(
                onPressed: _selectedPortals.isEmpty || _isLoading
                    ? null
                    : _startImport,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Continuer avec ${_selectedPortals.length} portail${_selectedPortals.length > 1 ? 'x' : ''}',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startImport() async {
    setState(() => _isLoading = true);

    try {
      // Pour chaque portail sélectionné, ouvrir authentification
      for (final portalId in _selectedPortals) {
        await _authenticatePortal(portalId);
      }

      // Rediriger vers écran progression import
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ImportProgressScreen(
            importType: ImportType.portals,
            portalIds: _selectedPortals.toList(),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur authentification: $e')),
      );
    }
  }

  Future<void> _authenticatePortal(String portalId) async {
    // Ouvrir URL authentification portail
    final authUrl = await _importService.getAuthUrl(portalId);
    
    if (await canLaunch(authUrl)) {
      await launch(authUrl);
      // Attendre callback authentification
      await _importService.waitForAuth(portalId);
    }
  }
}
```

---

### **Étape 4 : Extraction Intelligente**

**Fichier** : `arkalia_cia_python_backend/onboarding/intelligent_extractor.py`

```python
"""
Extraction intelligente : ne garder que l'essentiel
Médecins, examens importants, dates clés, médicaments principaux
"""
from typing import Dict, List
from datetime import datetime
import logging

logger = logging.getLogger(__name__)


class IntelligentExtractor:
    """Extracteur intelligent données essentielles"""
    
    def extract_essentials(self, raw_data: Dict) -> Dict:
        """
        Extrait uniquement données essentielles depuis données brutes
        
        Args:
            raw_data: Données brutes importées
        
        Returns:
            {
                'doctors': List[Dict],        # Médecins uniques
                'key_exams': List[Dict],      # Examens importants uniquement
                'key_dates': List[Dict],      # Dates clés (diagnostics, opérations)
                'medications': List[Dict],     # Médicaments principaux
                'summary': str                # Résumé historique
            }
        """
        essentials = {
            'doctors': self._extract_doctors(raw_data),
            'key_exams': self._extract_key_exams(raw_data),
            'key_dates': self._extract_key_dates(raw_data),
            'medications': self._extract_medications(raw_data),
            'summary': self._generate_summary(raw_data),
        }
        
        return essentials
    
    def _extract_doctors(self, data: Dict) -> List[Dict]:
        """Extrait médecins uniques avec spécialités"""
        doctors = {}
        
        # Parcourir consultations, examens, documents
        for item in data.get('consultations', []):
            doctor = item.get('doctor')
            if doctor:
                doctor_id = doctor.get('id') or doctor.get('name')
                if doctor_id not in doctors:
                    doctors[doctor_id] = {
                        'name': doctor.get('name', ''),
                        'specialty': doctor.get('specialty', ''),
                        'first_visit': item.get('date'),
                        'last_visit': item.get('date'),
                        'visit_count': 1,
                    }
                else:
                    # Mettre à jour dernière visite
                    if item.get('date') > doctors[doctor_id]['last_visit']:
                        doctors[doctor_id]['last_visit'] = item.get('date')
                    doctors[doctor_id]['visit_count'] += 1
        
        return list(doctors.values())
    
    def _extract_key_exams(self, data: Dict) -> List[Dict]:
        """Extrait uniquement examens importants"""
        all_exams = data.get('exams', [])
        
        # Filtrer : garder seulement examens importants
        key_exams = []
        
        important_types = [
            'scanner', 'irm', 'biopsie', 'operation',
            'diagnostic', 'resultat_anormal'
        ]
        
        for exam in all_exams:
            exam_type = exam.get('type', '').lower()
            
            # Garder si type important
            if any(important in exam_type for important in important_types):
                key_exams.append({
                    'type': exam.get('type'),
                    'date': exam.get('date'),
                    'result': exam.get('result', '')[:200],  # Limiter taille
                    'doctor': exam.get('doctor'),
                })
            # Garder aussi si résultat anormal
            elif exam.get('is_abnormal'):
                key_exams.append({
                    'type': exam.get('type'),
                    'date': exam.get('date'),
                    'result': exam.get('result', '')[:200],
                    'doctor': exam.get('doctor'),
                })
        
        # Trier par date (plus récent d'abord)
        key_exams.sort(key=lambda x: x.get('date', ''), reverse=True)
        
        # Limiter à 50 examens max
        return key_exams[:50]
    
    def _extract_key_dates(self, data: Dict) -> List[Dict]:
        """Extrait dates clés (diagnostics, opérations, etc.)"""
        key_dates = []
        
        # Parcourir documents pour trouver dates importantes
        for doc in data.get('documents', []):
            doc_type = doc.get('type', '').lower()
            
            # Dates importantes : diagnostics, opérations, hospitalisations
            if any(keyword in doc_type for keyword in ['diagnostic', 'operation', 'hospitalisation']):
                key_dates.append({
                    'date': doc.get('date'),
                    'type': doc.get('type'),
                    'description': doc.get('title', '')[:100],
                })
        
        # Trier par date
        key_dates.sort(key=lambda x: x.get('date', ''), reverse=True)
        
        return key_dates
    
    def _extract_medications(self, data: Dict) -> List[Dict]:
        """Extrait médicaments principaux (actuels et récents)"""
        medications = {}
        
        # Parcourir ordonnances
        for prescription in data.get('prescriptions', []):
            for med in prescription.get('medications', []):
                med_name = med.get('name', '')
                
                if med_name and med_name not in medications:
                    medications[med_name] = {
                        'name': med_name,
                        'dosage': med.get('dosage', ''),
                        'start_date': prescription.get('date'),
                        'is_current': prescription.get('is_current', False),
                    }
        
        # Garder seulement médicaments actuels + 10 plus récents
        current_meds = [m for m in medications.values() if m['is_current']]
        recent_meds = sorted(
            [m for m in medications.values() if not m['is_current']],
            key=lambda x: x.get('start_date', ''),
            reverse=True
        )[:10]
        
        return current_meds + recent_meds
    
    def _generate_summary(self, data: Dict) -> str:
        """Génère résumé historique intelligent"""
        summary_parts = []
        
        # Nombre médecins
        doctors_count = len(self._extract_doctors(data))
        if doctors_count > 0:
            summary_parts.append(f"{doctors_count} médecin{'s' if doctors_count > 1 else ''} consulté{'s' if doctors_count > 1 else ''}")
        
        # Examens importants
        key_exams = self._extract_key_exams(data)
        if key_exams:
            summary_parts.append(f"{len(key_exams)} examen{'s' if len(key_exams) > 1 else ''} important{'s' if len(key_exams) > 1 else ''}")
        
        # Dates clés
        key_dates = self._extract_key_dates(data)
        if key_dates:
            summary_parts.append(f"{len(key_dates)} date{'s' if len(key_dates) > 1 else ''} clé{'s' if len(key_dates) > 1 else ''}")
        
        return ", ".join(summary_parts) if summary_parts else "Historique créé"
```

---

### **Étape 5 : Écran Progression Import**

**Fichier** : `arkalia_cia/lib/screens/onboarding/import_progress_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../../services/portal_import_service.dart';

enum ImportType { portals, manualPDF }

class ImportProgressScreen extends StatefulWidget {
  final ImportType importType;
  final List<String>? portalIds;

  const ImportProgressScreen({
    required this.importType,
    this.portalIds,
  });

  @override
  _ImportProgressScreenState createState() => _ImportProgressScreenState();
}

class _ImportProgressScreenState extends State<ImportProgressScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  final PortalImportService _portalService = PortalImportService();
  
  double _progress = 0.0;
  String _currentStep = 'Initialisation...';
  Map<String, dynamic>? _importResult;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    try {
      if (widget.importType == ImportType.portals) {
        await _importFromPortals();
      } else {
        await _importManualPDF();
      }
    } catch (e) {
      setState(() {
        _currentStep = 'Erreur: $e';
      });
    }
  }

  Future<void> _importFromPortals() async {
    setState(() {
      _progress = 0.1;
      _currentStep = 'Connexion aux portails...';
    });

    // Importer depuis chaque portail
    for (int i = 0; i < widget.portalIds!.length; i++) {
      final portalId = widget.portalIds![i];
      
      setState(() {
        _currentStep = 'Import depuis ${_getPortalName(portalId)}...';
        _progress = 0.2 + (i * 0.3);
      });

      await _portalService.importFromPortal(portalId, (progress) {
        setState(() {
          _progress = 0.2 + (i * 0.3) + (progress * 0.3);
        });
      });
    }

    setState(() {
      _progress = 0.8;
      _currentStep = 'Extraction données essentielles...';
    });

    // Extraction intelligente
    final result = await _onboardingService.extractEssentials();

    setState(() {
      _progress = 1.0;
      _currentStep = 'Terminé !';
      _importResult = result;
    });

    // Attendre 2 secondes puis rediriger
    await Future.delayed(Duration(seconds: 2));
    _completeOnboarding();
  }

  Future<void> _importManualPDF() async {
    // Logique import PDF manuel
    // (similaire mais avec sélection fichiers)
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  String _getPortalName(String portalId) {
    final names = {
      'ehealth': 'eHealth',
      'andaman7': 'Andaman 7',
      'masante': 'MaSanté',
    };
    return names[portalId] ?? portalId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Icon(
                Icons.cloud_download,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              
              SizedBox(height: 32),
              
              // Titre
              Text(
                'Import en cours',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 8),
              
              // Étape actuelle
              Text(
                _currentStep,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32),
              
              // Barre progression
              LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
              ),
              
              SizedBox(height: 16),
              
              // Pourcentage
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 48),
              
              // Résultat import (si terminé)
              if (_importResult != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Historique créé avec succès !',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _importResult!['summary'] ?? '',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ✅ **TESTS**

### **Tests Extraction Intelligente**

```python
# tests/test_intelligent_extractor.py
def test_extract_essentials():
    extractor = IntelligentExtractor()
    raw_data = {
        'consultations': [...],
        'exams': [...],
        'documents': [...],
    }
    essentials = extractor.extract_essentials(raw_data)
    
    assert 'doctors' in essentials
    assert 'key_exams' in essentials
    assert len(essentials['key_exams']) <= 50  # Limite respectée
```

---

## 🚀 **PERFORMANCE**

### **Optimisations**

1. **Import asynchrone** : Ne pas bloquer UI
2. **Extraction progressive** : Extraire pendant import
3. **Cache données** : Mettre en cache données importées
4. **Limite données** : Ne garder que l'essentiel (50 examens max, etc.)

---

## 🔐 **SÉCURITÉ**

1. **Consentement explicite** : Demander avant chaque import
2. **Données locales** : Tout stocké localement
3. **Chiffrement** : Chiffrer données importées
4. **Validation** : Valider données avant import

---

## 📅 **TIMELINE**

### **Semaine 1 : Onboarding UI**
- [ ] Jour 1-2 : Écrans onboarding (Welcome, Choice, Progress)
- [ ] Jour 3-4 : Authentification portails
- [ ] Jour 5 : Tests UI

### **Semaine 2 : Backend Import**
- [ ] Jour 1-3 : Connexion portails (eHealth, Andaman 7, MaSanté)
- [ ] Jour 4-5 : Import données

### **Semaine 3 : Extraction Intelligente**
- [ ] Jour 1-3 : IntelligentExtractor
- [ ] Jour 4-5 : Tests extraction

### **Semaine 4 : Intégration**
- [ ] Jour 1-3 : Intégration complète
- [ ] Jour 4-5 : Tests finaux

---

## 📚 **RESSOURCES**

- **eHealth API** : https://www.ehealth.fgov.be
- **Andaman 7** : https://www.andaman7.com
- **MaSanté** : https://www.masante.be

---

**Statut** : 📋 **PLAN VALIDÉ**  
**Priorité** : 🔴 **CRITIQUE** (Doit être fait en premier)  
**Temps estimé** : 3-4 semaines

