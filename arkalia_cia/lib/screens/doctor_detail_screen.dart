import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import '../models/doctor.dart' as models;
import 'add_edit_doctor_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  Doctor? _doctor;
  List<models.Consultation> _consultations = [];
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Médecin')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_doctor!.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Historique des consultations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (_consultations.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Aucune consultation enregistrée',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._consultations.map((consultation) => _buildConsultationCard(consultation)),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _doctor!.fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (_doctor!.specialty != null) ...[
              const SizedBox(height: 8),
              Text(
                _doctor!.specialty!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_doctor!.phone != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(_doctor!.phone!),
                ],
              ),
            ],
            if (_doctor!.email != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(_doctor!.email!),
                ],
              ),
            ],
            if (_doctor!.address != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '${_stats!['consultation_count']}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text('Consultations'),
              ],
            ),
            if (_stats!['last_visit'] != null)
              Column(
                children: [
                  const Text(
                    'Dernière visite',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    _formatDate(_stats!['last_visit']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(models.Consultation consultation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.calendar_today,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(_formatDate(consultation.date.toIso8601String())),
        subtitle: consultation.reason != null
            ? Text(consultation.reason!)
            : null,
        trailing: consultation.documentIds.isNotEmpty
            ? Chip(
                label: Text('${consultation.documentIds.length} doc'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null,
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
}

