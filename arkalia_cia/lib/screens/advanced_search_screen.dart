import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import 'documents_screen.dart';
import 'doctor_detail_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  final DoctorService _doctorService = DoctorService();
  
  SearchFilters _filters = SearchFilters();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  bool _useSemanticSearch = true; // Activé par défaut pour meilleure qualité de recherche
  List<String> _suggestions = [];
  List<Doctor> _doctors = [];
  String? _selectedCategory;
  String? _selectedExamType;
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedDoctorId;
  
  // Types d'examens médicaux courants
  static const List<String> _examTypes = [
    'Analyse de sang',
    'Radiographie',
    'IRM',
    'Scanner',
    'Échographie',
    'ECG',
    'Biopsie',
    'Endoscopie',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _doctorService.getAllDoctors();
      setState(() {
        _doctors = doctors;
      });
    } catch (e) {
      // Ignorer erreur
    }
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
        category: _selectedCategory,
        examType: _selectedExamType,
        startDate: _startDate,
        endDate: _endDate,
        doctorId: _selectedDoctorId,
      );
    });

    try {
      final results = await _searchService.search(_filters, useSemantic: _useSemanticSearch);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur recherche: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche Avancée'),
      ),
      body: Column(
        children: [
          // Barre recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _results = [];
                                _suggestions = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                
                // Suggestions
                if (_suggestions.isNotEmpty)
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Filtre catégorie
                FilterChip(
                  label: Text(_selectedCategory ?? 'Catégorie'),
                  selected: _selectedCategory != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showCategoryDialog();
                    } else {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _performSearch();
                    }
                  },
                ),
                
                // Filtre date
                FilterChip(
                  label: Text(_startDate != null || _endDate != null 
                      ? 'Date sélectionnée' 
                      : 'Date'),
                  selected: _startDate != null || _endDate != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showDateRangePicker();
                    } else {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _performSearch();
                    }
                  },
                ),
                
                // Filtre type d'examen
                FilterChip(
                  label: Text(_selectedExamType ?? 'Type examen'),
                  selected: _selectedExamType != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showExamTypeDialog();
                    } else {
                      setState(() {
                        _selectedExamType = null;
                      });
                      _performSearch();
                    }
                  },
                ),
                
                // Filtre médecin
                FilterChip(
                  label: Text(_selectedDoctorId != null && _doctors.isNotEmpty
                      ? (_doctors.firstWhere(
                          (d) => d.id == _selectedDoctorId,
                          orElse: () => _doctors.first,
                        ).fullName)
                      : 'Médecin'),
                  selected: _selectedDoctorId != null,
                  onSelected: (selected) {
                    if (selected) {
                      _showDoctorDialog();
                    } else {
                      setState(() {
                        _selectedDoctorId = null;
                      });
                      _performSearch();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Options de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Recherche sémantique'),
                    subtitle: const Text('Meilleure qualité de résultats'),
                    value: _useSemanticSearch,
                    onChanged: (value) {
                      setState(() {
                        _useSemanticSearch = value ?? true;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          // Bouton rechercher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performSearch,
                icon: const Icon(Icons.search),
                label: const Text('Rechercher'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Résultats
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun résultat',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final result = _results[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Icon(
                                result.type == 'document' 
                                    ? Icons.description
                                    : result.type == 'doctor'
                                        ? Icons.person
                                        : Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(result.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (result.preview != null)
                                    Text(result.preview!),
                                  if (result.date != null)
                                    Text(
                                      '${result.date!.day}/${result.date!.month}/${result.date!.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                if (result.type == 'document') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DocumentsScreen(),
                                    ),
                                  );
                                } else if (result.type == 'doctor') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorDetailScreen(
                                        doctorId: int.parse(result.id),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog() async {
    final categories = ['Tous', 'Ordonnance', 'Résultat', 'Compte-rendu', 'Autre'];
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir catégorie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) {
            return RadioListTile<String>(
              title: Text(cat),
              value: cat,
              groupValue: _selectedCategory ?? 'Tous',
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
      ),
    );
    
    if (selected != null) {
      setState(() {
        _selectedCategory = selected == 'Tous' ? null : selected;
      });
      _performSearch();
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _performSearch();
    }
  }

  Future<void> _showExamTypeDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir type d\'examen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _examTypes.map((type) {
            return RadioListTile<String>(
              title: Text(type),
              value: type,
              groupValue: _selectedExamType,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
    
    if (selected != null) {
      setState(() {
        _selectedExamType = selected;
      });
      _performSearch();
    }
  }

  Future<void> _showDoctorDialog() async {
    if (_doctors.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun médecin disponible')),
        );
      }
      return;
    }

    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir médecin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              if (doctor.id == null) return const SizedBox.shrink();
              return RadioListTile<int>(
                title: Text(doctor.fullName),
                subtitle: doctor.specialty != null ? Text(doctor.specialty!) : null,
                value: doctor.id!,
                groupValue: _selectedDoctorId,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              );
            },
          ),
        ),
      ),
    );
    
    if (selected != null) {
      setState(() {
        _selectedDoctorId = selected;
      });
      _performSearch();
    }
  }
}

