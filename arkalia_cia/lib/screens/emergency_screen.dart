import 'package:flutter/material.dart';
import '../services/contacts_service.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../widgets/emergency_contact_dialog.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/emergency_info_card.dart';
import '../utils/error_helper.dart';
import '../utils/input_sanitizer.dart';

/// Écran de gestion des contacts et informations d'urgence
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<dynamic> emergencyContacts = [];
  Map<String, dynamic> emergencyInfo = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Vérifier d'abord la permission avant de charger les contacts
      final hasPermission = await ContactsService.hasContactsPermission();
      
      if (!hasPermission) {
        // Demander la permission avec un dialogue explicatif
        final granted = await _requestContactsPermissionWithDialog();
        if (!granted) {
          if (mounted) {
            setState(() {
              emergencyContacts = [];
              isLoading = false;
            });
            // Charger quand même les infos médicales et les contacts locaux
            final info = await LocalStorageService.getEmergencyInfo();
            if (mounted) {
              setState(() {
                emergencyInfo = info ?? {};
              });
            }
          }
          return;
        }
      }

      final contactsList = await ContactsService.getEmergencyContacts();
      final info = await LocalStorageService.getEmergencyInfo();

      if (mounted) {
        setState(() {
          emergencyContacts = contactsList;
          emergencyInfo = info ?? {};
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      // Ne pas afficher d'erreur si c'est juste une permission refusée
      if (!e.toString().contains('Permission')) {
        ErrorHelper.logError('EmergencyScreen._loadData', e);
        _showError(ErrorHelper.getUserFriendlyMessage(e));
      }
    }
  }

  Future<bool> _requestContactsPermissionWithDialog() async {
    // Ne pas afficher le dialog si on n'est pas sur l'écran Urgence
    if (!mounted) return false;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Permission Contacts'),
        content: const Text(
          'Arkalia CIA a besoin d\'accéder à vos contacts pour afficher '
          'vos contacts d\'urgence (ICE).\n\n'
          'Vos données restent privées et ne quittent jamais votre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(100, 48), // Minimum 48px pour accessibilité seniors
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48), // Minimum 48px pour accessibilité seniors
            ),
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );

    if (result == true) {
      return await ContactsService.requestContactsPermission();
    }
    return false;
  }

  Future<void> _showAddContactDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const EmergencyContactDialog(),
    );

    if (result != null) {
      await _addContact(result);
    }
  }

  Future<void> _showEditContactDialog(Map<String, dynamic> contact) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EmergencyContactDialog(existingContact: contact),
    );

    if (result != null) {
      await _updateContact(result);
    }
  }

  Future<void> _addContact(Map<String, dynamic> contactData) async {
    try {
      // 1. Sauvegarder dans le backend si configuré
      final backendConfigured = await ApiService.isBackendConfigured();
      if (backendConfigured) {
        try {
          final backendResult = await ApiService.createEmergencyContact(
            name: contactData['name']!,
            phone: contactData['phone']!,
            relationship: contactData['relationship'] ?? '',
            isPrimary: contactData['is_primary'] ?? false,
          );
          
          // Le backend retourne soit un objet avec 'id' (succès) soit un objet avec 'error' (échec)
          if (backendResult.containsKey('error') || backendResult['success'] == false) {
            // Erreur backend, afficher message détaillé
            final errorMsg = backendResult['error'] ?? 
                           backendResult['technical_error'] ?? 
                           'Erreur lors de la sauvegarde sur le serveur';
            _showError('Erreur serveur: $errorMsg');
            return;
          }
          
          // Si le backend retourne un ID, l'utiliser (succès)
          if (backendResult['id'] != null) {
            contactData['id'] = backendResult['id'];
          }
        } catch (e) {
          // Erreur backend, afficher message détaillé et arrêter
          ErrorHelper.logError('EmergencyScreen._addContact (backend)', e);
          final errorMsg = ErrorHelper.getUserFriendlyMessage(e);
          _showError('Erreur serveur: $errorMsg');
          return;
        }
      }
      
      // 2. Ajouter au système natif (contacts du téléphone)
      try {
        await ContactsService.addEmergencyContact(
          name: contactData['name']!,
          phone: contactData['phone']!,
          relationship: contactData['relationship'] ?? '',
        );
      } catch (e) {
        // Erreur système natif, continuer quand même avec stockage local
        ErrorHelper.logError('EmergencyScreen._addContact (contacts natifs)', e);
      }

      // 3. Sauvegarder localement
      await LocalStorageService.saveEmergencyContact(contactData);
      await _loadData();
      _showSuccess('Contact d\'urgence ajouté avec succès');
    } catch (e) {
      ErrorHelper.logError('EmergencyScreen._addContact', e);
      _showError(ErrorHelper.getUserFriendlyMessage(e));
    }
  }

  Future<void> _updateContact(Map<String, dynamic> contactData) async {
    try {
      await LocalStorageService.updateEmergencyContact(contactData);
      await _loadData();
      _showSuccess('Contact modifié avec succès');
    } catch (e) {
      ErrorHelper.logError('EmergencyScreen._updateContact', e);
      _showError(ErrorHelper.getUserFriendlyMessage(e));
    }
  }

  Future<void> _deleteContact(Map<String, dynamic> contact) async {
    final confirmed = await _showConfirmDialog(
      'Supprimer le contact',
      'Êtes-vous sûr de vouloir supprimer ${contact['name']} ?',
    );

    if (confirmed) {
      try {
        await LocalStorageService.deleteEmergencyContact(contact['id']);
        await _loadData();
        _showSuccess('Contact supprimé');
      } catch (e) {
        ErrorHelper.logError('EmergencyScreen._deleteContact', e);
        _showError(ErrorHelper.getUserFriendlyMessage(e));
      }
    }
  }

  Future<void> _showEditInfoDialog() async {
    final controllers = <String, TextEditingController>{};
    final fields = {
      'blood_type': 'Groupe sanguin',
      'allergies': 'Allergies',
      'medical_conditions': 'Conditions médicales',
      'medications': 'Médicaments',
      'emergency_notes': 'Notes d\'urgence',
    };

    for (final key in fields.keys) {
      controllers[key] = TextEditingController(
        text: emergencyInfo[key] as String? ?? '',
      );
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations médicales d\'urgence'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: controllers[entry.key]!,
                        decoration: InputDecoration(
                          labelText: entry.value,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: entry.key == 'emergency_notes' ? 3 : 1,
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size(100, 48), // Minimum 48px pour accessibilité seniors
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final data = <String, dynamic>{};
              for (final entry in controllers.entries) {
                // Sanitizer les entrées utilisateur pour prévenir XSS
                final sanitizedValue = InputSanitizer.sanitizeForStorage(entry.value.text.trim());
                data[entry.key] = sanitizedValue;
              }
              Navigator.of(context).pop(data);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48), // Minimum 48px pour accessibilité seniors
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    // Nettoyer les contrôleurs
    for (final controller in controllers.values) {
      controller.dispose();
    }

    if (result != null) {
      await _saveEmergencyInfo(result);
    }
  }

  Future<void> _saveEmergencyInfo(Map<String, dynamic> info) async {
    try {
      await LocalStorageService.saveEmergencyInfo(info);
      await _loadData();
      _showSuccess('Informations sauvegardées');
    } catch (e) {
      ErrorHelper.logError('EmergencyScreen._saveEmergencyInfo', e);
      _showError(ErrorHelper.getUserFriendlyMessage(e));
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(120, 48), // Minimum 48px pour accessibilité seniors
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Urgences'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Boutons d'urgence
            _buildEmergencyButtons(),
            const SizedBox(height: 24),

            // Informations médicales
            EmergencyInfoCard(
              emergencyInfo: emergencyInfo,
              onEdit: _showEditInfoDialog,
            ),
            const SizedBox(height: 24),

            // Section contacts
            _buildContactsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Colors.red.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmergencyButtons() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Numéros d\'urgence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency('112'),
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('Ambulance\n112'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency('100'),
                    icon: const Icon(Icons.fire_truck),
                    label: const Text('Pompiers\n100'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency('101'),
                    icon: const Icon(Icons.local_police),
                    label: const Text('Police\n101'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      minimumSize: const Size(0, 48), // Minimum 48px pour accessibilité seniors
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contacts, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Contacts d\'urgence',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (emergencyContacts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.contact_phone_outlined,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun contact d\'urgence',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des contacts pour les situations d\'urgence',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          ...emergencyContacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: EmergencyContactCard(
                  contact: contact is Map<String, dynamic>
                      ? contact
                      : {
                          'name': contact.displayName ?? 'Contact sans nom',
                          'phone': contact.phones?.first?.value ?? '',
                          'relationship': contact.phones?.first?.label ?? '',
                          'is_primary': false,
                        },
                  onEdit: () => _showEditContactDialog(contact),
                  onDelete: () => _deleteContact(contact),
                ),
              )),
      ],
    );
  }

  Future<void> _callEmergency(String number) async {
    try {
      // Note: Utilisation d'URL launcher sera gérée par EmergencyContactCard
      _showSuccess('Appel vers le $number...');
    } catch (e) {
      ErrorHelper.logError('EmergencyScreen._callEmergency', e);
      _showError(ErrorHelper.getUserFriendlyMessage(e));
    }
  }
}
