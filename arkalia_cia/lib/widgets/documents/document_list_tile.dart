import 'package:flutter/material.dart';

import '../../models/document.dart';
import '../exam_type_badge.dart';

/// Tuile liste d'un document (actions déléguées à l'écran parent).
class DocumentListTile extends StatelessWidget {
  const DocumentListTile({
    super.key,
    required this.document,
    required this.formattedSize,
    required this.onPreview,
    required this.onShare,
    required this.onDelete,
  });

  final Document document;
  final String formattedSize;
  final VoidCallback onPreview;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.picture_as_pdf,
          color: scheme.error,
          size: 40,
        ),
        title: Text(
          document.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (document.examType != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ExamTypeBadge(
                    examType: document.examType,
                    confidence: document.examTypeConfidence,
                    showConfidence: document.needsVerification,
                  ),
                ),
              Text('Taille: $formattedSize', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                'Ajouté: ${document.createdAt ?? 'Inconnu'}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility, color: scheme.primary, size: 24),
              onPressed: onPreview,
              tooltip: 'Prévisualiser',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
            IconButton(
              icon: Icon(Icons.share, color: scheme.tertiary, size: 24),
              onPressed: onShare,
              tooltip: 'Partager',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: scheme.error, size: 24),
              onPressed: onDelete,
              tooltip: 'Supprimer',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
      ),
    );
  }
}
