import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import 'doctor_detail_screen.dart';
import 'add_edit_doctor_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  List<Doctor> _displayedDoctors = []; // Pour pagination
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSpecialty;
  Color? _selectedColor; // Filtre par couleur (spécialité)
  
  // Pagination pour performance
  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  bool _hasMoreItems = true;

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
        // Pagination : Charger seulement les 20 premiers
        _currentPage = 0;
        _hasMoreItems = doctors.length > _itemsPerPage;
        _displayedDoctors = doctors.take(_itemsPerPage).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
      }
    }
  }

  void _filterDoctors() {
    setState(() {
      // Réinitialiser la pagination lors du filtrage
      _currentPage = 0;
      final queryLower = _searchQuery.toLowerCase().trim();
      _filteredDoctors = _doctors.where((doctor) {
        // Recherche améliorée : dans nom complet, prénom, nom, spécialité, téléphone
        final matchesSearch = queryLower.isEmpty ||
            doctor.fullName.toLowerCase().contains(queryLower) ||
            doctor.firstName.toLowerCase().contains(queryLower) ||
            doctor.lastName.toLowerCase().contains(queryLower) ||
            (doctor.specialty?.toLowerCase().contains(queryLower) ?? false) ||
            (doctor.phone?.toLowerCase().contains(queryLower) ?? false);
        
        final matchesSpecialty = _selectedSpecialty == null ||
            doctor.specialty == _selectedSpecialty;
        
        // Filtre par couleur (spécialité)
        final matchesColor = _selectedColor == null ||
            Doctor.getColorForSpecialty(doctor.specialty) == _selectedColor;
        
        return matchesSearch && matchesSpecialty && matchesColor;
      }).toList();
      
      // Pagination : Limiter à la première page
      _hasMoreItems = _filteredDoctors.length > _itemsPerPage;
      _displayedDoctors = _filteredDoctors.take(_itemsPerPage).toList();
    });
  }
  
  /// Charge la page suivante pour la pagination
  void _loadNextPage() {
    if (!_hasMoreItems || _isLoading) return;
    
    final nextPage = _currentPage + 1;
    final startIndex = nextPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredDoctors.length);
    
    if (startIndex >= _filteredDoctors.length) {
      setState(() {
        _hasMoreItems = false;
      });
      return;
    }
    
    setState(() {
      _displayedDoctors.addAll(_filteredDoctors.sublist(startIndex, endIndex));
      _currentPage = nextPage;
      _hasMoreItems = endIndex < _filteredDoctors.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médecins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditDoctorScreen(),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un médecin...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterDoctors();
                  },
                ),
                const SizedBox(height: 8),
                // Filtre spécialité
                DropdownButton<String>(
                  value: _selectedSpecialty,
                  hint: const Text('Toutes les spécialités'),
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
            child: RefreshIndicator(
              onRefresh: _loadDoctors,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun médecin trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddEditDoctorScreen(),
                                  ),
                                );
                                if (result == true) {
                                  _loadDoctors();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un médecin'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _displayedDoctors.length + (_hasMoreItems ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Bouton "Charger plus" à la fin
                          if (index == _displayedDoctors.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: ElevatedButton.icon(
                                  onPressed: _loadNextPage,
                                  icon: const Icon(Icons.expand_more),
                                  label: const Text('Charger plus'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 48), // Minimum 48px pour accessibilité seniors
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          final doctor = _displayedDoctors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                radius: 24,
                                child: Text(
                                  doctor.firstName.isNotEmpty 
                                      ? doctor.firstName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      doctor.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Badge coloré selon spécialité (plus visible)
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Doctor.getColorForSpecialty(doctor.specialty),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (doctor.specialty != null)
                                      Text(
                                        doctor.specialty!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    if (doctor.phone != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '📞 ${doctor.phone}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
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
                            ),
                          );
                        },
                      ),
            ),
          ),
          
          // Légende des couleurs
          _buildColorLegend(),
        ],
      ),
    );
  }

  List<String> _getSpecialties() {
    final specialties = _doctors
        .map((d) => d.specialty)
        .where((s) => s != null && s.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    specialties.sort();
    return specialties;
  }

  /// Construit la légende des couleurs et filtres
  Widget _buildColorLegend() {
    final specialties = _getSpecialties();
    if (specialties.isEmpty) return const SizedBox.shrink();
    
    // Obtenir couleurs uniques
    final colorSpecialtyMap = <Color, String>{};
    for (var specialty in specialties) {
      final color = Doctor.getColorForSpecialty(specialty);
      if (!colorSpecialtyMap.containsKey(color)) {
        colorSpecialtyMap[color] = specialty;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Légende des couleurs (spécialités)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: colorSpecialtyMap.entries.map((entry) {
              final isSelected = _selectedColor == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = isSelected ? null : entry.key;
                  });
                  _filterDoctors();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? entry.key.withOpacity(0.3) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? entry.key : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: entry.key,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

