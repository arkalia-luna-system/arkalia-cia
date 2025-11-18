import 'package:flutter/material.dart';

/// Widget pour afficher les informations médicales d'urgence
class EmergencyInfoCard extends StatelessWidget {
  final Map<String, dynamic> emergencyInfo;
  final VoidCallback? onEdit;

  const EmergencyInfoCard({
    super.key,
    required this.emergencyInfo,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = emergencyInfo.isEmpty ||
        emergencyInfo.values.every((value) =>
            value == null || value.toString().trim().isEmpty);

    if (isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.medical_information_outlined,
                size: 48,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune information médicale',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez vos informations médicales importantes\npour les urgences',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter des informations'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information,
                  color: Colors.red.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Informations médicales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Modifier les informations',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ..._buildInfoItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInfoItems() {
    final items = <Widget>[];

    final infoMap = {
      'blood_type': ('Groupe sanguin', Icons.bloodtype),
      'allergies': ('Allergies', Icons.warning),
      'medical_conditions': ('Conditions médicales', Icons.local_hospital),
      'medications': ('Médicaments', Icons.medication),
      'emergency_notes': ('Notes d\'urgence', Icons.note),
    };

    for (final entry in infoMap.entries) {
      final key = entry.key;
      final label = entry.value.$1;
      final icon = entry.value.$2;
      final value = emergencyInfo[key] as String?;

      if (value != null && value.trim().isNotEmpty) {
        items.add(_buildInfoItem(label, value, icon));
        items.add(const SizedBox(height: 12));
      }
    }

    if (items.isEmpty) {
      return [
        Text(
          'Aucune information disponible',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ];
    }

    // Retirer le dernier SizedBox
    if (items.isNotEmpty) {
      items.removeLast();
    }

    return items;
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.red.shade400,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
