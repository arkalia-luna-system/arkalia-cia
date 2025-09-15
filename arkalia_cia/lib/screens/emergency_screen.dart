import 'package:flutter/material.dart';
import '../services/contacts_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/emergency_contact_dialog.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/emergency_info_card.dart';

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
    setState(() => isLoading = true);

    try {
      final contactsList = await ContactsService.getEmergencyContacts();
      final info = await LocalStorageService.getEmergencyInfo();

      setState(() {
        emergencyContacts = contactsList;
        emergencyInfo = info ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Erreur lors du chargement: $e');
    }
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
      final success = await ContactsService.addEmergencyContact(
        name: contactData['name']!,
        phone: contactData['phone']!,
        relationship: contactData['relationship'] ?? '',
      );

      if (success) {
        await LocalStorageService.saveEmergencyContact(contactData);
        await _loadData();
        _showSuccess('Contact d\'urgence ajouté avec succès');
      } else {
        _showError('Erreur lors de l\'ajout du contact');
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  Future<void> _updateContact(Map<String, dynamic> contactData) async {
    try {
      await LocalStorageService.updateEmergencyContact(contactData);
      await _loadData();
      _showSuccess('Contact modifié avec succès');
    } catch (e) {
      _showError('Erreur lors de la modification: $e');
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
        _showError('Erreur lors de la suppression: $e');
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
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final data = <String, dynamic>{};
              for (final entry in controllers.entries) {
                data[entry.key] = entry.value.text.trim();
              }
              Navigator.of(context).pop(data);
            },
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
      _showError('Erreur lors de la sauvegarde: $e');
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency('15'),
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('SAMU\n15'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency('18'),
                    icon: const Icon(Icons.fire_truck),
                    label: const Text('Pompiers\n18'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency('17'),
                    icon: const Icon(Icons.local_police),
                    label: const Text('Police\n17'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                  Icon(
                    Icons.contact_phone_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
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
      _showError('Impossible d\'appeler: $e');
    }
  }
}
