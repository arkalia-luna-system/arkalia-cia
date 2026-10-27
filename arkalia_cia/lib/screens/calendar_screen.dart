import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/calendar_service.dart';
import '../services/doctor_service.dart';
import '../services/medication_service.dart';
import '../services/local_storage_service.dart';
import '../models/doctor.dart'; // Contient aussi Consultation
import '../utils/input_sanitizer.dart';
import '../utils/error_helper.dart';
import '../widgets/senior_empty_state.dart';

/// Événement calendrier typé (réduit le hotspot Map/dynamic côté UI).
class _CalendarEvent {
  const _CalendarEvent({
    required this.type,
    required this.color,
    this.title,
    this.description,
    this.doctor,
    this.consultation,
  });

  final String type;
  final Color color;
  final String? title;
  final String? description;
  final Doctor? doctor;
  final Consultation? consultation;
}

/// Écran calendrier avec affichage des rappels médicaments et hydratation
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DoctorService _doctorService = DoctorService();
  final MedicationService _medicationService = MedicationService();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<_CalendarEvent>> _events = {};
  List<_CalendarEvent> _selectedEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer tous les médecins
      final doctors = await _doctorService.getAllDoctors();
      final eventsMap = <DateTime, List<_CalendarEvent>>{};

      // Pour chaque médecin, récupérer ses consultations
      for (final doctor in doctors) {
        if (doctor.id == null) continue;

        final consultations = await _doctorService.getConsultationsByDoctor(
          doctor.id!,
        );
        for (final consultation in consultations) {
          final date = DateTime(
            consultation.date.year,
            consultation.date.month,
            consultation.date.day,
          );

          eventsMap
              .putIfAbsent(date, () => [])
              .add(
                _CalendarEvent(
                  type: 'consultation',
                  doctor: doctor,
                  consultation: consultation,
                  color: Doctor.getColorForSpecialty(doctor.specialty),
                ),
              );
        }
      }

      // Récupérer les médicaments actifs
      // Charger pour tous les jours du mois visible (pas seulement _focusedDay)
      final medications = await _medicationService.getActiveMedications();
      final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // Charger les médicaments pour tous les jours du mois visible
      for (int day = 1; day <= monthEnd.day; day++) {
        final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
        for (final medication in medications) {
          for (final time in medication.times) {
            final dateOnly = DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
            );
            final dosage = medication.dosage ?? 'Médicament';
            final hh = time.hour.toString().padLeft(2, '0');
            final mm = time.minute.toString().padLeft(2, '0');

            eventsMap
                .putIfAbsent(dateOnly, () => [])
                .add(
                  _CalendarEvent(
                    type: 'medication',
                    title: medication.name,
                    description: '$dosage · $hh:$mm',
                    color: Colors.blue,
                  ),
                );
          }
        }
      }

      // Récupérer les rappels d'hydratation (toutes les 2h de 8h à 20h)
      // Charger pour tous les jours du mois visible
      for (int day = 1; day <= monthEnd.day; day++) {
        final currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
        for (int hour = 8; hour <= 20; hour += 2) {
          final dateOnly = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
          );

          eventsMap
              .putIfAbsent(dateOnly, () => [])
              .add(
                const _CalendarEvent(
                  type: 'hydration',
                  title: 'Hydratation',
                  description: 'N\'oubliez pas de boire de l\'eau !',
                  color: Colors.cyan,
                ),
              );
        }
      }

      // Récupérer les rappels depuis LocalStorageService (rappels locaux)
      final localReminders = await LocalStorageService.getReminders();
      for (final reminder in localReminders) {
        try {
          final reminderDateStr = reminder['reminder_date'] as String?;
          if (reminderDateStr == null || reminderDateStr.isEmpty) continue;

          final reminderDate = DateTime.parse(reminderDateStr);
          final dateOnly = DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
          );

          // Ne charger que les rappels du mois visible
          if (dateOnly.year == _focusedDay.year &&
              dateOnly.month == _focusedDay.month) {
            // Ne pas afficher les rappels terminés dans le calendrier
            final isCompleted = reminder['is_completed'] == true;
            if (!isCompleted) {
              eventsMap
                  .putIfAbsent(dateOnly, () => [])
                  .add(
                    _CalendarEvent(
                      type: 'reminder',
                      title: reminder['title'] as String? ?? 'Rappel',
                      description: reminder['description'] as String? ?? '',
                      color: Colors.orange,
                    ),
                  );
            }
          }
        } catch (e) {
          // Ignorer les rappels avec date invalide
          continue;
        }
      }

      // Récupérer aussi les rappels du calendrier système
      // Ajouter un timeout pour éviter les blocages
      try {
        final calendarReminders = await CalendarService.getUpcomingReminders()
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () => <Map<String, dynamic>>[],
            );
        for (final reminder in calendarReminders) {
          final dateStr = reminder['reminder_date'] as String?;
          if (dateStr != null) {
            try {
              final date = DateTime.parse(dateStr);
              final dateOnly = DateTime(date.year, date.month, date.day);

              // Ne charger que les rappels du mois visible
              if (dateOnly.year == _focusedDay.year &&
                  dateOnly.month == _focusedDay.month) {
                // Détecter le type de rappel par le titre
                final title = reminder['title'] as String? ?? 'Rappel';
                final isMedication = title.contains('💊');
                final isHydration = title.contains('💧');

                eventsMap
                    .putIfAbsent(dateOnly, () => [])
                    .add(
                      _CalendarEvent(
                        type:
                            isMedication
                                ? 'medication'
                                : (isHydration ? 'hydration' : 'reminder'),
                        title: title,
                        description: reminder['description'] as String? ?? '',
                        color:
                            isMedication
                                ? Colors.blue
                                : (isHydration ? Colors.cyan : Colors.orange),
                      ),
                    );
              }
            } catch (e) {
              // Ignorer dates invalides
            }
          }
        }
      } catch (e) {
        // Ignorer erreurs calendrier système
      }

      if (mounted) {
        setState(() {
          _events = eventsMap;
          _updateSelectedEvents();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ErrorHelper.logError('CalendarScreen', e);
        _showError(ErrorHelper.getUserFriendlyMessage(e));
      }
    }
  }

  void _updateSelectedEvents() {
    _selectedEvents = _events[_selectedDay] ?? [];
  }

  List<Color> _getEventColors(DateTime day) {
    final events = _events[day] ?? [];
    return events.map((e) => e.color).toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: scheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Calendrier'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendrier
          TableCalendar<_CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _events[day] ?? [],
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: scheme.error,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 6,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _updateSelectedEvents();
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                // Recharger les événements pour le nouveau mois
                _loadEvents();
              });
            },
            calendarBuilders: CalendarBuilders<_CalendarEvent>(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                final colors = _getEventColors(date);
                if (colors.isEmpty) return const SizedBox.shrink();

                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        colors.take(3).map((color) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),

          // Légende simple pour aider à comprendre les couleurs/icônes
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Légende :  ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 18, color: Colors.red),
                    SizedBox(width: 4),
                    Text('Consultation  ', style: TextStyle(fontSize: 14)),
                    Icon(Icons.medication, size: 18, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('Médicament  ', style: TextStyle(fontSize: 14)),
                    Icon(Icons.water_drop, size: 18, color: Colors.cyan),
                    SizedBox(width: 4),
                    Text('Hydratation', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          // Liste des événements sélectionnés
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEvents,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _selectedEvents.isEmpty
                      ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: const SeniorEmptyState(
                            icon: Icons.event_busy,
                            title: 'Aucun événement ce jour',
                            message:
                                'Appuyez sur un jour avec des petits points colorés pour voir vos rendez-vous et rappels.',
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _selectedEvents.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(_selectedEvents[index]);
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(_CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 4, height: double.infinity, color: event.color),
            const SizedBox(width: 8),
            Icon(
              event.type == 'consultation'
                  ? Icons.medical_services
                  : event.type == 'medication'
                  ? Icons.medication
                  : event.type == 'hydration'
                  ? Icons.water_drop
                  : Icons.notifications,
              color: event.color,
            ),
          ],
        ),
        title: Text(
          event.type == 'consultation'
              ? 'Consultation: ${event.doctor!.fullName}'
              : event.title ?? 'Rappel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            event.type == 'consultation'
                ? _buildConsultationSubtitle(event)
                : Text(
                  // Sanitizer à l'affichage pour prévenir XSS
                  InputSanitizer.sanitize(event.description ?? ''),
                ),
        onTap: () {
          _showEventDetails(event);
        },
      ),
    );
  }

  Widget _buildConsultationSubtitle(_CalendarEvent event) {
    final doctor = event.doctor!;
    final consultation = event.consultation!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (doctor.specialty != null) Text('Spécialité: ${doctor.specialty}'),
        if (doctor.address != null) Text('Adresse: ${doctor.address}'),
        if (consultation.reason != null) Text('Raison: ${consultation.reason}'),
      ],
    );
  }

  void _showEventDetails(_CalendarEvent event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              event.type == 'consultation'
                  ? 'Consultation'
                  : event.title ?? 'Rappel',
            ),
            content:
                event.type == 'consultation'
                    ? _buildConsultationDetails(event)
                    : Text(
                      // Sanitizer à l'affichage pour prévenir XSS
                      InputSanitizer.sanitize(event.description ?? ''),
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

  Widget _buildConsultationDetails(_CalendarEvent event) {
    final doctor = event.doctor!;
    final consultation = event.consultation!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Médecin: ${doctor.fullName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (doctor.specialty != null) ...[
            const SizedBox(height: 8),
            Text('Spécialité: ${doctor.specialty}'),
          ],
          if (doctor.address != null) ...[
            const SizedBox(height: 8),
            Text('Adresse: ${doctor.address}'),
            if (doctor.city != null)
              Text('${doctor.city} ${doctor.postalCode ?? ''}'),
          ],
          if (doctor.phone != null) ...[
            const SizedBox(height: 8),
            Text('Téléphone: ${doctor.phone}'),
          ],
          if (doctor.email != null) ...[
            const SizedBox(height: 8),
            Text('Email: ${doctor.email}'),
          ],
          const SizedBox(height: 16),
          Text(
            'Date: ${consultation.date.day}/${consultation.date.month}/${consultation.date.year}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (consultation.reason != null) ...[
            const SizedBox(height: 8),
            Text('Raison: ${consultation.reason}'),
          ],
          if (consultation.notes != null) ...[
            const SizedBox(height: 8),
            Text('Notes: ${consultation.notes}'),
          ],
          if (consultation.documentIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Documents: ${consultation.documentIds.length} document(s)'),
          ],
        ],
      ),
    );
  }
}
