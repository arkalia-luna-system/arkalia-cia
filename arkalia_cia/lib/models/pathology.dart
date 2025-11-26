import 'package:flutter/material.dart';
import 'dart:convert';

/// Configuration pour un rappel spécifique à une pathologie
class ReminderConfig {
  final String type; // 'exam', 'medication', 'therapy', etc.
  final String frequency; // 'daily', 'weekly', 'monthly', 'custom'
  final List<String> times; // Heures de rappel (ex: ['08:00', '20:00'])

  ReminderConfig({
    required this.type,
    required this.frequency,
    List<String>? times,
  }) : times = times ?? [];

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'frequency': frequency,
      'times': times,
    };
  }

  factory ReminderConfig.fromMap(Map<String, dynamic> map) {
    return ReminderConfig(
      type: map['type'] ?? '',
      frequency: map['frequency'] ?? 'daily',
      times: map['times'] != null
          ? List<String>.from(map['times'])
          : [],
    );
  }
}

/// Modèle représentant une pathologie médicale
class Pathology {
  final int? id;
  final String name;
  final String? description;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> exams;
  final Map<String, ReminderConfig> reminders;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pathology({
    this.id,
    required this.name,
    this.description,
    List<String>? symptoms,
    List<String>? treatments,
    List<String>? exams,
    Map<String, ReminderConfig>? reminders,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : symptoms = symptoms ?? [],
       treatments = treatments ?? [],
       exams = exams ?? [],
       reminders = reminders ?? {},
       color = color ?? Colors.blue,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'symptoms': symptoms.join(','),
      'treatments': treatments.join(','),
      'exams': exams.join(','),
      'reminders': reminders.map((key, value) => MapEntry(key, value.toMap())),
      'color': color.toARGB32(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Pathology.fromMap(Map<String, dynamic> map) {
    final remindersMap = <String, ReminderConfig>{};
    if (map['reminders'] != null) {
      // Gérer le cas où reminders est une String JSON (web) ou un Map (mobile)
      Map<String, dynamic> remindersData;
      if (map['reminders'] is String) {
        try {
          remindersData = json.decode(map['reminders'] as String) as Map<String, dynamic>;
        } catch (e) {
          remindersData = {};
        }
      } else if (map['reminders'] is Map) {
        remindersData = Map<String, dynamic>.from(map['reminders'] as Map);
      } else {
        remindersData = {};
      }
      
      remindersData.forEach((key, value) {
        try {
          remindersMap[key] = ReminderConfig.fromMap(
            Map<String, dynamic>.from(value),
          );
        } catch (e) {
          // Ignorer les erreurs de conversion
        }
      });
    }

    return Pathology(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'],
      symptoms: map['symptoms'] != null
          ? (map['symptoms'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      treatments: map['treatments'] != null
          ? (map['treatments'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      exams: map['exams'] != null
          ? (map['exams'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      reminders: remindersMap,
      color: map['color'] != null
          ? Color.fromARGB(
              (map['color'] as int) >> 24 & 0xFF,
              (map['color'] as int) >> 16 & 0xFF,
              (map['color'] as int) >> 8 & 0xFF,
              (map['color'] as int) & 0xFF,
            )
          : Colors.blue,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Pathology copyWith({
    int? id,
    String? name,
    String? description,
    List<String>? symptoms,
    List<String>? treatments,
    List<String>? exams,
    Map<String, ReminderConfig>? reminders,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pathology(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      treatments: treatments ?? this.treatments,
      exams: exams ?? this.exams,
      reminders: reminders ?? this.reminders,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

