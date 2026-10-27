import 'package:flutter/material.dart';

/// Widget affichant suggestions IA basées sur pathologies
class PathologyAISuggestions extends StatelessWidget {
  final String pathologyName;
  final List<String> questions;
  final VoidCallback? onQuestionTap;

  const PathologyAISuggestions({
    super.key,
    required this.pathologyName,
    required this.questions,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.45),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vous suivez $pathologyName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Questions à poser à votre médecin :',
            style: TextStyle(
              fontSize: 14, // Minimum 14sp pour accessibilité seniors
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...questions.take(5).map((question) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: onQuestionTap,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize:
                              14, // Minimum 14sp pour accessibilité seniors
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
