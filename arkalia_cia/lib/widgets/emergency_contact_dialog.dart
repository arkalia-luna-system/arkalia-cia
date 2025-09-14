import 'package:flutter/material.dart';

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
  bool isPrimary = false;

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
    isPrimary = widget.existingContact?['is_primary'] ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    relationshipController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      nameController.text.trim().isNotEmpty &&
      phoneController.text.trim().isNotEmpty;

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
              decoration: const InputDecoration(
                labelText: 'Nom du contact',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
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
                  final contactData = {
                    'name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'relationship': relationshipController.text.trim(),
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
}
