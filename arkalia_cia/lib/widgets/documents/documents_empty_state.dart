import 'package:flutter/material.dart';

/// État vide de la bibliothèque documents (vouvoiement, couleurs thème).
class DocumentsEmptyState extends StatelessWidget {
  const DocumentsEmptyState({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onVariant = scheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open, size: 64, color: scheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun document médical enregistré',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Appuyez sur le bouton ci-dessous pour ajouter votre premier document médical (ordonnance, résultat d’analyse, etc.).',
              style: TextStyle(color: onVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.upload),
            label: const Text('Ajouter un document médical'),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              minimumSize: const Size(220, 48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aucun résultat pour les filtres / recherche actifs.
class DocumentsFilterEmptyState extends StatelessWidget {
  const DocumentsFilterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onVariant = scheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 64, color: onVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun document trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Modifiez vos critères de recherche ou de filtre.',
            style: TextStyle(fontSize: 14, color: onVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
