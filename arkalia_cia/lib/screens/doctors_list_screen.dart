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
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedSpecialty;
  Color? _selectedColor; // Filtre par couleur (spécialité)

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
      }
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
        
        // Filtre par couleur (spécialité)
        final matchesColor = _selectedColor == null ||
            Doctor.getColorForSpecialty(doctor.specialty) == _selectedColor;
        
        return matchesSearch && matchesSpecialty && matchesColor;
      }).toList();
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                                color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun médecin trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
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
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  doctor.firstName[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    doctor.fullName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  // Badge coloré selon spécialité (plus visible)
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: Doctor.getColorForSpecialty(doctor.specialty),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (doctor.specialty != null)
                                    Text(doctor.specialty!),
                                  if (doctor.phone != null)
                                    Text('📞 ${doctor.phone}'),
                                ],
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                    color: isSelected ? entry.key.withValues(alpha: 0.3) : Colors.transparent,
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
                          fontSize: 14,
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

