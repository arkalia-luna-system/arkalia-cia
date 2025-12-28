import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utils/validation_helper.dart';
import '../../utils/input_sanitizer.dart';
import '../../services/contacts_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts_api;

/// Dialog pour ajouter/éditer un contact d'urgence
class EmergencyContactDialog extends StatefulWidget {
  final Map<String, dynamic>? existingContact;

  const EmergencyContactDialog({
    super.key,
    this.existingContact,
  });

  @override
  State<EmergencyContactDialog> createState() => _EmergencyContactDialogState();
}

class _EmergencyContactDialogState extends State<EmergencyContactDialog> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController relationshipController;
  late final TextEditingController displayNameController;
  late final TextEditingController emojiController;
  bool isPrimary = false;
  Color selectedColor = Colors.red;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.existingContact?['name'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.existingContact?['phone'] ?? '',
    );
    relationshipController = TextEditingController(
      text: widget.existingContact?['relationship'] ?? '',
    );
    displayNameController = TextEditingController(
      text: widget.existingContact?['display_name'] ?? widget.existingContact?['name'] ?? '',
    );
    emojiController = TextEditingController(
      text: widget.existingContact?['emoji'] ?? '👤',
    );
    isPrimary = widget.existingContact?['is_primary'] ?? false;
    if (widget.existingContact?['color'] != null) {
      selectedColor = Color(widget.existingContact!['color'] as int);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
    displayNameController.dispose();
    emojiController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      ValidationHelper.isValidName(nameController.text.trim()) &&
      ValidationHelper.isValidPhone(phoneController.text.trim());

  Future<void> _importFromContacts() async {
    try {
      final contacts = await ContactsService.getContacts();
      if (contacts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun contact trouvé')),
          );
        }
        return;
      }

      // Afficher un dialog pour sélectionner un contact
      if (!mounted) return;
      final selectedContact = await showDialog<contacts_api.Contact>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sélectionner un contact'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final name = '${contact.name.first} ${contact.name.last}'.trim();
                final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                return ListTile(
                  title: Text(name),
                  subtitle: phone.isNotEmpty ? Text(phone) : null,
                  onTap: () => Navigator.of(context).pop(contact),
                );
              },
            ),
          ),
        ),
      );

      if (selectedContact != null && mounted) {
        final name = '${selectedContact.name.first} ${selectedContact.name.last}'.trim();
        final phone = selectedContact.phones.isNotEmpty 
            ? selectedContact.phones.first.number 
            : '';
        
        setState(() {
          nameController.text = name;
          phoneController.text = phone;
          if (displayNameController.text.isEmpty) {
            displayNameController.text = name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingContact != null;

    return AlertDialog(
      title: Text(isEditing ? 'Modifier le contact' : 'Nouveau contact d\'urgence'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nom du contact',
                border: const OutlineInputBorder(),
                errorText: nameController.text.isNotEmpty && 
                    !ValidationHelper.isValidName(nameController.text.trim())
                    ? 'Nom invalide (min 2 caractères, lettres uniquement)'
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                border: const OutlineInputBorder(),
                helperText: 'Format: 04XX XX XX XX ou +32 4XX XX XX XX',
                errorText: phoneController.text.isNotEmpty && 
                    !ValidationHelper.isValidPhone(phoneController.text.trim())
                    ? 'Numéro invalide'
                    : null,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
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
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Nom affiché (optionnel)',
                helperText: 'Nom personnalisé pour l\'affichage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emojiController,
                    decoration: const InputDecoration(
                      labelText: 'Emoji (optionnel)',
                      helperText: 'Ex: 👨‍⚕️, 👩‍⚕️, 🚑',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 2,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Couleur', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showColorPicker(),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!kIsWeb)
              TextButton.icon(
                onPressed: _importFromContacts,
                icon: const Icon(Icons.contact_phone),
                label: const Text('Importer depuis les contacts'),
              ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Contact principal'),
              subtitle: const Text('Ce contact sera affiché en premier'),
              value: isPrimary,
              onChanged: (value) {
                setState(() {
                  isPrimary = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () {
                  // Sanitizer les entrées utilisateur pour prévenir XSS
                  final sanitizedName = InputSanitizer.sanitizeForStorage(nameController.text.trim());
                  final sanitizedPhone = phoneController.text.trim(); // Phone déjà validé par ValidationHelper
                  final sanitizedRelationship = relationshipController.text.trim().isNotEmpty
                      ? InputSanitizer.sanitizeForStorage(relationshipController.text.trim())
                      : '';
                  final sanitizedDisplayName = displayNameController.text.trim().isNotEmpty 
                      ? InputSanitizer.sanitizeForStorage(displayNameController.text.trim())
                      : sanitizedName;
                  final sanitizedEmoji = emojiController.text.trim().isNotEmpty 
                      ? emojiController.text.trim() // Emoji ne nécessite pas de sanitization
                      : '👤';
                  
                  final contactData = {
                    'name': sanitizedName,
                    'phone': sanitizedPhone,
                    'relationship': sanitizedRelationship,
                    'display_name': sanitizedDisplayName,
                    'emoji': sanitizedEmoji,
                    'color': selectedColor.value, // Utilisation de .value pour obtenir la valeur entière ARGB
                    'is_primary': isPrimary,
                    if (isEditing) 'id': widget.existingContact!['id'],
                  };
                  Navigator.of(context).pop(contactData);
                }
              : null,
          child: Text(isEditing ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }

  void _showColorPicker() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = color;
                });
                Navigator.of(context).pop();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == color ? Colors.black : Colors.grey,
                    width: selectedColor == color ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
