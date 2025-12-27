import 'package:flutter/material.dart';

/// Widget badge coloré avec icône selon type d'examen
class ExamTypeBadge extends StatelessWidget {
  final String? examType;
  final double? confidence;
  final bool showConfidence;

  const ExamTypeBadge({
    super.key,
    required this.examType,
    this.confidence,
    this.showConfidence = false,
  });

  /// Obtient l'icône selon le type d'examen
  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'radio':
      case 'radiographie':
        return Icons.radio_button_checked;
      case 'analyse':
        return Icons.science;
      case 'scanner':
        return Icons.scanner;
      case 'irm':
        return Icons.medical_services; // MRI icon not available, using medical_services
      case 'echographie':
      case 'échographie':
        return Icons.waves;
      case 'biopsie':
        return Icons.medical_services;
      case 'mammographie':
        return Icons.medical_services; // breastfeeding icon not available
      case 'densitometrie':
        return Icons.medical_services; // bone icon not available
      case 'endoscopie':
        return Icons.visibility;
      case 'electrocardiogramme':
      case 'ecg':
        return Icons.favorite;
      case 'electroencephalogramme':
      case 'eeg':
        return Icons.memory;
      default:
        return Icons.description;
    }
  }

  /// Obtient la couleur selon le type d'examen
  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'radio':
      case 'radiographie':
        return Colors.blue;
      case 'analyse':
        return Colors.red;
      case 'scanner':
        return Colors.orange;
      case 'irm':
        return Colors.purple;
      case 'echographie':
      case 'échographie':
        return Colors.teal;
      case 'biopsie':
        return Colors.pink;
      case 'mammographie':
        return Colors.pink.shade300;
      case 'densitometrie':
        return Colors.grey;
      case 'endoscopie':
        return Colors.green;
      case 'electrocardiogramme':
      case 'ecg':
        return Colors.red.shade300;
      case 'electroencephalogramme':
      case 'eeg':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Formate le nom du type d'examen pour affichage
  String _formatExamType(String type) {
    switch (type.toLowerCase()) {
      case 'radio':
        return 'Radiographie';
      case 'analyse':
        return 'Analyse';
      case 'scanner':
        return 'Scanner';
      case 'irm':
        return 'IRM';
      case 'echographie':
        return 'Échographie';
      case 'biopsie':
        return 'Biopsie';
      case 'mammographie':
        return 'Mammographie';
      case 'densitometrie':
        return 'Densitométrie';
      case 'endoscopie':
        return 'Endoscopie';
      case 'electrocardiogramme':
        return 'ECG';
      case 'electroencephalogramme':
        return 'EEG';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (examType == null || examType!.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = _getColor(examType!);
    final icon = _getIcon(examType!);
    final label = _formatExamType(examType!);
    final needsVerification = confidence != null && confidence! < 0.7;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            needsVerification ? '$label ?' : label,
            style: TextStyle(
              fontSize: 14, // Minimum 14sp pour accessibilité seniors
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showConfidence && confidence != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${(confidence! * 100).toInt()}%)',
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

