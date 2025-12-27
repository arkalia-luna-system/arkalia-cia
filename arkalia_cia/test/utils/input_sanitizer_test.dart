import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer Tests', () {
    test('sanitize should escape HTML characters', () {
      final input = '<script>alert("XSS")</script>';
      final result = InputSanitizer.sanitize(input);
      
      // Vérifier que les balises HTML sont échappées (ne peuvent pas s'exécuter)
      expect(result, isNot(contains('<script>')));
      expect(result, isNot(contains('</script>')));
      expect(result, contains('&lt;')); // < échappé
      expect(result, contains('&gt;')); // > échappé
      // "alert" peut rester dans le texte échappé, mais ne peut pas s'exécuter car <script> est échappé
    });

    test('sanitize should remove JavaScript patterns', () {
      final input = 'javascript:alert("XSS")';
      final result = InputSanitizer.sanitize(input);
      
      expect(result, isNot(contains('javascript:')));
    });

    test('sanitize should remove event handlers', () {
      final input = '<img src=x onerror=alert("XSS")>';
      final result = InputSanitizer.sanitize(input);
      
      expect(result, isNot(contains('onerror')));
      expect(result, contains('&lt;'));
    });

    test('sanitizeForStorage should remove script tags', () {
      final input = '<script>alert("XSS")</script>Hello';
      final result = InputSanitizer.sanitizeForStorage(input);
      
      expect(result, isNot(contains('<script>')));
      expect(result, contains('Hello'));
    });

    test('sanitizeForStorage should remove iframe tags', () {
      final input = '<iframe src="evil.com"></iframe>Content';
      final result = InputSanitizer.sanitizeForStorage(input);
      
      expect(result, isNot(contains('<iframe>')));
      expect(result, contains('Content'));
    });

    test('isValid should return false for dangerous content', () {
      expect(InputSanitizer.isValid('<script>alert("XSS")</script>'), isFalse);
      expect(InputSanitizer.isValid('javascript:alert("XSS")'), isFalse);
      expect(InputSanitizer.isValid('<img onerror=alert("XSS")>'), isFalse);
    });

    test('isValid should return true for safe content', () {
      expect(InputSanitizer.isValid('Hello World'), isTrue);
      expect(InputSanitizer.isValid('Rappel médical'), isTrue);
      expect(InputSanitizer.isValid(''), isTrue);
    });

    test('sanitize should handle empty strings', () {
      expect(InputSanitizer.sanitize(''), equals(''));
    });

    test('sanitizeForStorage should handle empty strings', () {
      expect(InputSanitizer.sanitizeForStorage(''), equals(''));
    });
  });
}

