import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';
import 'local_storage_service.dart';
import 'api_service.dart';
import 'backend_config_service.dart';
import 'aria_service.dart';

/// Service de synchronisation automatique en arrière-plan
/// Synchronise les données quand l'app revient au premier plan
class AutoSyncService {
  static const String _autoSyncEnabledKey = 'auto_sync_enabled';
  static const String _lastSyncTimeKey = 'last_auto_sync_time';
  static const String _syncOnStartupKey = 'sync_on_startup';
  static const String _syncOnlyOnWifiKey = 'sync_only_on_wifi';
  static const String _lastSyncStatsKey = 'last_sync_stats';
  
  static bool _isSyncing = false;
  static Timer? _periodicTimer;
  
  // Statistiques de la dernière synchronisation
  static int _lastDocsSynced = 0;
  static int _lastRemindersSynced = 0;
  static int _lastContactsSynced = 0;

  /// Active ou désactive la synchronisation automatique
  static Future<void> setAutoSyncEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncEnabledKey, enabled);
    
    if (enabled) {
      _startPeriodicSync();
    } else {
      _stopPeriodicSync();
    }
  }

  /// Vérifie si la synchronisation automatique est activée
  static Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncEnabledKey) ?? true; // Activé par défaut
  }

  /// Active ou désactive la synchronisation au démarrage
  static Future<void> setSyncOnStartup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncOnStartupKey, enabled);
  }

  /// Vérifie si la synchronisation au démarrage est activée
  static Future<bool> isSyncOnStartupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncOnStartupKey) ?? true; // Activé par défaut
  }

  /// Active ou désactive la synchronisation uniquement sur WiFi
  static Future<void> setSyncOnlyOnWifi(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncOnlyOnWifiKey, enabled);
  }

  /// Vérifie si la synchronisation uniquement sur WiFi est activée
  static Future<bool> isSyncOnlyOnWifi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncOnlyOnWifiKey) ?? false;
  }

  /// Vérifie si on est connecté en WiFi
  static Future<bool> _isWifiConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      // checkConnectivity() retourne une List<ConnectivityResult>
      return connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      AppLogger.warning('Erreur vérification WiFi: $e');
      // En cas d'erreur, autoriser la synchronisation par sécurité
      return true;
    }
  }

  /// Synchronise automatiquement si activé et si nécessaire
  static Future<void> syncIfNeeded({bool force = false}) async {
    if (_isSyncing) {
      AppLogger.debug('Synchronisation déjà en cours, ignorée');
      return;
    }

    final enabled = await isAutoSyncEnabled();
    if (!enabled && !force) {
      return;
    }

    // Vérifier WiFi si requis
    final syncOnlyWifi = await isSyncOnlyOnWifi();
    if (syncOnlyWifi && !force) {
      final isWifi = await _isWifiConnected();
      if (!isWifi) {
        AppLogger.debug('Synchronisation uniquement WiFi activée mais pas en WiFi, ignorée');
        return;
      }
    }

    // Vérifier si on doit synchroniser (éviter trop de syncs)
    if (!force) {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncStr = prefs.getString(_lastSyncTimeKey);
      if (lastSyncStr != null) {
        try {
          final lastSync = DateTime.parse(lastSyncStr);
          final now = DateTime.now();
          final diff = now.difference(lastSync);
          
          // Ne pas synchroniser si la dernière sync était il y a moins de 5 minutes
          if (diff.inMinutes < 5) {
            AppLogger.debug('Synchronisation récente (${diff.inMinutes} min), ignorée');
            return;
          }
        } catch (e) {
          AppLogger.warning('Erreur parsing dernière sync: $e');
        }
      }
    }

    await _performSync();
  }

  /// Effectue la synchronisation complète
  static Future<void> _performSync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _lastDocsSynced = 0;
    _lastRemindersSynced = 0;
    _lastContactsSynced = 0;
    
    try {
      // Vérifier la connexion backend
      final backendEnabled = await BackendConfigService.isBackendEnabled();
      final ariaConnected = await ARIAService.checkConnection();

      if (!backendEnabled && !ariaConnected) {
        AppLogger.debug('Aucune connexion disponible pour la synchronisation');
        return;
      }

      AppLogger.debug('Début synchronisation automatique...');

      // Synchroniser les documents
      await _syncDocuments();

      // Synchroniser les rappels
      await _syncReminders();

      // Synchroniser les contacts d'urgence
      await _syncEmergencyContacts();

      // Enregistrer l'heure de la dernière synchronisation et les statistiques
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
      
      final stats = {
        'docs': _lastDocsSynced,
        'reminders': _lastRemindersSynced,
        'contacts': _lastContactsSynced,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_lastSyncStatsKey, jsonEncode(stats));

      final totalSynced = _lastDocsSynced + _lastRemindersSynced + _lastContactsSynced;
      AppLogger.info('Synchronisation automatique terminée: $_lastDocsSynced docs, $_lastRemindersSynced rappels, $_lastContactsSynced contacts');
      
      // Afficher une notification silencieuse si des éléments ont été synchronisés
      if (totalSynced > 0) {
        AppLogger.debug('Notification: $totalSynced élément(s) synchronisé(s)');
        // Note: Les notifications peuvent être ajoutées ici avec flutter_local_notifications
        // si nécessaire pour informer l'utilisateur
      }
    } catch (e) {
      AppLogger.error('Erreur lors de la synchronisation automatique', e);
      // Notification d'erreur silencieuse
      AppLogger.warning('Notification erreur: Synchronisation échouée');
    } finally {
      _isSyncing = false;
    }
  }

  /// Synchronise les documents (bidirectionnel)
  static Future<void> _syncDocuments() async {
    if (!await BackendConfigService.isBackendEnabled()) return;

    try {
      final localDocs = await LocalStorageService.getDocuments();
      final backendDocs = await ApiService.getDocuments();

      // 1. Synchroniser LOCAL → BACKEND (documents nouveaux/modifiés localement)
      final toSyncUp = localDocs.where((doc) {
        final docId = doc['id'].toString();
        final backendDoc = backendDocs.firstWhere(
          (bd) => bd['id'].toString() == docId,
          orElse: () => <String, dynamic>{},
        );
        
        if (backendDoc.isEmpty) return true;
        
        try {
          final localUpdated = doc['updated_at'] as String? ?? doc['created_at'] as String? ?? '';
          final backendUpdated = backendDoc['updated_at'] as String? ?? backendDoc['created_at'] as String? ?? '';
          if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
            final localDate = DateTime.parse(localUpdated);
            final backendDate = DateTime.parse(backendUpdated);
            return localDate.isAfter(backendDate);
          }
        } catch (e) {
          return true;
        }
        return false;
      });
      
      for (final doc in toSyncUp) {
        try {
          final filePath = doc['path'] as String? ?? doc['file_path'] as String?;
          if (filePath != null) {
            final file = File(filePath);
            if (await file.exists()) {
              await ApiService.uploadDocument(file);
              _lastDocsSynced++;
            }
          }
        } catch (e) {
          AppLogger.error('Erreur sync document ${doc['id']}', e);
        }
      }

      // 2. Synchroniser BACKEND → LOCAL (documents nouveaux/modifiés sur le backend)
      for (final backendDoc in backendDocs) {
        final docId = backendDoc['id'].toString();
        final localDoc = localDocs.firstWhere(
          (ld) => ld['id'].toString() == docId,
          orElse: () => <String, dynamic>{},
        );
        
        // Si nouveau document sur le backend ou plus récent
        if (localDoc.isEmpty) {
          // Nouveau document depuis le backend - sauvegarder localement
          try {
            final docToSave = {
              'id': docId,
              'name': backendDoc['name'] ?? backendDoc['file_name'] ?? '',
              'original_name': backendDoc['original_name'] ?? backendDoc['name'] ?? '',
              'path': backendDoc['file_path'] ?? '',
              'file_size': backendDoc['file_size'] ?? 0,
              'created_at': backendDoc['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at': backendDoc['updated_at'] ?? backendDoc['created_at'] ?? DateTime.now().toIso8601String(),
            };
            await LocalStorageService.saveDocument(docToSave);
            _lastDocsSynced++;
          } catch (e) {
            AppLogger.error('Erreur sauvegarde document backend $docId', e);
          }
        } else {
          // Document existe localement - vérifier si le backend est plus récent
          try {
            final localUpdated = localDoc['updated_at'] as String? ?? localDoc['created_at'] as String? ?? '';
            final backendUpdated = backendDoc['updated_at'] as String? ?? backendDoc['created_at'] as String? ?? '';
            if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
              final localDate = DateTime.parse(localUpdated);
              final backendDate = DateTime.parse(backendUpdated);
              if (backendDate.isAfter(localDate)) {
                // Backend plus récent - mettre à jour localement
                final docToUpdate = {
                  'id': docId,
                  'name': backendDoc['name'] ?? localDoc['name'] ?? '',
                  'original_name': backendDoc['original_name'] ?? localDoc['original_name'] ?? '',
                  'path': backendDoc['file_path'] ?? localDoc['path'] ?? '',
                  'file_size': backendDoc['file_size'] ?? localDoc['file_size'] ?? 0,
                  'created_at': localDoc['created_at'] ?? DateTime.now().toIso8601String(),
                  'updated_at': backendUpdated,
                };
                await LocalStorageService.updateDocument(docToUpdate);
                _lastDocsSynced++;
              }
            }
          } catch (e) {
            AppLogger.error('Erreur mise à jour document $docId', e);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Erreur sync documents', e);
    }
  }

  /// Synchronise les rappels (bidirectionnel)
  static Future<void> _syncReminders() async {
    if (!await BackendConfigService.isBackendEnabled()) return;

    try {
      final localReminders = await LocalStorageService.getReminders();
      final backendReminders = await ApiService.getReminders();
      
      // 1. Synchroniser LOCAL → BACKEND
      final toSyncUp = localReminders.where((reminder) {
        final reminderId = reminder['id'].toString();
        final backendReminder = backendReminders.firstWhere(
          (br) => br['id'].toString() == reminderId,
          orElse: () => <String, dynamic>{},
        );
        
        if (backendReminder.isEmpty) return true;
        
        try {
          final localUpdated = reminder['updated_at'] as String? ?? reminder['created_at'] as String? ?? '';
          final backendUpdated = backendReminder['updated_at'] as String? ?? backendReminder['created_at'] as String? ?? '';
          if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
            final localDate = DateTime.parse(localUpdated);
            final backendDate = DateTime.parse(backendUpdated);
            return localDate.isAfter(backendDate);
          }
        } catch (e) {
          return true;
        }
        return false;
      });
      
      for (final reminder in toSyncUp) {
        try {
          final reminderDateStr = reminder['reminder_date'] as String;
          await ApiService.createReminder(
            title: reminder['title'] as String,
            description: reminder['description'] as String? ?? '',
            reminderDate: reminderDateStr,
          );
          _lastRemindersSynced++;
        } catch (e) {
          AppLogger.error('Erreur sync rappel ${reminder['id']}', e);
        }
      }

      // 2. Synchroniser BACKEND → LOCAL
      for (final backendReminder in backendReminders) {
        final reminderId = backendReminder['id'].toString();
        final localReminder = localReminders.firstWhere(
          (lr) => lr['id'].toString() == reminderId,
          orElse: () => <String, dynamic>{},
        );
        
        if (localReminder.isEmpty) {
          // Nouveau rappel depuis le backend
          try {
            final reminderToSave = {
              'id': reminderId,
              'title': backendReminder['title'] ?? '',
              'description': backendReminder['description'] ?? '',
              'reminder_date': backendReminder['reminder_date'] ?? backendReminder['date'] ?? '',
              'created_at': backendReminder['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at': backendReminder['updated_at'] ?? backendReminder['created_at'] ?? DateTime.now().toIso8601String(),
              'is_completed': backendReminder['is_completed'] ?? false,
            };
            await LocalStorageService.saveReminder(reminderToSave);
            _lastRemindersSynced++;
          } catch (e) {
            AppLogger.error('Erreur sauvegarde rappel backend $reminderId', e);
          }
        } else {
          // Vérifier si le backend est plus récent
          try {
            final localUpdated = localReminder['updated_at'] as String? ?? localReminder['created_at'] as String? ?? '';
            final backendUpdated = backendReminder['updated_at'] as String? ?? backendReminder['created_at'] as String? ?? '';
            if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
              final localDate = DateTime.parse(localUpdated);
              final backendDate = DateTime.parse(backendUpdated);
              if (backendDate.isAfter(localDate)) {
                // Backend plus récent - mettre à jour localement
                final reminderToUpdate = {
                  'id': reminderId,
                  'title': backendReminder['title'] ?? localReminder['title'] ?? '',
                  'description': backendReminder['description'] ?? localReminder['description'] ?? '',
                  'reminder_date': backendReminder['reminder_date'] ?? backendReminder['date'] ?? localReminder['reminder_date'] ?? '',
                  'created_at': localReminder['created_at'] ?? DateTime.now().toIso8601String(),
                  'updated_at': backendUpdated,
                  'is_completed': backendReminder['is_completed'] ?? localReminder['is_completed'] ?? false,
                };
                await LocalStorageService.updateReminder(reminderToUpdate);
                _lastRemindersSynced++;
              }
            }
          } catch (e) {
            AppLogger.error('Erreur mise à jour rappel $reminderId', e);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Erreur sync rappels', e);
    }
  }

  /// Synchronise les contacts d'urgence (bidirectionnel)
  static Future<void> _syncEmergencyContacts() async {
    if (!await BackendConfigService.isBackendEnabled()) return;

    try {
      final localContacts = await LocalStorageService.getEmergencyContacts();
      final backendContacts = await ApiService.getEmergencyContacts();
      
      // 1. Synchroniser LOCAL → BACKEND
      final toSyncUp = localContacts.where((contact) {
        final contactId = contact['id'].toString();
        final backendContact = backendContacts.firstWhere(
          (bc) => bc['id'].toString() == contactId,
          orElse: () => <String, dynamic>{},
        );
        
        if (backendContact.isEmpty) return true;
        
        try {
          final localUpdated = contact['updated_at'] as String? ?? contact['created_at'] as String? ?? '';
          final backendUpdated = backendContact['updated_at'] as String? ?? backendContact['created_at'] as String? ?? '';
          if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
            final localDate = DateTime.parse(localUpdated);
            final backendDate = DateTime.parse(backendUpdated);
            return localDate.isAfter(backendDate);
          }
        } catch (e) {
          return true;
        }
        return false;
      });
      
      for (final contact in toSyncUp) {
        try {
          await ApiService.createEmergencyContact(
            name: contact['name'] as String,
            phone: contact['phone'] as String,
            relationship: contact['relationship'] as String? ?? '',
            isPrimary: contact['is_primary'] as bool? ?? false,
          );
          _lastContactsSynced++;
        } catch (e) {
          AppLogger.error('Erreur sync contact ${contact['id']}', e);
        }
      }

      // 2. Synchroniser BACKEND → LOCAL
      for (final backendContact in backendContacts) {
        final contactId = backendContact['id'].toString();
        final localContact = localContacts.firstWhere(
          (lc) => lc['id'].toString() == contactId,
          orElse: () => <String, dynamic>{},
        );
        
        if (localContact.isEmpty) {
          // Nouveau contact depuis le backend
          try {
            final contactToSave = {
              'id': contactId,
              'name': backendContact['name'] ?? '',
              'phone': backendContact['phone'] ?? '',
              'relationship': backendContact['relationship'] ?? '',
              'is_primary': backendContact['is_primary'] ?? false,
              'created_at': backendContact['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at': backendContact['updated_at'] ?? backendContact['created_at'] ?? DateTime.now().toIso8601String(),
            };
            await LocalStorageService.saveEmergencyContact(contactToSave);
            _lastContactsSynced++;
          } catch (e) {
            AppLogger.error('Erreur sauvegarde contact backend $contactId', e);
          }
        } else {
          // Vérifier si le backend est plus récent
          try {
            final localUpdated = localContact['updated_at'] as String? ?? localContact['created_at'] as String? ?? '';
            final backendUpdated = backendContact['updated_at'] as String? ?? backendContact['created_at'] as String? ?? '';
            if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
              final localDate = DateTime.parse(localUpdated);
              final backendDate = DateTime.parse(backendUpdated);
              if (backendDate.isAfter(localDate)) {
                // Backend plus récent - mettre à jour localement
                final contactToUpdate = {
                  'id': contactId,
                  'name': backendContact['name'] ?? localContact['name'] ?? '',
                  'phone': backendContact['phone'] ?? localContact['phone'] ?? '',
                  'relationship': backendContact['relationship'] ?? localContact['relationship'] ?? '',
                  'is_primary': backendContact['is_primary'] ?? localContact['is_primary'] ?? false,
                  'created_at': localContact['created_at'] ?? DateTime.now().toIso8601String(),
                  'updated_at': backendUpdated,
                };
                await LocalStorageService.updateEmergencyContact(contactToUpdate);
                _lastContactsSynced++;
              }
            }
          } catch (e) {
            AppLogger.error('Erreur mise à jour contact $contactId', e);
          }
        }
      }
    } catch (e) {
      AppLogger.error('Erreur sync contacts', e);
    }
  }

  /// Démarre la synchronisation périodique (toutes les heures)
  static void _startPeriodicSync() {
    _stopPeriodicSync(); // S'assurer qu'il n'y a pas de timer en double
    
    _periodicTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      syncIfNeeded();
    });
  }

  /// Arrête la synchronisation périodique
  static void _stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Récupère l'heure de la dernière synchronisation
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncTimeKey);
    if (lastSyncStr == null) return null;
    
    try {
      return DateTime.parse(lastSyncStr);
    } catch (e) {
      return null;
    }
  }

  /// Récupère les statistiques de la dernière synchronisation
  static Future<Map<String, dynamic>?> getLastSyncStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsStr = prefs.getString(_lastSyncStatsKey);
    if (statsStr == null) return null;
    
    try {
      return Map<String, dynamic>.from(jsonDecode(statsStr));
    } catch (e) {
      return null;
    }
  }

  /// Formate le temps écoulé depuis la dernière synchronisation
  static String formatLastSyncTime(DateTime? lastSync) {
    if (lastSync == null) return 'Jamais';
    
    final now = DateTime.now();
    final diff = now.difference(lastSync);
    
    if (diff.inDays > 0) {
      return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'Il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return 'Il y a ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  /// Nettoie les ressources
  static void dispose() {
    _stopPeriodicSync();
  }
}

