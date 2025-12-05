import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/calendar_service.dart';
import '../services/local_storage_service.dart';

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
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String? recurrenceType; // null = pas de récurrence

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau rappel'),
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
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'reminder_date': selectedDate.toIso8601String(),
                    'recurrence': recurrenceType,
                  });
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _createReminder(result);
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
          await CalendarService.addReminder(
            title: reminderData['title'],
            description: reminderData['description'],
            reminderDate: DateTime.parse(reminderData['reminder_date']),
            recurrence: reminderData['recurrence'] as String?,
          );
        } catch (e) {
          // Ignorer les erreurs de calendrier, on a déjà sauvegardé localement
        }
      }

      _showSuccess('Rappel créé avec succès !');
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reminders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun rappel',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Appuyez sur + pour créer un rappel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                        leading: Icon(
                          isCompleted ? Icons.check_circle : Icons.schedule,
                          color: isCompleted ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        title: Text(
                          reminder['title'] ?? 'Rappel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reminder['description'] != null)
                              Text(reminder['description']),
                            Text(
                              _formatDateTime(reminder['reminder_date'] ?? ''),
                              style: TextStyle(
                                color: isCompleted ? Colors.grey : Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: isCompleted
                            ? const Icon(Icons.check, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () async {
                                  await _markReminderComplete(reminder['id']);
                                },
                              ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
