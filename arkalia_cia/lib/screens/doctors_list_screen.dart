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
        
        return matchesSearch && matchesSpecialty;
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
                              color: Colors.grey[400],
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
                              title: Text(
                                doctor.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
}

