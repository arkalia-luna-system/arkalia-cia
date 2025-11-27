import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../services/medication_service.dart';
import '../widgets/medication_reminder_widget.dart';

// MedicationTaken est défini dans medication.dart

/// Écran de gestion des rappels médicaments
class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  State<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  final MedicationService _medicationService = MedicationService();
  List<Medication> _medications = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  /// Vérifie si un médicament a été pris pour une date et heure données
  Future<bool> _isMedicationTaken(int medicationId, DateTime date, TimeOfDay time) async {
    try {
      // Utiliser la méthode du service qui gère déjà le web
      final tracking = await _medicationService.getMedicationTracking(
        medicationId,
        date,
        date,
      );
      final dateStr = date.toIso8601String().split('T')[0];
      final timeStr = '${time.hour}:${time.minute}';
      
      // Vérifier dans les entrées si le médicament a été pris à cette heure
      final entries = tracking['entries'] as List?;
      if (entries != null) {
        return entries.any((entry) {
          if (entry is MedicationTaken) {
            final entryDate = entry.date.toIso8601String().split('T')[0];
            final entryTime = '${entry.time.hour}:${entry.time.minute}';
            return entryDate == dateStr && entryTime == timeStr && entry.taken;
          }
          return false;
        });
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadMedications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final medications = await _medicationService.getAllMedications();
      if (mounted) {
        setState(() {
          _medications = medications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Erreur lors du chargement: $e');
      }
    }
  }

  Future<void> _showAddEditMedicationDialog({Medication? medication}) async {
    final nameController = TextEditingController(text: medication?.name ?? '');
    final dosageController = TextEditingController(text: medication?.dosage ?? '');
    final notesController = TextEditingController(text: medication?.notes ?? '');
    String frequency = medication?.frequency ?? 'daily';
    List<TimeOfDay> times = medication?.times ?? [const TimeOfDay(hour: 8, minute: 0)];
    DateTime? startDate = medication?.startDate;
    DateTime? endDate = medication?.endDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(medication == null ? 'Nouveau médicament' : 'Modifier médicament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du médicament *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (ex: 1 comprimé, 5ml)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: const InputDecoration(
                    labelText: 'Fréquence',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Une fois par jour')),
                    DropdownMenuItem(value: 'twice_daily', child: Text('Deux fois par jour')),
                    DropdownMenuItem(value: 'three_times_daily', child: Text('Trois fois par jour')),
                    DropdownMenuItem(value: 'four_times_daily', child: Text('Quatre fois par jour')),
                    DropdownMenuItem(value: 'as_needed', child: Text('Selon besoin')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        frequency = value;
                        // Ajuster le nombre d'heures selon la fréquence
                        final defaultTimes = {
                          'daily': [const TimeOfDay(hour: 8, minute: 0)],
                          'twice_daily': [
                            const TimeOfDay(hour: 8, minute: 0),
                            const TimeOfDay(hour: 20, minute: 0),
                          ],
                          'three_times_daily': [
                            const TimeOfDay(hour: 8, minute: 0),
                            const TimeOfDay(hour: 14, minute: 0),
                            const TimeOfDay(hour: 20, minute: 0),
                          ],
                          'four_times_daily': [
                            const TimeOfDay(hour: 8, minute: 0),
                            const TimeOfDay(hour: 12, minute: 0),
                            const TimeOfDay(hour: 16, minute: 0),
                            const TimeOfDay(hour: 20, minute: 0),
                          ],
                          'as_needed': [const TimeOfDay(hour: 8, minute: 0)],
                        };
                        times = defaultTimes[value] ?? times;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ...times.asMap().entries.map((entry) {
                  final index = entry.key;
                  final time = entry.value;
                  return ListTile(
                    title: Text('Heure ${index + 1}'),
                    subtitle: Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: time,
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          times[index] = pickedTime;
                        });
                      }
                    },
                  );
                }),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date de début'),
                  subtitle: Text(startDate != null
                      ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                      : 'Non définie'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        startDate = date;
                      });
                    }
                  },
                ),
                if (endDate != null || true) ...[
                  ListTile(
                    title: const Text('Date de fin (optionnel)'),
                    subtitle: Text(endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'Aucune'),
                    trailing: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setDialogState(() {
                          endDate = null;
                        });
                      },
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() {
                          endDate = date;
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom du médicament est requis')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newMedication = Medication(
        id: medication?.id,
        name: nameController.text,
        dosage: dosageController.text.isEmpty ? null : dosageController.text,
        frequency: frequency,
        times: times,
        startDate: startDate ?? DateTime.now(),
        endDate: endDate,
        notes: notesController.text.isEmpty ? null : notesController.text,
      );

      try {
        if (medication == null) {
          await _medicationService.insertMedication(newMedication);
        } else {
          await _medicationService.updateMedication(newMedication);
        }
        _loadMedications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(medication == null
                  ? 'Médicament ajouté'
                  : 'Médicament modifié'),
            ),
          );
        }
      } catch (e) {
        _showError('Erreur lors de l\'enregistrement: $e');
      }
    }
  }

  Future<void> _markAsTaken(Medication medication, TimeOfDay time) async {
    try {
      await _medicationService.markAsTaken(
        medication.id!,
        _selectedDate,
        time,
      );
      _loadMedications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Médicament marqué comme pris')),
        );
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  Future<void> _showTrackingChart(Medication medication) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final tracking = await _medicationService.getMedicationTracking(
      medication.id!,
      weekAgo,
      now,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suivi: ${medication.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pris: ${tracking['taken']}/${tracking['total']}'),
            Text('Taux de conformité: ${tracking['percentage']}%'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: tracking['percentage'] / 100,
              minHeight: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMedications = _medications.where((m) => m.isActiveOnDate(_selectedDate)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💊 Rappels Médicaments'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditMedicationDialog(),
            tooltip: 'Ajouter un médicament',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sélecteur de date
                Card(
                  margin: const EdgeInsets.all(16),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date sélectionnée'),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                    ),
                  ),
                ),
                // Liste des médicaments
                Expanded(
                  child: activeMedications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.medication, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun médicament actif',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showAddEditMedicationDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un médicament'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: activeMedications.length,
                          itemBuilder: (context, index) {
                            final medication = activeMedications[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ExpansionTile(
                                leading: const Icon(Icons.medication, color: Colors.blue),
                                title: Text(medication.name),
                                subtitle: Text(
                                  medication.dosage ?? 'Sans dosage spécifié',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.bar_chart),
                                      onPressed: () => _showTrackingChart(medication),
                                      tooltip: 'Voir le suivi',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showAddEditMedicationDialog(
                                        medication: medication,
                                      ),
                                      tooltip: 'Modifier',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Supprimer'),
                                            content: Text(
                                              'Supprimer ${medication.name} ?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Annuler'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true && medication.id != null) {
                                          await _medicationService.deleteMedication(medication.id!);
                                          _loadMedications();
                                        }
                                      },
                                      tooltip: 'Supprimer',
                                    ),
                                  ],
                                ),
                                children: medication.times.map((time) {
                                  return FutureBuilder<bool>(
                                    future: _isMedicationTaken(medication.id!, DateTime.now(), time),
                                    builder: (context, snapshot) {
                                      return MedicationReminderWidget(
                                        medication: medication,
                                        time: time,
                                        isTaken: snapshot.data ?? false,
                                        onTaken: () => _markAsTaken(medication, time),
                                        onIgnore: () {},
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

