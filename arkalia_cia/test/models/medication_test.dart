import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/models/medication.dart';

void main() {
  group('Medication', () {
    test('should create medication with required fields', () {
      final medication = Medication(name: 'Aspirine');

      expect(medication.name, 'Aspirine');
      expect(medication.frequency, 'daily');
      expect(medication.times, [const TimeOfDay(hour: 8, minute: 0)]);
      expect(medication.startDate, isNotNull);
    });

    test('toMap should convert medication to map', () {
      final medication = Medication(
        id: 1,
        name: 'Aspirine',
        dosage: '100mg',
        frequency: 'twice_daily',
        times: [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ],
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        notes: 'Take with food',
      );

      final map = medication.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Aspirine');
      expect(map['dosage'], '100mg');
      expect(map['frequency'], 'twice_daily');
      expect(map['times'], '8:0,20:0');
      expect(map['start_date'], '2024-01-01T00:00:00.000');
      expect(map['end_date'], '2024-12-31T00:00:00.000');
      expect(map['notes'], 'Take with food');
    });

    test('fromMap should create medication from map', () {
      final map = {
        'id': 1,
        'name': 'Aspirine',
        'dosage': '100mg',
        'frequency': 'twice_daily',
        'times': '8:0,20:0',
        'start_date': '2024-01-01T00:00:00.000',
        'end_date': '2024-12-31T00:00:00.000',
        'notes': 'Take with food',
      };

      final medication = Medication.fromMap(map);

      expect(medication.id, 1);
      expect(medication.name, 'Aspirine');
      expect(medication.dosage, '100mg');
      expect(medication.frequency, 'twice_daily');
      expect(medication.times.length, 2);
      expect(medication.times[0], const TimeOfDay(hour: 8, minute: 0));
      expect(medication.times[1], const TimeOfDay(hour: 20, minute: 0));
      expect(medication.startDate, DateTime(2024, 1, 1));
      expect(medication.endDate, DateTime(2024, 12, 31));
      expect(medication.notes, 'Take with food');
    });

    test('fromMap should handle empty times', () {
      final map = {
        'id': 1,
        'name': 'Aspirine',
        'start_date': '2024-01-01T00:00:00.000',
      };

      final medication = Medication.fromMap(map);

      expect(medication.times, [const TimeOfDay(hour: 8, minute: 0)]);
    });

    test('copyWith should create modified copy', () {
      final original = Medication(
        id: 1,
        name: 'Aspirine',
        dosage: '100mg',
      );

      final modified = original.copyWith(
        name: 'Paracétamol',
        dosage: '500mg',
      );

      expect(modified.id, 1);
      expect(modified.name, 'Paracétamol');
      expect(modified.dosage, '500mg');
      expect(modified.frequency, 'daily'); // Unchanged
    });

    test('isActiveOnDate should return true for active dates', () {
      final medication = Medication(
        name: 'Aspirine',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      );

      expect(medication.isActiveOnDate(DateTime(2024, 6, 1)), isTrue);
      expect(medication.isActiveOnDate(DateTime(2024, 1, 1)), isTrue);
      expect(medication.isActiveOnDate(DateTime(2024, 12, 31)), isTrue);
    });

    test('isActiveOnDate should return false for inactive dates', () {
      final medication = Medication(
        name: 'Aspirine',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      );

      expect(medication.isActiveOnDate(DateTime(2023, 12, 31)), isFalse);
      expect(medication.isActiveOnDate(DateTime(2025, 1, 1)), isFalse);
    });

    test('isActiveOnDate should return true when no endDate', () {
      final medication = Medication(
        name: 'Aspirine',
        startDate: DateTime(2024, 1, 1),
      );

      expect(medication.isActiveOnDate(DateTime(2025, 1, 1)), isTrue);
    });
  });

  group('MedicationTaken', () {
    test('should create medication taken', () {
      final taken = MedicationTaken(
        medicationId: 1,
        date: DateTime(2024, 1, 1),
        time: const TimeOfDay(hour: 8, minute: 0),
      );

      expect(taken.medicationId, 1);
      expect(taken.date, DateTime(2024, 1, 1));
      expect(taken.time, const TimeOfDay(hour: 8, minute: 0));
      expect(taken.taken, isFalse);
    });

    test('toMap should convert medication taken to map', () {
      final taken = MedicationTaken(
        id: 1,
        medicationId: 2,
        date: DateTime(2024, 1, 1),
        time: const TimeOfDay(hour: 8, minute: 0),
        taken: true,
        takenAt: DateTime(2024, 1, 1, 8, 5),
      );

      final map = taken.toMap();

      expect(map['id'], 1);
      expect(map['medication_id'], 2);
      expect(map['date'], '2024-01-01');
      expect(map['time'], '8:0');
      expect(map['taken'], 1);
      expect(map['taken_at'], '2024-01-01T08:05:00.000');
    });

    test('fromMap should create medication taken from map', () {
      final map = {
        'id': 1,
        'medication_id': 2,
        'date': '2024-01-01',
        'time': '8:0',
        'taken': 1,
        'taken_at': '2024-01-01T08:05:00.000',
      };

      final taken = MedicationTaken.fromMap(map);

      expect(taken.id, 1);
      expect(taken.medicationId, 2);
      expect(taken.date, DateTime(2024, 1, 1));
      expect(taken.time, const TimeOfDay(hour: 8, minute: 0));
      expect(taken.taken, isTrue);
      expect(taken.takenAt, DateTime(2024, 1, 1, 8, 5));
    });
  });
}

