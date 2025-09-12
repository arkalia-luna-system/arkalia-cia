import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/contacts_service.dart';
import '../services/local_storage_service.dart';

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
    setState(() {
      isLoading = true;
    });

    try {
      // Charger les contacts ICE du carnet natif
      final contactsList = await ContactsService.getEmergencyContacts();

      // Charger les infos d'urgence stockées localement
      final info = await LocalStorageService.getEmergencyInfo();

      setState(() {
        emergencyContacts = contactsList;
        emergencyInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Erreur lors du chargement: $e');
    }
  }

  Future<void> _showAddContactDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();
    bool isPrimary = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau contact d\'urgence'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du contact',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relation (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Contact principal'),
                  subtitle: const Text('Ce contact sera affiché en premier'),
                  value: isPrimary,
                  onChanged: (value) {
                    setDialogState(() {
                      isPrimary = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'relationship': relationshipController.text,
                    'is_primary': isPrimary,
                  });
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _createContact(result);
    }
  }

  Future<void> _createContact(Map<String, dynamic> contactData) async {
    try {
      final success = await ContactsService.addEmergencyContact(
        name: contactData['name'],
        phone: contactData['phone'],
        relationship: contactData['relationship'],
      );

      if (success) {
        _showSuccess('Contact ajouté avec succès !');
        _loadData();
      } else {
        _showError('Erreur lors de l\'ajout du contact');
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  Future<void> _callContact(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showError('Impossible d\'ouvrir l\'application téléphone');
      }
    } catch (e) {
      _showError('Erreur appel: $e');
    }
  }

  Future<void> _copyPhoneNumber(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    _showSuccess('Numéro copié dans le presse-papiers');
  }

  Future<void> _showEmergencyInfoDialog() async {
    final bloodTypeController = TextEditingController(text: emergencyInfo['blood_type'] ?? '');
    final allergiesController = TextEditingController(text: emergencyInfo['allergies'] ?? '');
    final medicationsController = TextEditingController(text: emergencyInfo['medications'] ?? '');
    final medicalConditionsController = TextEditingController(text: emergencyInfo['medical_conditions'] ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fiche médicale d\'urgence'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bloodTypeController,
                decoration: const InputDecoration(
                  labelText: 'Groupe sanguin',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: A+, B-, O+, AB-',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Allergies',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Pénicilline, noix, pollen...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicationsController,
                decoration: const InputDecoration(
                  labelText: 'Médicaments actuels',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Insuline, Warfarine...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicalConditionsController,
                decoration: const InputDecoration(
                  labelText: 'Conditions médicales',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Diabète, hypertension...',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'blood_type': bloodTypeController.text,
                'allergies': allergiesController.text,
                'medications': medicationsController.text,
                'medical_conditions': medicalConditionsController.text,
              });
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _saveEmergencyInfo(result);
    }
  }

  Future<void> _saveEmergencyInfo(Map<String, dynamic> info) async {
    try {
      await LocalStorageService.saveEmergencyInfo(info);
      setState(() {
        emergencyInfo = info;
      });
      _showSuccess('Fiche médicale sauvegardée !');
    } catch (e) {
      _showError('Erreur sauvegarde: $e');
    }
  }

  Future<void> _callPrimaryContact() async {
    if (emergencyContacts.isNotEmpty) {
      final primaryContact = emergencyContacts.first;
      final phone = primaryContact.phones?.first.value;
      if (phone != null) {
        await _callContact(phone);
      } else {
        _showError('Aucun numéro de téléphone trouvé');
      }
    } else {
      _showError('Aucun contact d\'urgence configuré');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urgence'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_information),
            onPressed: _showEmergencyInfoDialog,
            tooltip: 'Fiche médicale',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // BOUTON D'URGENCE GÉANT
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton(
                      onPressed: _callPrimaryContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emergency,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'URGENCE',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Appuyer pour appeler le contact principal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // FICHE MÉDICALE D'URGENCE
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medical_information, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Fiche médicale d\'urgence',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: _showEmergencyInfoDialog,
                                tooltip: 'Modifier',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (emergencyInfo.isEmpty)
                            const Text(
                              'Aucune information médicale enregistrée.\nAppuyez sur ✏️ pour en ajouter.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (emergencyInfo['blood_type']?.isNotEmpty == true)
                                  _buildInfoRow('Groupe sanguin', emergencyInfo['blood_type']),
                                if (emergencyInfo['allergies']?.isNotEmpty == true)
                                  _buildInfoRow('Allergies', emergencyInfo['allergies']),
                                if (emergencyInfo['medications']?.isNotEmpty == true)
                                  _buildInfoRow('Médicaments', emergencyInfo['medications']),
                                if (emergencyInfo['medical_conditions']?.isNotEmpty == true)
                                  _buildInfoRow('Conditions médicales', emergencyInfo['medical_conditions']),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CONTACTS D'URGENCE
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contacts, color: Colors.purple[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Contacts d\'urgence',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[600],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _showAddContactDialog,
                                tooltip: 'Ajouter un contact',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (emergencyContacts.isEmpty)
                            const Text(
                              'Aucun contact d\'urgence configuré.\nAppuyez sur + pour en ajouter.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            ...emergencyContacts.map((contact) => _buildContactCard(contact)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(dynamic contact) {
    final phone = contact.phones?.first.value ?? '';
    final relationship = contact.phones?.first.label ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[600],
          child: const Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          contact.givenName ?? 'Contact',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phone,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.purple[700],
              ),
            ),
            if (relationship.isNotEmpty)
              Text(
                relationship,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () => _callContact(phone),
              tooltip: 'Appeler',
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              onPressed: () => _copyPhoneNumber(phone),
              tooltip: 'Copier le numéro',
            ),
          ],
        ),
      ),
    );
  }
}
