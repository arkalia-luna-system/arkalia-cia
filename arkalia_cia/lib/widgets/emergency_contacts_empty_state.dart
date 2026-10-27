import 'package:flutter/material.dart';

/// État vide de la liste des contacts d'urgence (vouvoiement, couleurs thème).
class EmergencyContactsEmptyState extends StatelessWidget {
  const EmergencyContactsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onVariant = scheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.contact_phone_outlined,
                size: 48,
                color: scheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun contact d\'urgence',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez ici 1 ou 2 personnes de confiance que vous pouvez appeler en cas de problème.',
              textAlign: TextAlign.center,
              style: TextStyle(color: onVariant, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
