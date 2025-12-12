import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service de cache offline pour les données
/// Cache LRU limité à 100 clés maximum pour éviter consommation mémoire excessive
class OfflineCacheService {
  static const String _cachePrefix = 'offline_cache_';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';
  static const String _cacheAccessOrderKey = 'offline_cache_access_order';
  static const Duration _defaultCacheDuration = Duration(hours: 24);
  static const int _maxCacheSize = 100; // Limite LRU : 100 clés maximum

  /// Sauvegarde des données en cache avec gestion LRU
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
      
      // Vérifier et nettoyer si limite LRU atteinte
      await _enforceLRULimit(prefs);
      
      final jsonString = jsonEncode(data);
      final expiryTime = DateTime.now().add(duration ?? _defaultCacheDuration);
      
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString(timestampKey, expiryTime.toIso8601String());
      
      // Mettre à jour l'ordre d'accès (LRU)
      await _updateAccessOrder(prefs, key);
      
      AppLogger.debug('Données mises en cache: $key (expire: $expiryTime)');
    } catch (e) {
      AppLogger.error('Erreur mise en cache $key', e);
    }
  }
  
  /// Applique la limite LRU en supprimant les clés les moins récemment utilisées
  static Future<void> _enforceLRULimit(SharedPreferences prefs) async {
    try {
      final accessOrderStr = prefs.getString(_cacheAccessOrderKey);
      if (accessOrderStr == null) return;
      
      final accessOrder = List<String>.from(jsonDecode(accessOrderStr));
      
      // Compter les clés de cache actives
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((k) => k.startsWith(_cachePrefix)).length;
      
      // Si on dépasse la limite, supprimer les plus anciennes
      if (cacheKeys >= _maxCacheSize) {
        final keysToRemove = accessOrder.take(cacheKeys - _maxCacheSize + 1).toList();
        
        for (final key in keysToRemove) {
          await clearCache(key);
          accessOrder.remove(key);
        }
        
        await prefs.setString(_cacheAccessOrderKey, jsonEncode(accessOrder));
        AppLogger.debug('Cache LRU: ${keysToRemove.length} clé(s) supprimée(s)');
      }
    } catch (e) {
      AppLogger.error('Erreur application limite LRU', e);
    }
  }
  
  /// Met à jour l'ordre d'accès pour le LRU
  static Future<void> _updateAccessOrder(SharedPreferences prefs, String key) async {
    try {
      final accessOrderStr = prefs.getString(_cacheAccessOrderKey);
      final accessOrder = accessOrderStr != null 
          ? List<String>.from(jsonDecode(accessOrderStr))
          : <String>[];
      
      // Retirer la clé si elle existe déjà
      accessOrder.remove(key);
      // Ajouter à la fin (plus récemment utilisée)
      accessOrder.add(key);
      
      await prefs.setString(_cacheAccessOrderKey, jsonEncode(accessOrder));
    } catch (e) {
      AppLogger.error('Erreur mise à jour ordre accès', e);
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
      
      // Mettre à jour l'ordre d'accès (LRU) - cette clé est utilisée
      await _updateAccessOrder(prefs, key);
      
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
      
      // Retirer de l'ordre d'accès
      final accessOrderStr = prefs.getString(_cacheAccessOrderKey);
      if (accessOrderStr != null) {
        final accessOrder = List<String>.from(jsonDecode(accessOrderStr));
        accessOrder.remove(key);
        await prefs.setString(_cacheAccessOrderKey, jsonEncode(accessOrder));
      }
      
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
      
      // Supprimer aussi l'ordre d'accès
      await prefs.remove(_cacheAccessOrderKey);
      
      AppLogger.debug('Tous les caches ont été supprimés');
    } catch (e) {
      AppLogger.error('Erreur suppression tous les caches', e);
    }
  }
  
  /// Nettoie automatiquement les caches expirés au démarrage
  /// À appeler au démarrage de l'app pour libérer la mémoire
  static Future<void> cleanupOnStartup() async {
    try {
      await clearExpiredCaches();
      // Appliquer aussi la limite LRU au cas où
      final prefs = await SharedPreferences.getInstance();
      await _enforceLRULimit(prefs);
      AppLogger.debug('Nettoyage cache au démarrage terminé');
    } catch (e) {
      AppLogger.error('Erreur nettoyage cache au démarrage', e);
    }
  }
}

