# 🔍 PLAN 03 : RECHERCHE AVANCÉE

> **Moteur de recherche performant pour examens, documents et consultations**

---

## 🎯 **OBJECTIF**

Permettre à votre mère de **retrouver facilement** n'importe quel document, examen ou consultation avec :
- Recherche multi-critères (type, date, médecin)
- Filtres combinés
- Recherche sémantique ("tous les examens cardiaques")
- Performance optimale (<200ms)

---

## 📋 **BESOINS IDENTIFIÉS**

### **Besoin Principal**
- ✅ Rechercher un examen spécifique
- ✅ Retrouver des résultats d'analyses
- ✅ Rechercher par date (période, année)
- ✅ Rechercher par type (radio, analyse, scanner)
- ✅ Rechercher par médecin prescripteur
- ✅ Filtres multiples combinés

### **Fonctionnalités Requises**
- 🔍 Recherche texte intégral (déjà existante, à améliorer)
- 📅 Filtre par date (période, année)
- 🏷️ Filtre par type examen
- 👨‍⚕️ Filtre par médecin
- 🔗 Recherche sémantique basique
- ⚡ Performance <200ms

---

## 🏗️ **ARCHITECTURE**

### **Index de Recherche**

```sql
-- Index pour recherche rapide
CREATE INDEX idx_documents_text ON documents(text_content);
CREATE INDEX idx_documents_type ON documents(category);
CREATE INDEX idx_documents_date ON documents(created_at);
CREATE INDEX idx_documents_doctor ON documents(doctor_id);

-- Table pour recherche sémantique (optionnel)
CREATE VIRTUAL TABLE documents_fts USING fts5(
    title,
    content,
    doctor_name,
    exam_type,
    content='documents',
    content_rowid='id'
);
```

### **Structure Fichiers**

```
arkalia_cia/
├── lib/
│   ├── screens/
│   │   └── advanced_search_screen.dart      # Interface recherche avancée
│   ├── services/
│   │   └── search_service.dart              # Service recherche
│   └── widgets/
│       ├── search_filters_widget.dart        # Widget filtres
│       └── search_results_widget.dart        # Widget résultats
```

---

## 🔧 **IMPLÉMENTATION DÉTAILLÉE**

### **Étape 1 : Service Recherche**

**Fichier** : `arkalia_cia/lib/services/search_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class SearchFilters {
  final String? query;
  final String? examType;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? doctorId;
  final String? category;

  SearchFilters({
    this.query,
    this.examType,
    this.startDate,
    this.endDate,
    this.doctorId,
    this.category,
  });
}

class SearchResult {
  final int id;
  final String title;
  final String type;  // 'document', 'consultation', 'examen'
  final DateTime? date;
  final String? preview;
  final double? relevanceScore;

  SearchResult({
    required this.id,
    required this.title,
    required this.type,
    this.date,
    this.preview,
    this.relevanceScore,
  });
}

class SearchService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<SearchResult>> search(SearchFilters filters) async {
    final db = await _dbHelper.database;
    final List<SearchResult> results = [];

    // Construire requête SQL dynamique
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    // Filtre texte
    if (filters.query != null && filters.query!.isNotEmpty) {
      whereClauses.add('(title LIKE ? OR text_content LIKE ?)');
      final queryPattern = '%${filters.query}%';
      whereArgs.add(queryPattern);
      whereArgs.add(queryPattern);
    }

    // Filtre type examen
    if (filters.examType != null) {
      whereClauses.add('exam_type = ?');
      whereArgs.add(filters.examType);
    }

    // Filtre date
    if (filters.startDate != null) {
      whereClauses.add('created_at >= ?');
      whereArgs.add(filters.startDate!.toIso8601String());
    }
    if (filters.endDate != null) {
      whereClauses.add('created_at <= ?');
      whereArgs.add(filters.endDate!.toIso8601String());
    }

    // Filtre médecin
    if (filters.doctorId != null) {
      whereClauses.add('doctor_id = ?');
      whereArgs.add(filters.doctorId);
    }

    // Filtre catégorie
    if (filters.category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(filters.category);
    }

    // Construire requête finale
    final whereClause = whereClauses.isNotEmpty
        ? 'WHERE ${whereClauses.join(' AND ')}'
        : '';

    // Recherche dans documents
    final documentsQuery = '''
      SELECT id, title, category, created_at, text_content
      FROM documents
      $whereClause
      ORDER BY created_at DESC
      LIMIT 50
    ''';

    final documents = await db.rawQuery(documentsQuery, whereArgs);

    for (var doc in documents) {
      final textContent = doc['text_content'] as String? ?? '';
      final preview = textContent.length > 200
          ? '${textContent.substring(0, 200)}...'
          : textContent;

      results.add(SearchResult(
        id: doc['id'] as int,
        title: doc['title'] as String,
        type: 'document',
        date: doc['created_at'] != null
            ? DateTime.parse(doc['created_at'] as String)
            : null,
        preview: preview,
      ));
    }

    // Recherche dans consultations
    if (filters.query == null || filters.query!.isEmpty || 
        filters.query!.toLowerCase().contains('consultation')) {
      final consultationsQuery = '''
        SELECT c.id, c.date, c.reason, d.first_name || ' ' || d.last_name as doctor_name
        FROM consultations c
        LEFT JOIN doctors d ON c.doctor_id = d.id
        ${filters.doctorId != null ? 'WHERE c.doctor_id = ?' : ''}
        ORDER BY c.date DESC
        LIMIT 50
      ''';

      final consultations = await db.rawQuery(
        consultationsQuery,
        filters.doctorId != null ? [filters.doctorId] : [],
      );

      for (var consult in consultations) {
        final reason = consult['reason'] as String? ?? '';
        final doctorName = consult['doctor_name'] as String? ?? '';
        final title = 'Consultation${doctorName.isNotEmpty ? ' - $doctorName' : ''}';

        results.add(SearchResult(
          id: consult['id'] as int,
          title: title,
          type: 'consultation',
          date: DateTime.parse(consult['date'] as String),
          preview: reason,
        ));
      }
    }

    // Trier par pertinence (date récente d'abord)
    results.sort((a, b) {
      if (a.date != null && b.date != null) {
        return b.date!.compareTo(a.date!);
      }
      return 0;
    });

    return results;
  }

  // Recherche sémantique basique
  Future<List<SearchResult>> semanticSearch(String query) async {
    // Mapping mots-clés → types examens
    final keywordMapping = {
      'cardiaque': 'radio',
      'cœur': 'radio',
      'poumon': 'radio',
      'radio': 'radio',
      'scanner': 'scanner',
      'irm': 'irm',
      'analyse': 'analyse',
      'sang': 'analyse',
      'urine': 'analyse',
    };

    final queryLower = query.toLowerCase();
    String? examType;

    for (var entry in keywordMapping.entries) {
      if (queryLower.contains(entry.key)) {
        examType = entry.value;
        break;
      }
    }

    return search(SearchFilters(
      query: query,
      examType: examType,
    ));
  }

  // Suggestions de recherche
  Future<List<String>> getSearchSuggestions(String partialQuery) async {
    final db = await _dbHelper.database;
    
    // Suggestions depuis titres documents
    final suggestions = await db.rawQuery('''
      SELECT DISTINCT title
      FROM documents
      WHERE title LIKE ?
      LIMIT 10
    ''', ['%$partialQuery%']);

    return suggestions.map((s) => s['title'] as String).toList();
  }
}
```

---

### **Étape 2 : Interface Recherche Avancée**

**Fichier** : `arkalia_cia/lib/screens/advanced_search_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../widgets/search_filters_widget.dart';
import '../widgets/search_results_widget.dart';

class AdvancedSearchScreen extends StatefulWidget {
  @override
  _AdvancedSearchScreenState createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  
  SearchFilters _filters = SearchFilters();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    if (query.length >= 2) {
      final suggestions = await _searchService.getSearchSuggestions(query);
      setState(() {
        _suggestions = suggestions;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
      _filters = SearchFilters(
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
        examType: _filters.examType,
        startDate: _filters.startDate,
        endDate: _filters.endDate,
        doctorId: _filters.doctorId,
        category: _filters.category,
      );
    });

    try {
      final results = await _searchService.search(_filters);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur recherche: $e')),
      );
    }
  }

  Future<void> _performSemanticSearch() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await _searchService.semanticSearch(query);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur recherche: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche Avancée'),
      ),
      body: Column(
        children: [
          // Barre recherche
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _results = [];
                                _suggestions = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                
                // Suggestions
                if (_suggestions.isNotEmpty)
                  Container(
                    height: 100,
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_suggestions[index]),
                          onTap: () {
                            _searchController.text = _suggestions[index];
                            _performSearch();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Filtres
          SearchFiltersWidget(
            filters: _filters,
            onFiltersChanged: (newFilters) {
              setState(() {
                _filters = newFilters;
              });
              _performSearch();
            },
          ),

          // Résultats
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(child: Text('Aucun résultat'))
                    : SearchResultsWidget(results: _results),
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ **TESTS**

### **Tests Performance**

```dart
// test/search_performance_test.dart
void main() {
  test('Recherche complète < 200ms', () async {
    final service = SearchService();
    final stopwatch = Stopwatch()..start();
    
    await service.search(SearchFilters(query: 'test'));
    
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(200));
  });
}
```

---

## 🚀 **PERFORMANCE**

### **Optimisations**

1. **Index SQLite** : Index sur colonnes recherchées
2. **Limite résultats** : Limiter à 50 résultats par défaut
3. **Recherche asynchrone** : Ne pas bloquer UI
4. **Cache suggestions** : Mettre en cache suggestions fréquentes
5. **Debounce recherche** : Attendre 300ms avant recherche

---

## 🔐 **SÉCURITÉ**

1. **Sanitization** : Nettoyer requêtes utilisateur
2. **Prévention SQL injection** : Utiliser paramètres liés
3. **Limite résultats** : Empêcher requêtes trop lourdes

---

## 📅 **TIMELINE**

### **Semaine 1 : Backend**
- [ ] Jour 1-2 : Service recherche
- [ ] Jour 3 : Recherche sémantique
- [ ] Jour 4-5 : Tests performance

### **Semaine 2 : Frontend**
- [ ] Jour 1-2 : Interface recherche
- [ ] Jour 3 : Widgets filtres et résultats
- [ ] Jour 4-5 : Tests UI

---

**Statut** : 📋 **PLAN VALIDÉ**  
**Priorité** : 🔴 **CRITIQUE**  
**Temps estimé** : 2-3 semaines

