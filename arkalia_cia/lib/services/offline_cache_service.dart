import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service de cache offline pour les données
class OfflineCacheService {
  static const String _cachePrefix = 'offline_cache_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  /// Sauvegarde des données en cache
  /// 
  /// [key] : Clé unique pour identifier le cache
  /// [data] : Données à mettre en cache (sera converti en JSON)
  /// [duration] : Durée de validité du cache (défaut: 24h)
  static Future<void> cacheData(
    String key,
    dynamic data, {
    Duration? duration,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      
      final jsonString = jsonEncode(data);
      final expiryTime = DateTime.now().add(duration ?? _defaultCacheDuration);
      
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString(timestampKey, expiryTime.toIso8601String());
      
      AppLogger.debug('Données mises en cache: $key (expire: $expiryTime)');
    } catch (e) {
      AppLogger.error('Erreur mise en cache $key', e);
    }
  }

  /// Récupère des données du cache si elles sont encore valides
  /// 
  /// [key] : Clé du cache
  /// Retourne les données si valides, null sinon
  static Future<dynamic> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '$_cacheTimestampPrefix$key';
      
      final cachedData = prefs.getString(cacheKey);
      final expiryString = prefs.getString(timestampKey);
      
      if (cachedData == null || expiryString == null) {
        return null;
      }
      
      final expiryTime = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiryTime)) {
        // Cache expiré, nettoyer
        await prefs.remove(cacheKey);
        await prefs.remove(timestampKey);
        AppLogger.debug('Cache expiré pour: $key');
        return null;
      }
      
      return jsonDecode(cachedData);
    } catch (e) {
      AppLogger.error('Erreur récupération cache $key', e);
      return null;
    }
  }

  /// Vérifie si des données en cache existent et sont valides
  static Future<bool> hasValidCache(String key) async {
    final cached = await getCachedData(key);
    return cached != null;
  }

  /// Supprime le cache pour une clé spécifique
  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cacheTimestampPrefix$key');
      AppLogger.debug('Cache supprimé pour: $key');
    } catch (e) {
      AppLogger.error('Erreur suppression cache $key', e);
    }
  }

  /// Supprime tous les caches expirés
  static Future<void> clearExpiredCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cacheTimestampPrefix)) {
          final cacheKey = key.replaceFirst(_cacheTimestampPrefix, '');
          final expiryString = prefs.getString(key);
          
          if (expiryString != null) {
            final expiryTime = DateTime.parse(expiryString);
            if (DateTime.now().isAfter(expiryTime)) {
              await clearCache(cacheKey);
            }
          }
        }
      }
    } catch (e) {
      AppLogger.error('Erreur nettoyage caches expirés', e);
    }
  }

  /// Supprime tous les caches
  static Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
      AppLogger.debug('Tous les caches ont été supprimés');
    } catch (e) {
      AppLogger.error('Erreur suppression tous les caches', e);
    }
  }
}

