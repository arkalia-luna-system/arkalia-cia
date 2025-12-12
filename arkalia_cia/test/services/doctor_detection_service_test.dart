import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/doctor_detection_service.dart';

void main() {
  group('DoctorDetectionService', () {
    test('detectDoctor détecte un médecin avec Dr.', () {
      const text = 'Consultation avec Dr. Jean Dupont, cardiologue';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNotNull);
      expect(result!['firstName'], 'Jean');
      expect(result['lastName'], 'Dupont');
      expect(result['specialty'], 'Cardiologue');
    });

    test('detectDoctor détecte un médecin avec Docteur', () {
      const text = 'Rendez-vous avec Docteur Marie Martin';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNotNull);
      expect(result!['firstName'], 'Marie');
      expect(result['lastName'], 'Martin');
    });

    test('detectDoctor détecte un médecin avec Pr.', () {
      const text = 'Consultation Pr. Pierre Dubois, neurologue';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNotNull);
      expect(result!['firstName'], 'Pierre');
      expect(result['lastName'], 'Dubois');
      expect(result['specialty'], 'Neurologue');
    });

    test('detectDoctor détecte une spécialité sans nom', () {
      const text = 'Consultation avec un dermatologue';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNull); // Pas de nom, donc null
    });

    test('detectDoctor retourne null si aucun médecin détecté', () {
      const text = 'Document médical standard sans médecin mentionné';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNull);
    });

    test('detectDoctor gère les noms avec accents', () {
      const text = 'Dr. François Müller, rhumatologue';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNotNull);
      expect(result!['firstName'], 'François');
      expect(result['lastName'], 'Müller');
      expect(result['specialty'], 'Rhumatologue');
    });

    test('detectDoctor détecte plusieurs spécialités (prend la première)', () {
      const text = 'Dr. Sophie Bernard, gynécologue et endocrinologue';
      final result = DoctorDetectionService.detectDoctor(text);

      expect(result, isNotNull);
      expect(result!['specialty'], isNotEmpty);
    });

    test('detectDoctorFromMetadata parse les métadonnées correctement', () {
      final metadata = {
        'doctor_name': 'Jean Dupont',
        'doctor_specialty': 'Cardiologue',
      };

      final result = DoctorDetectionService.detectDoctorFromMetadata(metadata);

      expect(result, isNotNull);
      expect(result!['firstName'], 'Jean');
      expect(result['lastName'], 'Dupont');
      expect(result['specialty'], 'Cardiologue');
    });

    test('detectDoctorFromMetadata gère un seul nom', () {
      final metadata = {
        'doctor_name': 'Dupont',
        'doctor_specialty': 'Généraliste',
      };

      final result = DoctorDetectionService.detectDoctorFromMetadata(metadata);

      expect(result, isNotNull);
      expect(result!['firstName'], '');
      expect(result['lastName'], 'Dupont');
      expect(result['specialty'], 'Généraliste');
    });

    test('detectDoctorFromMetadata retourne null si pas de nom', () {
      final metadata = {
        'doctor_specialty': 'Cardiologue',
      };

      final result = DoctorDetectionService.detectDoctorFromMetadata(metadata);

      expect(result, isNull);
    });

    test('detectDoctorFromDocument priorise les métadonnées', () {
      final metadata = {
        'doctor_name': 'Marie Martin',
        'doctor_specialty': 'Dermatologue',
      };
      const text = 'Dr. Jean Dupont, cardiologue';

      final result = DoctorDetectionService.detectDoctorFromDocument(
        metadata: metadata,
        textContent: text,
      );

      expect(result, isNotNull);
      // Doit utiliser les métadonnées, pas le texte
      expect(result!['firstName'], 'Marie');
      expect(result['lastName'], 'Martin');
      expect(result['specialty'], 'Dermatologue');
    });

    test('detectDoctorFromDocument utilise le texte si pas de métadonnées', () {
      const text = 'Dr. Pierre Dubois, neurologue';

      final result = DoctorDetectionService.detectDoctorFromDocument(
        metadata: null,
        textContent: text,
      );

      expect(result, isNotNull);
      expect(result!['firstName'], 'Pierre');
      expect(result['lastName'], 'Dubois');
      expect(result['specialty'], 'Neurologue');
    });

    test('detectDoctorFromDocument retourne null si rien détecté', () {
      final result = DoctorDetectionService.detectDoctorFromDocument(
        metadata: null,
        textContent: 'Document sans médecin',
      );

      expect(result, isNull);
    });
  });
}

