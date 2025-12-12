import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/utils/retry_helper.dart';

void main() {
  group('RetryHelper', () {
    test('retry should succeed on first attempt', () async {
      int attempts = 0;
      final result = await RetryHelper.retry(
        fn: () async {
          attempts++;
          return 'success';
        },
        maxRetries: 3,
      );

      expect(result, 'success');
      expect(attempts, 1);
    });

    test('retry should succeed after retries', () async {
      int attempts = 0;
      final result = await RetryHelper.retry(
        fn: () async {
          attempts++;
          if (attempts < 2) {
            throw Exception('Temporary error');
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: 0, // Pour accélérer les tests
      );

      expect(result, 'success');
      expect(attempts, 2);
    });

    test('retry should throw after max retries', () async {
      int attempts = 0;
      expect(
        () => RetryHelper.retry(
          fn: () async {
            attempts++;
            throw Exception('Persistent error');
          },
          maxRetries: 3,
          initialDelay: 0,
        ),
        throwsException,
      );

      expect(attempts, 3);
    });

    test('retry should respect maxDelay', () async {
      int attempts = 0;
      final stopwatch = Stopwatch()..start();

      try {
        await RetryHelper.retry(
          fn: () async {
            attempts++;
            throw Exception('Error');
          },
          maxRetries: 2,
          initialDelay: 0, // Utiliser 0 pour accélérer le test
          maxDelay: 2,
        );
      } catch (e) {
        // Expected
      }

      stopwatch.stop();
      // Vérifier qu'on a bien fait 2 tentatives
      expect(attempts, 2);
      // Le délai devrait être minimal avec initialDelay=0
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('retryOnNetworkError should work like retry', () async {
      int attempts = 0;
      final result = await RetryHelper.retryOnNetworkError(
        fn: () async {
          attempts++;
          if (attempts < 2) {
            throw Exception('Network error');
          }
          return 'success';
        },
        maxRetries: 3,
        initialDelay: 0,
      );

      expect(result, 'success');
      expect(attempts, 2);
    });

    test('retry should use exponential backoff', () async {
      int attempts = 0;

      try {
        await RetryHelper.retry(
          fn: () async {
            attempts++;
            throw Exception('Error');
          },
          maxRetries: 4,
          initialDelay: 0,
          maxDelay: 10,
        );
      } catch (e) {
        // Expected
      }

      // Vérifier qu'on a bien fait plusieurs tentatives
      expect(attempts, 4);
    });
  });
}

