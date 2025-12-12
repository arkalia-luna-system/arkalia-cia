import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/calendar_service.dart';
import '../services/local_storage_service.dart';
import 'medication_reminders_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Map<String, dynamic>> reminders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      // Charger depuis le stockage local
      final localReminders = await LocalStorageService.getReminders();
      
      // Essayer de charger depuis le calendrier natif (mobile seulement)
      List<Map<String, dynamic>> calendarReminders = [];
      if (!kIsWeb) {
        try {
          final calendarEvents = await CalendarService.getUpcomingReminders();
          // Convertir les événements calendrier en format local
          calendarReminders = calendarEvents.map((event) => {
            'id': event['id'] ?? '',
            'title': (event['title'] ?? '').replaceFirst('[Santé] ', ''),
            'description': event['description'] ?? '',
            'reminder_date': event['reminder_date'] ?? '',
            'is_completed': false,
            'source': 'calendar',
          }).toList();
        } catch (e) {
          // Ignorer les erreurs de calendrier, on a déjà les rappels locaux
        }
      }

      if (mounted) {
        setState(() {
          reminders = [...localReminders, ...calendarReminders];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showError('Erreur lors du chargement des rappels: $e');
      }
    }
  }

  Future<void> _showAddReminderDialog() async {
    await _showReminderDialog();
  }

  Future<void> _showEditReminderDialog(Map<String, dynamic> reminder) async {
    await _showReminderDialog(reminder: reminder);
  }

  Future<void> _showReminderDialog({Map<String, dynamic>? reminder}) async {
    final isEditing = reminder != null;
    final titleController = TextEditingController(text: reminder?['title'] ?? '');
    final descriptionController = TextEditingController(text: reminder?['description'] ?? '');
    DateTime selectedDate = reminder != null && reminder['reminder_date'] != null
        ? DateTime.parse(reminder['reminder_date'])
        : DateTime.now().add(const Duration(days: 1));
    String? recurrenceType = reminder?['recurrence'] as String?; // null = pas de récurrence

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Modifier le rappel' : 'Nouveau rappel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre du rappel',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date du rappel'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Heure du rappel'),
                  subtitle: Text(
                    '${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Utiliser MenuAnchor au lieu de DropdownButtonFormField (API moderne Flutter)
                MenuAnchor(
                  builder: (context, controller, child) {
                    return ListTile(
                      title: const Text('Récurrence (optionnel)'),
                      subtitle: Text(
                        recurrenceType == null
                            ? 'Aucune récurrence'
                            : recurrenceType == 'daily'
                                ? 'Quotidien'
                                : recurrenceType == 'weekly'
                                    ? 'Hebdomadaire'
                                    : 'Mensuel',
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      },
                    );
                  },
                  menuChildren: [
                    MenuItemButton(
                      child: const Text('Aucune récurrence'),
                      onPressed: () {
                        setDialogState(() {
                          recurrenceType = null;
                        });
                      },
                    ),
                    MenuItemButton(
                      child: const Text('Quotidien'),
                      onPressed: () {
                        setDialogState(() {
                          recurrenceType = 'daily';
                        });
                      },
                    ),
                    MenuItemButton(
                      child: const Text('Hebdomadaire'),
                      onPressed: () {
                        setDialogState(() {
                          recurrenceType = 'weekly';
                        });
                      },
                    ),
                    MenuItemButton(
                      child: const Text('Mensuel'),
                      onPressed: () {
                        setDialogState(() {
                          recurrenceType = 'monthly';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'id': reminder?['id'],
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'reminder_date': selectedDate.toIso8601String(),
                    'recurrence': recurrenceType,
                    'is_editing': isEditing,
                  });
                }
              },
              child: Text(isEditing ? 'Modifier' : 'Créer'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (result['is_editing'] == true) {
        await _updateReminder(result);
      } else {
        await _createReminder(result);
      }
    }
  }

  Future<void> _createReminder(Map<String, dynamic> reminderData) async {
    try {
      // Créer le rappel
      final reminder = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': reminderData['title'],
        'description': reminderData['description'],
        'reminder_date': reminderData['reminder_date'],
        'recurrence': reminderData['recurrence'],
        'is_completed': false,
        'source': 'local',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Sauvegarder localement (fonctionne sur web et mobile)
      await LocalStorageService.saveReminder(reminder);
      
      // Essayer d'ajouter au calendrier natif (mobile seulement)
      if (!kIsWeb) {
        try {
          // Vérifier les permissions avant d'ajouter
          final hasPermission = await CalendarService.hasCalendarPermission();
          if (!hasPermission) {
            final permissionGranted = await CalendarService.requestCalendarPermission();
            if (!permissionGranted) {
              // Permission refusée, on continue quand même avec le stockage local
              _showError('Permission calendrier refusée. Le rappel est sauvegardé localement uniquement.');
            }
          }
          
          // Ajouter au calendrier si permission accordée
          if (hasPermission || await CalendarService.hasCalendarPermission()) {
            await CalendarService.addReminder(
              title: reminderData['title'],
              description: reminderData['description'],
              reminderDate: DateTime.parse(reminderData['reminder_date']),
              recurrence: reminderData['recurrence'] as String?,
            );
          }
        } catch (e) {
          // Ignorer les erreurs de calendrier, on a déjà sauvegardé localement
          _showError('Erreur lors de l\'ajout au calendrier: $e');
        }
      }

      _showSuccess('Rappel créé avec succès !');
      _loadReminders();
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  /// Met à jour un rappel existant
  Future<void> _updateReminder(Map<String, dynamic> reminderData) async {
    try {
      final reminderId = reminderData['id']?.toString();
      if (reminderId == null) {
        _showError('ID du rappel introuvable');
        return;
      }

      // Récupérer le rappel existant pour préserver les champs non modifiés
      final existingReminders = await LocalStorageService.getReminders();
      final existingReminder = existingReminders.firstWhere(
        (r) => r['id']?.toString() == reminderId,
        orElse: () => {},
      );

      if (existingReminder.isEmpty) {
        _showError('Rappel introuvable');
        return;
      }

      // Mettre à jour le rappel
      final updatedReminder = {
        ...existingReminder,
        'title': reminderData['title'],
        'description': reminderData['description'],
        'reminder_date': reminderData['reminder_date'],
        'recurrence': reminderData['recurrence'],
        'updated_at': DateTime.now().toIso8601String(),
      };

      await LocalStorageService.updateReminder(updatedReminder);

      // Mettre à jour dans le calendrier natif (mobile seulement)
      if (!kIsWeb) {
        try {
          // Note: device_calendar ne permet pas de modifier facilement un événement
          // On supprime l'ancien et on crée le nouveau
          // Pour simplifier, on ne fait que mettre à jour localement
          // L'utilisateur devra recréer dans le calendrier si nécessaire
        } catch (e) {
          // Ignorer les erreurs de calendrier
        }
      }

      _showSuccess('Rappel modifié avec succès !');
      _loadReminders();
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  /// Marque un rappel comme terminé
  Future<void> _markReminderComplete(String? reminderId) async {
    if (reminderId == null) return;

    try {
      await LocalStorageService.markReminderComplete(reminderId);
      await _loadReminders();
      _showSuccess('Rappel marqué comme terminé');
    } catch (e) {
      _showError('Erreur lors de la mise à jour: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappels'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.medication),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicationRemindersScreen(),
                ),
              );
            },
            tooltip: 'Rappels médicaments',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReminders,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : reminders.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha:0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun rappel',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Appuyez sur + pour créer un rappel',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final isCompleted = reminder['is_completed'] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          isCompleted ? Icons.check_circle : Icons.schedule,
                          color: isCompleted ? Colors.green : Colors.orange,
                          size: 40,
                        ),
                        title: Text(
                          reminder['title'] ?? 'Rappel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reminder['description'] != null)
                                Text(
                                  reminder['description'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              if (reminder['description'] != null)
                                const SizedBox(height: 4),
                              Text(
                                _formatDateTime(reminder['reminder_date'] ?? ''),
                                style: TextStyle(
                                  color: isCompleted ? Colors.grey : Colors.orange[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: isCompleted
                            ? const Icon(Icons.check, color: Colors.green, size: 24)
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 24),
                                    onPressed: () async {
                                      await _showEditReminderDialog(reminder);
                                    },
                                    tooltip: 'Modifier',
                                    constraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline, size: 24),
                                    onPressed: () async {
                                      await _markReminderComplete(reminder['id']);
                                    },
                                    tooltip: 'Marquer comme terminé',
                                    constraints: const BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
