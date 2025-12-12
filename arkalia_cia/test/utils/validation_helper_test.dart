import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/utils/validation_helper.dart';

void main() {
  group('ValidationHelper', () {
    group('isValidPhone', () {
      test('should validate Belgian phone numbers', () {
        expect(ValidationHelper.isValidPhone('0412345678'), isTrue);
        expect(ValidationHelper.isValidPhone('04 12 34 56 78'), isTrue);
        expect(ValidationHelper.isValidPhone('04-12-34-56-78'), isTrue);
        expect(ValidationHelper.isValidPhone('(04) 12 34 56 78'), isTrue);
        expect(ValidationHelper.isValidPhone('+32412345678'), isTrue);
        expect(ValidationHelper.isValidPhone('+32 4 12 34 56 78'), isTrue);
      });

      test('should validate international phone numbers', () {
        expect(ValidationHelper.isValidPhone('+33123456789'), isTrue);
        expect(ValidationHelper.isValidPhone('+1234567890123'), isTrue);
      });

      test('should reject invalid phone numbers', () {
        expect(ValidationHelper.isValidPhone(''), isFalse);
        expect(ValidationHelper.isValidPhone('123'), isFalse);
        expect(ValidationHelper.isValidPhone('abc'), isFalse);
        expect(ValidationHelper.isValidPhone('0312345678'), isFalse); // Ne commence pas par 04
      });
    });

    group('isValidUrl', () {
      test('should validate HTTP URLs', () {
        expect(ValidationHelper.isValidUrl('http://example.com'), isTrue);
        expect(ValidationHelper.isValidUrl('http://www.example.com'), isTrue);
        expect(ValidationHelper.isValidUrl('http://example.com/path'), isTrue);
      });

      test('should validate HTTPS URLs', () {
        expect(ValidationHelper.isValidUrl('https://example.com'), isTrue);
        expect(ValidationHelper.isValidUrl('https://www.example.com'), isTrue);
        expect(ValidationHelper.isValidUrl('https://example.com/path'), isTrue);
      });

      test('should reject invalid URLs', () {
        expect(ValidationHelper.isValidUrl(''), isFalse);
        expect(ValidationHelper.isValidUrl('not a url'), isFalse);
        expect(ValidationHelper.isValidUrl('ftp://example.com'), isFalse);
        expect(ValidationHelper.isValidUrl('example.com'), isFalse);
      });
    });

    group('isValidDate', () {
      test('should validate ISO 8601 dates', () {
        expect(ValidationHelper.isValidDate('2024-01-01'), isTrue);
        expect(ValidationHelper.isValidDate('2024-01-01T12:00:00'), isTrue);
        expect(ValidationHelper.isValidDate('2024-01-01T12:00:00Z'), isTrue);
        expect(ValidationHelper.isValidDate('2024-01-01T12:00:00+01:00'), isTrue);
      });

      test('should reject invalid dates', () {
        expect(ValidationHelper.isValidDate(''), isFalse);
        expect(ValidationHelper.isValidDate('not a date'), isFalse);
        expect(ValidationHelper.isValidDate('01/01/2024'), isFalse);
        expect(ValidationHelper.isValidDate('2024-13-01'), isFalse);
      });
    });

    group('isValidEmail', () {
      test('should validate correct emails', () {
        expect(ValidationHelper.isValidEmail('test@example.com'), isTrue);
        expect(ValidationHelper.isValidEmail('user.name@example.co.uk'), isTrue);
        expect(ValidationHelper.isValidEmail('user+tag@example.com'), isTrue);
        expect(ValidationHelper.isValidEmail('user_name@example.com'), isTrue);
      });

      test('should reject invalid emails', () {
        expect(ValidationHelper.isValidEmail(''), isFalse);
        expect(ValidationHelper.isValidEmail('notanemail'), isFalse);
        expect(ValidationHelper.isValidEmail('@example.com'), isFalse);
        expect(ValidationHelper.isValidEmail('user@'), isFalse);
        expect(ValidationHelper.isValidEmail('user@example'), isFalse);
      });
    });

    group('isValidName', () {
      test('should validate correct names', () {
        expect(ValidationHelper.isValidName('Jean'), isTrue);
        expect(ValidationHelper.isValidName('Jean-Pierre'), isTrue);
        expect(ValidationHelper.isValidName("Jean d'Orient"), isTrue);
        expect(ValidationHelper.isValidName('Marie-Claire'), isTrue);
        expect(ValidationHelper.isValidName('José'), isTrue);
      });

      test('should reject invalid names', () {
        expect(ValidationHelper.isValidName(''), isFalse);
        expect(ValidationHelper.isValidName(' '), isFalse);
        expect(ValidationHelper.isValidName('A'), isFalse); // Trop court
        expect(ValidationHelper.isValidName('A' * 101), isFalse); // Trop long
        expect(ValidationHelper.isValidName('Jean123'), isFalse); // Chiffres
        expect(ValidationHelper.isValidName('Jean@Pierre'), isFalse); // Caractères spéciaux
      });
    });

    group('isValidTitle', () {
      test('should validate correct titles', () {
        expect(ValidationHelper.isValidTitle('Mon titre'), isTrue);
        expect(ValidationHelper.isValidTitle('A'), isTrue);
        expect(ValidationHelper.isValidTitle('A' * 200), isTrue);
      });

      test('should reject invalid titles', () {
        expect(ValidationHelper.isValidTitle(''), isFalse);
        expect(ValidationHelper.isValidTitle(' '), isFalse);
        expect(ValidationHelper.isValidTitle('A' * 201), isFalse); // Trop long
      });
    });

    group('isValidDescription', () {
      test('should validate optional descriptions', () {
        expect(ValidationHelper.isValidDescription(null), isTrue);
        expect(ValidationHelper.isValidDescription(''), isTrue);
        expect(ValidationHelper.isValidDescription('Description valide'), isTrue);
        expect(ValidationHelper.isValidDescription('A' * 1000), isTrue);
      });

      test('should reject too long descriptions', () {
        expect(ValidationHelper.isValidDescription('A' * 1001), isFalse);
      });
    });

    group('isValidPdfFileName', () {
      test('should validate PDF file names', () {
        expect(ValidationHelper.isValidPdfFileName('document.pdf'), isTrue);
        expect(ValidationHelper.isValidPdfFileName('DOCUMENT.PDF'), isTrue);
        expect(ValidationHelper.isValidPdfFileName('file name.PDF'), isTrue);
      });

      test('should reject non-PDF file names', () {
        expect(ValidationHelper.isValidPdfFileName(''), isFalse);
        expect(ValidationHelper.isValidPdfFileName('document.txt'), isFalse);
        expect(ValidationHelper.isValidPdfFileName('document'), isFalse);
        expect(ValidationHelper.isValidPdfFileName('.pdf'), isFalse);
      });
    });

    group('formatBelgianPhone', () {
      test('should format Belgian phone numbers correctly', () {
        expect(ValidationHelper.formatBelgianPhone('0412345678'),
            '0412 34 56 78');
        expect(ValidationHelper.formatBelgianPhone('+32412345678'),
            '0412345678');
        expect(ValidationHelper.formatBelgianPhone('04 12 34 56 78'),
            '0412 34 56 78');
      });

      test('should return original if format not recognized', () {
        expect(ValidationHelper.formatBelgianPhone('1234567890'),
            '1234567890');
        expect(ValidationHelper.formatBelgianPhone('invalid'),
            'invalid');
      });
    });
  });
}

