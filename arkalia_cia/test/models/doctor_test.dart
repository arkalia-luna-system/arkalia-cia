import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:arkalia_cia/models/doctor.dart';

void main() {
  group('Doctor', () {
    test('should create doctor with required fields', () {
      final doctor = Doctor(
        firstName: 'Jean',
        lastName: 'Dupont',
      );

      expect(doctor.firstName, 'Jean');
      expect(doctor.lastName, 'Dupont');
      expect(doctor.fullName, 'Jean Dupont');
      expect(doctor.country, 'Belgique');
      expect(doctor.createdAt, isNotNull);
      expect(doctor.updatedAt, isNotNull);
    });

    test('fullName should return first and last name', () {
      final doctor = Doctor(
        firstName: 'Marie',
        lastName: 'Martin',
      );

      expect(doctor.fullName, 'Marie Martin');
    });

    test('getColorForSpecialty should return correct colors', () {
      expect(Doctor.getColorForSpecialty('Cardiologue'), Colors.red);
      expect(Doctor.getColorForSpecialty('Dermatologue'), Colors.orange);
      expect(Doctor.getColorForSpecialty('Gynécologue'), Colors.pink);
      expect(Doctor.getColorForSpecialty('Ophtalmologue'), Colors.blue);
      expect(Doctor.getColorForSpecialty('Orthopédiste'), Colors.brown);
      expect(Doctor.getColorForSpecialty('Pneumologue'), Colors.cyan);
      expect(Doctor.getColorForSpecialty('Rhumatologue'), Colors.purple);
      expect(Doctor.getColorForSpecialty('Neurologue'), Colors.indigo);
      expect(Doctor.getColorForSpecialty('Médecin général'), Colors.green);
      expect(Doctor.getColorForSpecialty('Pédiatre'), Colors.lightBlue);
      expect(Doctor.getColorForSpecialty('Psychiatre'), Colors.teal);
      expect(Doctor.getColorForSpecialty('Urologue'), Colors.deepOrange);
      expect(Doctor.getColorForSpecialty('Endocrinologue'), Colors.amber);
    });

    test('getColorForSpecialty should return grey for unknown specialty', () {
      expect(Doctor.getColorForSpecialty('Unknown Specialty'), Colors.grey);
      expect(Doctor.getColorForSpecialty(null), Colors.grey);
      expect(Doctor.getColorForSpecialty(''), Colors.grey);
    });

    test('toMap should convert doctor to map', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 1, 2);
      final doctor = Doctor(
        id: 1,
        firstName: 'Jean',
        lastName: 'Dupont',
        specialty: 'Cardiologue',
        phone: '0412345678',
        email: 'jean@example.com',
        address: 'Rue de la Paix',
        city: 'Bruxelles',
        postalCode: '1000',
        country: 'Belgique',
        notes: 'Notes',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = doctor.toMap();

      expect(map['id'], 1);
      expect(map['first_name'], 'Jean');
      expect(map['last_name'], 'Dupont');
      expect(map['specialty'], 'Cardiologue');
      expect(map['phone'], '0412345678');
      expect(map['email'], 'jean@example.com');
      expect(map['address'], 'Rue de la Paix');
      expect(map['city'], 'Bruxelles');
      expect(map['postal_code'], '1000');
      expect(map['country'], 'Belgique');
      expect(map['notes'], 'Notes');
      expect(map['created_at'], createdAt.toIso8601String());
      expect(map['updated_at'], updatedAt.toIso8601String());
    });

    test('fromMap should create doctor from map', () {
      final map = {
        'id': 1,
        'first_name': 'Jean',
        'last_name': 'Dupont',
        'specialty': 'Cardiologue',
        'phone': '0412345678',
        'email': 'jean@example.com',
        'address': 'Rue de la Paix',
        'city': 'Bruxelles',
        'postal_code': '1000',
        'country': 'Belgique',
        'notes': 'Notes',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final doctor = Doctor.fromMap(map);

      expect(doctor.id, 1);
      expect(doctor.firstName, 'Jean');
      expect(doctor.lastName, 'Dupont');
      expect(doctor.specialty, 'Cardiologue');
      expect(doctor.phone, '0412345678');
      expect(doctor.email, 'jean@example.com');
      expect(doctor.address, 'Rue de la Paix');
      expect(doctor.city, 'Bruxelles');
      expect(doctor.postalCode, '1000');
      expect(doctor.country, 'Belgique');
      expect(doctor.notes, 'Notes');
    });

    test('copyWith should create modified copy', () {
      final original = Doctor(
        id: 1,
        firstName: 'Jean',
        lastName: 'Dupont',
        specialty: 'Cardiologue',
      );

      final modified = original.copyWith(
        firstName: 'Marie',
        specialty: 'Dermatologue',
      );

      expect(modified.id, 1);
      expect(modified.firstName, 'Marie');
      expect(modified.lastName, 'Dupont'); // Unchanged
      expect(modified.specialty, 'Dermatologue');
    });
  });

  group('Consultation', () {
    test('should create consultation with required fields', () {
      final consultation = Consultation(
        doctorId: 1,
        date: DateTime(2024, 1, 1),
      );

      expect(consultation.doctorId, 1);
      expect(consultation.date, DateTime(2024, 1, 1));
      expect(consultation.documentIds, isEmpty);
      expect(consultation.createdAt, isNotNull);
    });

    test('toMap should convert consultation to map', () {
      final consultation = Consultation(
        id: 1,
        doctorId: 2,
        date: DateTime(2024, 1, 1, 10, 0),
        reason: 'Check-up',
        notes: 'Notes',
        documentIds: [1, 2, 3],
        createdAt: DateTime(2024, 1, 1),
      );

      final map = consultation.toMap();

      expect(map['id'], 1);
      expect(map['doctor_id'], 2);
      expect(map['date'], '2024-01-01T10:00:00.000');
      expect(map['reason'], 'Check-up');
      expect(map['notes'], 'Notes');
      expect(map['documents'], '1,2,3');
      expect(map['created_at'], '2024-01-01T00:00:00.000');
    });

    test('fromMap should create consultation from map', () {
      final map = {
        'id': 1,
        'doctor_id': 2,
        'date': '2024-01-01T10:00:00.000',
        'reason': 'Check-up',
        'notes': 'Notes',
        'documents': '1,2,3',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final consultation = Consultation.fromMap(map);

      expect(consultation.id, 1);
      expect(consultation.doctorId, 2);
      expect(consultation.date, DateTime(2024, 1, 1, 10, 0));
      expect(consultation.reason, 'Check-up');
      expect(consultation.notes, 'Notes');
      expect(consultation.documentIds, [1, 2, 3]);
    });

    test('fromMap should handle empty documents', () {
      final map = {
        'id': 1,
        'doctor_id': 2,
        'date': '2024-01-01T10:00:00.000',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final consultation = Consultation.fromMap(map);

      expect(consultation.documentIds, isEmpty);
    });
  });
}

