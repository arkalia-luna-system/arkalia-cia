import 'package:flutter/material.dart';
import 'senior_empty_state.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final isEmpty =
        emergencyInfo.isEmpty ||
        emergencyInfo.values.every(
          (value) => value == null || value.toString().trim().isEmpty,
        );

    if (isEmpty) {
      return Card(
        child: SeniorEmptyState(
          icon: Icons.medical_information_outlined,
          title: 'Aucune information médicale',
          message:
              'Ajoutez vos informations médicales importantes pour les urgences',
          useErrorAccent: true,
          action: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter des informations'),
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
                Icon(Icons.medical_information, color: scheme.error, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Informations médicales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
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
            ..._buildInfoItems(scheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInfoItems(ColorScheme scheme) {
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
        items.add(_buildInfoItem(label, value, icon, scheme));
        items.add(const SizedBox(height: 12));
      }
    }

    if (items.isEmpty) {
      return [
        Text(
          'Aucune information disponible',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
            fontSize: 14,
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

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    ColorScheme scheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.error),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: scheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
