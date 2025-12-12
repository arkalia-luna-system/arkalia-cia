import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/calendar_service.dart';
import '../services/doctor_service.dart';
import '../services/medication_service.dart';
import '../models/doctor.dart'; // Contient aussi Consultation

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
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  List<Map<String, dynamic>> _selectedEvents = [];
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
      final eventsMap = <DateTime, List<Map<String, dynamic>>>{};

      // Pour chaque médecin, récupérer ses consultations
      for (final doctor in doctors) {
        if (doctor.id == null) continue;

        final consultations = await _doctorService.getConsultationsByDoctor(doctor.id!);
        for (final consultation in consultations) {
          final date = DateTime(
            consultation.date.year,
            consultation.date.month,
            consultation.date.day,
          );

          if (!eventsMap.containsKey(date)) {
            eventsMap[date] = [];
          }

          eventsMap[date]!.add({
            'type': 'consultation',
            'doctor': doctor,
            'consultation': consultation,
            'color': Doctor.getColorForSpecialty(doctor.specialty),
          });
        }
      }

      // Récupérer les médicaments actifs
      final medications = await _medicationService.getActiveMedications();
      for (final medication in medications) {
        for (final time in medication.times) {
          final reminderDate = DateTime(
            _focusedDay.year,
            _focusedDay.month,
            _focusedDay.day,
            time.hour,
            time.minute,
          );
          final dateOnly = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);

          if (!eventsMap.containsKey(dateOnly)) {
            eventsMap[dateOnly] = [];
          }

          eventsMap[dateOnly]!.add({
            'type': 'medication',
            'medication': medication,
            'time': time,
            'title': '💊 ${medication.name}',
            'description': medication.dosage ?? 'Médicament',
            'color': Colors.blue,
          });
        }
      }

      // Récupérer les rappels d'hydratation (toutes les 2h de 8h à 20h)
      for (int hour = 8; hour <= 20; hour += 2) {
        final reminderDate = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, hour, 0);
        final dateOnly = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);

        if (!eventsMap.containsKey(dateOnly)) {
          eventsMap[dateOnly] = [];
        }

        eventsMap[dateOnly]!.add({
          'type': 'hydration',
          'title': '💧 Hydratation',
          'description': 'N\'oubliez pas de boire de l\'eau !',
          'color': Colors.cyan,
        });
      }

      // Récupérer aussi les rappels du calendrier système
      final reminders = await CalendarService.getUpcomingReminders();
      for (final reminder in reminders) {
        final dateStr = reminder['reminder_date'] as String?;
        if (dateStr != null) {
          try {
            final date = DateTime.parse(dateStr);
            final dateOnly = DateTime(date.year, date.month, date.day);

            if (!eventsMap.containsKey(dateOnly)) {
              eventsMap[dateOnly] = [];
            }

            // Détecter le type de rappel par le titre
            final title = reminder['title'] as String? ?? 'Rappel';
            final isMedication = title.contains('💊');
            final isHydration = title.contains('💧');

            eventsMap[dateOnly]!.add({
              'type': isMedication ? 'medication' : (isHydration ? 'hydration' : 'reminder'),
              'title': title,
              'description': reminder['description'] as String? ?? '',
              'color': isMedication ? Colors.blue : (isHydration ? Colors.cyan : Colors.orange),
            });
          } catch (e) {
            // Ignorer dates invalides
          }
        }
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
        _showError('Erreur lors du chargement: $e');
      }
    }
  }

  void _updateSelectedEvents() {
    _selectedEvents = _events[_selectedDay] ?? [];
  }

  List<Color> _getEventColors(DateTime day) {
    final events = _events[day] ?? [];
    return events.map((e) => e['color'] as Color).toList();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Calendrier'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
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
          TableCalendar<Map<String, dynamic>>(
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
                color: Colors.blue.withValues(alpha:0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
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
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                final colors = _getEventColors(date);
                if (colors.isEmpty) return const SizedBox.shrink();

                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: colors.take(3).map((color) {
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

          // Liste des événements sélectionnés
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEvents,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedEvents.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun événement ce jour',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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


  Widget _buildEventCard(Map<String, dynamic> event) {
    final color = event['color'] as Color;
    final type = event['type'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: double.infinity,
              color: color,
            ),
            const SizedBox(width: 8),
            Icon(
              type == 'consultation'
                  ? Icons.medical_services
                  : type == 'medication'
                      ? Icons.medication
                      : type == 'hydration'
                          ? Icons.water_drop
                          : Icons.notifications,
              color: color,
            ),
          ],
        ),
        title: Text(
          type == 'consultation'
              ? 'Consultation: ${(event['doctor'] as Doctor).fullName}'
              : event['title'] as String? ?? 'Rappel',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: type == 'consultation'
            ? _buildConsultationSubtitle(event)
            : Text(event['description'] as String? ?? ''),
        onTap: () {
          _showEventDetails(event);
        },
      ),
    );
  }

  Widget _buildConsultationSubtitle(Map<String, dynamic> event) {
    final doctor = event['doctor'] as Doctor;
    final consultation = event['consultation'] as Consultation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (doctor.specialty != null)
          Text('Spécialité: ${doctor.specialty}'),
        if (doctor.address != null)
          Text('Adresse: ${doctor.address}'),
        if (consultation.reason != null)
          Text('Raison: ${consultation.reason}'),
      ],
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          event['type'] == 'consultation'
              ? 'Consultation'
              : event['title'] as String? ?? 'Rappel',
        ),
        content: event['type'] == 'consultation'
            ? _buildConsultationDetails(event)
            : Text(event['description'] as String? ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationDetails(Map<String, dynamic> event) {
    final doctor = event['doctor'] as Doctor;
    final consultation = event['consultation'] as Consultation;

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
