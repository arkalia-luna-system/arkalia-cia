import 'package:flutter/material.dart';

/// Modèle représentant un médicament avec ses informations de posologie
class Medication {
  final int? id;
  final String name;
  final String? dosage;
  final String frequency; // 'daily', 'twice_daily', 'three_times_daily', 'four_times_daily', 'as_needed'
  final List<TimeOfDay> times; // Heures de prise
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  Medication({
    this.id,
    required this.name,
    this.dosage,
    this.frequency = 'daily',
    List<TimeOfDay>? times,
    DateTime? startDate,
    this.endDate,
    this.notes,
  }) : times = times ?? [const TimeOfDay(hour: 8, minute: 0)],
       startDate = startDate ?? DateTime.now();

  /// Convertit le médicament en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times.map((t) => '${t.hour}:${t.minute}').join(','),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Crée un médicament depuis un Map de la base de données
  factory Medication.fromMap(Map<String, dynamic> map) {
    List<TimeOfDay> parsedTimes = [];
    if (map['times'] != null && map['times'].toString().isNotEmpty) {
      final timeStrings = (map['times'] as String).split(',');
      parsedTimes = timeStrings.map((timeStr) {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList();
    } else {
      parsedTimes = [const TimeOfDay(hour: 8, minute: 0)];
    }

    return Medication(
      id: map['id'],
      name: map['name'] ?? '',
      dosage: map['dosage'],
      frequency: map['frequency'] ?? 'daily',
      times: parsedTimes,
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      notes: map['notes'],
    );
  }

  /// Crée une copie du médicament avec des modifications
  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    String? frequency,
    List<TimeOfDay>? times,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }

  /// Vérifie si le médicament est actif à une date donnée
  bool isActiveOnDate(DateTime date) {
    if (date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    return true;
  }
}

/// Modèle représentant une prise de médicament
class MedicationTaken {
  final int? id;
  final int medicationId;
  final DateTime date;
  final TimeOfDay time;
  final bool taken;
  final DateTime? takenAt;

  MedicationTaken({
    this.id,
    required this.medicationId,
    required this.date,
    required this.time,
    this.taken = false,
    this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medication_id': medicationId,
      'date': date.toIso8601String().split('T')[0], // Date seulement
      'time': '${time.hour}:${time.minute}',
      'taken': taken ? 1 : 0,
      'taken_at': takenAt?.toIso8601String(),
    };
  }

  factory MedicationTaken.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return MedicationTaken(
      id: map['id'],
      medicationId: map['medication_id'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      taken: map['taken'] == 1,
      takenAt: map['taken_at'] != null ? DateTime.parse(map['taken_at']) : null,
    );
  }
}

