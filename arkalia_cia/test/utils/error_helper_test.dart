import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/utils/error_helper.dart';

void main() {
  group('ErrorHelper', () {
    test('getUserFriendlyMessage should return database error message', () {
      expect(
        ErrorHelper.getUserFriendlyMessage('DatabaseFactory not initialized'),
        'Erreur de base de données. Veuillez redémarrer l\'application.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('database factory error'),
        'Erreur de base de données. Veuillez redémarrer l\'application.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('SQLite error'),
        'Erreur de sauvegarde. Veuillez réessayer.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('database connection failed'),
        'Erreur de sauvegarde. Veuillez réessayer.',
      );
    });

    test('getUserFriendlyMessage should return network error message', () {
      expect(
        ErrorHelper.getUserFriendlyMessage('Failed host lookup'),
        'Problème de connexion. Vérifiez votre réseau.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('Connection refused'),
        'Problème de connexion. Vérifiez votre réseau.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('Network error'),
        'Problème de connexion. Vérifiez votre réseau.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('Request timeout'),
        'La requête a pris trop de temps. Réessayez.',
      );
    });

    test('getUserFriendlyMessage should return permission error message', () {
      expect(
        ErrorHelper.getUserFriendlyMessage('Permission denied'),
        'Permission refusée. Vérifiez les paramètres de l\'application.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('Access denied'),
        'Permission refusée. Vérifiez les paramètres de l\'application.',
      );
    });

    test('getUserFriendlyMessage should return file error message', () {
      expect(
        ErrorHelper.getUserFriendlyMessage('File not found'),
        'Erreur de fichier. Vérifiez que le fichier existe.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('Invalid path'),
        'Erreur de fichier. Vérifiez que le fichier existe.',
      );
    });

    test('getUserFriendlyMessage should return generic error message', () {
      expect(
        ErrorHelper.getUserFriendlyMessage('Unknown error'),
        'Une erreur est survenue. Veuillez réessayer.',
      );
      expect(
        ErrorHelper.getUserFriendlyMessage('Some random error'),
        'Une erreur est survenue. Veuillez réessayer.',
      );
    });

    test('logError should not throw', () {
      expect(() => ErrorHelper.logError('test context', 'test error'),
          returnsNormally);
    });

    test('isNetworkError should detect network errors', () {
      expect(ErrorHelper.isNetworkError('Failed host lookup'), isTrue);
      expect(ErrorHelper.isNetworkError('Connection refused'), isTrue);
      expect(ErrorHelper.isNetworkError('Network error'), isTrue);
      expect(ErrorHelper.isNetworkError('Request timeout'), isTrue);
      expect(ErrorHelper.isNetworkError('SocketException'), isTrue);
      expect(ErrorHelper.isNetworkError('Connection error'), isTrue);
    });

    test('isNetworkError should return false for non-network errors', () {
      expect(ErrorHelper.isNetworkError('Database error'), isFalse);
      expect(ErrorHelper.isNetworkError('File error'), isFalse);
      expect(ErrorHelper.isNetworkError('Permission denied'), isFalse);
    });
  });
}

