import 'package:flutter/material.dart';

/// Filtres chips par type d'examen (répartition fournie par l'écran parent).
class DocumentsExamFilters extends StatelessWidget {
  const DocumentsExamFilters({
    super.key,
    required this.distribution,
    required this.selectedExamType,
    required this.onChanged,
  });

  final Map<String, int> distribution;
  final String? selectedExamType;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tous'),
            selected: selectedExamType == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          ...distribution.keys.map(
            (examType) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('$examType (${distribution[examType]})'),
                selected: selectedExamType == examType,
                onSelected: (selected) {
                  onChanged(selected ? examType : null);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
