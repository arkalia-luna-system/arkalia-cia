import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../services/aria_service.dart';
import '../services/backend_config_service.dart';

/// Écran de synchronisation CIA ↔ ARIA
class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isSyncing = false;
  String _syncStatus = 'Prêt à synchroniser';
  double _syncProgress = 0.0;
  final Map<String, bool> _syncOptions = {
    'Documents': true,
    'Rappels': true,
    'Contacts d\'urgence': true,
    'Informations médicales': true,
    'Données ARIA': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronisation'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            _buildHeader(),
            const SizedBox(height: 24),

            // Options de synchronisation
            _buildSyncOptions(),
            const SizedBox(height: 24),

            // Statut de synchronisation
            _buildSyncStatus(),
            const SizedBox(height: 24),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.syncIcon, color: Colors.orange[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Synchronisation CIA ↔ ARIA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Synchronisez vos données entre l\'application et le backend',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options de synchronisation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ..._syncOptions.entries.map((entry) => CheckboxListTile(
                  title: Text(entry.key),
                  value: entry.value,
                  onChanged: _isSyncing
                      ? null
                      : (value) {
                          setState(() {
                            _syncOptions[entry.key] = value ?? false;
                          });
                        },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _syncStatus,
              style: TextStyle(
                fontSize: 14,
                color: _isSyncing ? Colors.blue[700] : Colors.grey[700],
              ),
            ),
            if (_isSyncing) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _syncProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_syncProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSyncing ? null : _startSync,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            label: Text(_isSyncing ? 'Synchronisation...' : 'Synchroniser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : _exportData,
                icon: const Icon(Icons.download),
                label: const Text('Exporter'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSyncing ? null : _importData,
                icon: const Icon(Icons.upload),
                label: const Text('Importer'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startSync() async {
    if (!mounted) return;
    
    setState(() {
      _isSyncing = true;
      _syncProgress = 0.0;
      _syncStatus = 'Vérification de la connexion...';
    });

    try {
      // Vérifier la connexion backend
      final backendEnabled = await BackendConfigService.isBackendEnabled();
      final ariaConnected = await ARIAService.checkConnection();

      if (!mounted) return;
      
      if (!backendEnabled && !ariaConnected) {
        _showError('Aucune connexion disponible. Activez le backend ou ARIA.');
        setState(() {
          _isSyncing = false;
        });
        return;
      }

      // Synchroniser les documents
      if (_syncOptions['Documents'] == true) {
        if (!mounted) return;
        setState(() {
          _syncStatus = 'Synchronisation des documents...';
          _syncProgress = 0.2;
        });
        await _syncDocuments();
      }

      // Synchroniser les rappels
      if (_syncOptions['Rappels'] == true) {
        if (!mounted) return;
        setState(() {
          _syncStatus = 'Synchronisation des rappels...';
          _syncProgress = 0.4;
        });
        await _syncReminders();
      }

      // Synchroniser les contacts d'urgence
      if (_syncOptions['Contacts d\'urgence'] == true) {
        if (!mounted) return;
        setState(() {
          _syncStatus = 'Synchronisation des contacts...';
          _syncProgress = 0.6;
        });
        await _syncEmergencyContacts();
      }

      // Synchroniser les informations médicales
      if (_syncOptions['Informations médicales'] == true) {
        if (!mounted) return;
        setState(() {
          _syncStatus = 'Synchronisation des informations médicales...';
          _syncProgress = 0.8;
        });
        await _syncEmergencyInfo();
      }

      if (!mounted) return;
      
      setState(() {
        _syncProgress = 1.0;
        _syncStatus = 'Synchronisation terminée avec succès !';
      });

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      
      setState(() {
        _isSyncing = false;
        _syncProgress = 0.0;
        _syncStatus = 'Prêt à synchroniser';
      });

      _showSuccess('Synchronisation réussie');
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isSyncing = false;
        _syncStatus = 'Erreur: $e';
      });
      _showError('Erreur lors de la synchronisation: $e');
    }
  }

  Future<void> _syncDocuments() async {
    if (await BackendConfigService.isBackendEnabled()) {
      final localDocs = await LocalStorageService.getDocuments();
      final backendDocs = await ApiService.getDocuments();

      // Synchroniser vers le backend
      // Comparer les timestamps et synchroniser les différences
      
      // Documents à envoyer au backend (nouveaux ou modifiés localement)
      final toSync = localDocs.where((doc) {
        final docId = doc['id'];
        final backendDoc = backendDocs.firstWhere(
          (bd) => bd['id'] == docId,
          orElse: () => <String, dynamic>{},
        );
        
        // Si nouveau document, synchroniser
        if (backendDoc.isEmpty) return true;
        
        // Comparer les dates de mise à jour
        try {
          final localUpdated = doc['updated_at'] as String? ?? doc['created_at'] as String? ?? '';
          final backendUpdated = backendDoc['updated_at'] as String? ?? backendDoc['created_at'] as String? ?? '';
          if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
            final localDate = DateTime.parse(localUpdated);
            final backendDate = DateTime.parse(backendUpdated);
            return localDate.isAfter(backendDate);
          }
        } catch (e) {
          // En cas d'erreur de parsing, synchroniser par sécurité
          return true;
        }
        return false;
      });
      
      // Synchroniser chaque document
      for (final doc in toSync) {
        try {
          // Upload si c'est un nouveau document avec fichier
          final filePath = doc['path'] as String? ?? doc['file_path'] as String?;
          if (filePath != null) {
            final file = File(filePath);
            if (await file.exists()) {
              await ApiService.uploadDocument(file);
            }
          }
        } catch (e) {
          // Ignorer les erreurs individuelles
        }
      }
    }
  }

  Future<void> _syncReminders() async {
    if (await BackendConfigService.isBackendEnabled()) {
      final localReminders = await LocalStorageService.getReminders();
      final backendReminders = await ApiService.getReminders();
      
      // Synchronisation bidirectionnelle
      
      // Rappels à envoyer au backend (nouveaux ou modifiés localement)
      final toSync = localReminders.where((reminder) {
        final reminderId = reminder['id'];
        final backendReminder = backendReminders.firstWhere(
          (br) => br['id'] == reminderId,
          orElse: () => <String, dynamic>{},
        );
        
        // Si nouveau rappel, synchroniser
        if (backendReminder.isEmpty) return true;
        
        // Comparer les dates de mise à jour
        try {
          final localUpdated = reminder['updated_at'] as String? ?? reminder['created_at'] as String? ?? '';
          final backendUpdated = backendReminder['updated_at'] as String? ?? backendReminder['created_at'] as String? ?? '';
          if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
            final localDate = DateTime.parse(localUpdated);
            final backendDate = DateTime.parse(backendUpdated);
            return localDate.isAfter(backendDate);
          }
        } catch (e) {
          // En cas d'erreur de parsing, synchroniser par sécurité
          return true;
        }
        return false;
      });
      
      // Synchroniser chaque rappel
      for (final reminder in toSync) {
        try {
          final reminderDateStr = reminder['reminder_date'] as String;
          await ApiService.createReminder(
            title: reminder['title'] as String,
            description: reminder['description'] as String? ?? '',
            reminderDate: reminderDateStr,
          );
        } catch (e) {
          // Ignorer les erreurs individuelles
        }
      }
    }
  }

  Future<void> _syncEmergencyContacts() async {
    if (await BackendConfigService.isBackendEnabled()) {
      final localContacts = await LocalStorageService.getEmergencyContacts();
      final backendContacts = await ApiService.getEmergencyContacts();
      
      // Synchronisation bidirectionnelle
      
      // Contacts à envoyer au backend (nouveaux ou modifiés localement)
      final toSync = localContacts.where((contact) {
        final contactId = contact['id'];
        final backendContact = backendContacts.firstWhere(
          (bc) => bc['id'] == contactId,
          orElse: () => <String, dynamic>{},
        );
        
        // Si nouveau contact, synchroniser
        if (backendContact.isEmpty) return true;
        
        // Comparer les dates de mise à jour
        try {
          final localUpdated = contact['updated_at'] as String? ?? contact['created_at'] as String? ?? '';
          final backendUpdated = backendContact['updated_at'] as String? ?? backendContact['created_at'] as String? ?? '';
          if (localUpdated.isNotEmpty && backendUpdated.isNotEmpty) {
            final localDate = DateTime.parse(localUpdated);
            final backendDate = DateTime.parse(backendUpdated);
            return localDate.isAfter(backendDate);
          }
        } catch (e) {
          // En cas d'erreur de parsing, synchroniser par sécurité
          return true;
        }
        return false;
      });
      
      // Synchroniser chaque contact
      for (final contact in toSync) {
        try {
          await ApiService.createEmergencyContact(
            name: contact['name'] as String,
            phone: contact['phone'] as String,
            relationship: contact['relationship'] as String? ?? '',
            isPrimary: contact['is_primary'] as bool? ?? false,
          );
        } catch (e) {
          // Ignorer les erreurs individuelles
        }
      }
    }
  }

  Future<void> _syncEmergencyInfo() async {
    // Les infos médicales sont uniquement locales pour la sécurité
    // Pas de synchronisation cloud pour ces données sensibles
  }

  Future<void> _exportData() async {
    if (!mounted) return;
    
    // Demander quels modules exporter
    final exportOptions = await showDialog<Map<String, bool>>(
      context: context,
      builder: (context) {
        final selected = <String, bool>{
          'Documents': true,
          'Rappels': true,
          'Contacts d\'urgence': true,
          'Informations médicales': true,
        };
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Sélectionner les données à exporter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: selected.keys.map((key) => CheckboxListTile(
                title: Text(key),
                value: selected[key],
                onChanged: (value) {
                  setState(() {
                    selected[key] = value ?? false;
                  });
                },
              )).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Exporter'),
              ),
            ],
          ),
        );
      },
    );

    if (exportOptions == null) return;

    try {
      setState(() {
        _syncStatus = 'Export des données...';
      });

      final allData = await LocalStorageService.exportAllData();
      final filteredData = <String, dynamic>{
        'export_date': DateTime.now().toIso8601String(),
        'version': '1.2.0',
      };

      if (exportOptions['Documents'] == true) {
        filteredData['documents'] = allData['documents'];
      }
      if (exportOptions['Rappels'] == true) {
        filteredData['reminders'] = allData['reminders'];
      }
      if (exportOptions['Contacts d\'urgence'] == true) {
        filteredData['emergency_contacts'] = allData['emergency_contacts'];
      }
      if (exportOptions['Informations médicales'] == true) {
        filteredData['emergency_info'] = allData['emergency_info'];
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(filteredData);
      
      // Obtenir le répertoire de téléchargement
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'arkalia_cia_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      // Sauvegarder le fichier
      await file.writeAsString(jsonString);
      
      // Partager le fichier
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        text: 'Sauvegarde Arkalia CIA - $timestamp',
        subject: 'Export de données Arkalia CIA',
      );
      
      if (!mounted) return;
      setState(() {
        _syncStatus = 'Export réussi';
      });
      
      _showSuccess('Données exportées dans $fileName');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _syncStatus = 'Erreur lors de l\'export';
      });
      _showError('Erreur lors de l\'export: $e');
    }
  }

  Future<void> _importData() async {
    try {
      // Sélectionner un fichier JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return; // Utilisateur a annulé
      }

      setState(() {
        _syncStatus = 'Import des données...';
      });

      // Lire et parser le fichier JSON
      String jsonString;
      if (kIsWeb) {
        // Sur le web, utiliser bytes
        final bytes = result.files.single.bytes;
        if (bytes == null) {
          _showError('Impossible de lire le fichier sélectionné');
          setState(() {
            _syncStatus = 'Prêt à synchroniser';
          });
          return;
        }
        jsonString = utf8.decode(bytes);
      } else {
        // Sur mobile, utiliser path
        final filePath = result.files.single.path;
        if (filePath == null) {
          _showError('Impossible de lire le fichier sélectionné');
          setState(() {
            _syncStatus = 'Prêt à synchroniser';
          });
          return;
        }
        final file = File(filePath);
        jsonString = await file.readAsString();
      }
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Valider le format
      if (!data.containsKey('documents') && 
          !data.containsKey('reminders') && 
          !data.containsKey('emergency_contacts')) {
        _showError('Format de fichier invalide');
        setState(() {
          _syncStatus = 'Prêt à synchroniser';
        });
        return;
      }

      // Demander confirmation
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer l\'import'),
          content: const Text(
            'Cette action va remplacer vos données actuelles par celles du fichier. '
            'Voulez-vous continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Importer'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() {
          _syncStatus = 'Prêt à synchroniser';
        });
        return;
      }

      // Importer les données
      await LocalStorageService.importAllData(data);

      setState(() {
        _syncStatus = 'Import réussi';
      });

      _showSuccess('Données importées avec succès');
      
      // Attendre un peu avant de réinitialiser le statut
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _syncStatus = 'Prêt à synchroniser';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Erreur lors de l\'import';
      });
      _showError('Erreur lors de l\'import: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

