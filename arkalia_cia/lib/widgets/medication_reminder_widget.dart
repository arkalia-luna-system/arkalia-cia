import 'package:flutter/material.dart';
import '../models/medication.dart';

/// Widget pour afficher un rappel de médicament
class MedicationReminderWidget extends StatelessWidget {
  final Medication medication;
  final TimeOfDay time;
  final bool isTaken;
  final VoidCallback? onTaken;
  final VoidCallback? onIgnore;

  const MedicationReminderWidget({
    super.key,
    required this.medication,
    required this.time,
    this.isTaken = false,
    this.onTaken,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Semantics(
      container: true,
      label:
          isTaken
              ? '${medication.name}, pris à $timeLabel'
              : '${medication.name}, à prendre à $timeLabel',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: isTaken ? 1 : 3,
        color:
            isTaken
                ? scheme.surfaceContainerHighest
                : scheme.primaryContainer.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isTaken ? scheme.outlineVariant : scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: isTaken ? scheme.onSurfaceVariant : scheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                        color:
                            isTaken
                                ? scheme.onSurfaceVariant
                                : scheme.onSurface,
                      ),
                    ),
                    if (medication.dosage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Dosage : ${medication.dosage}',
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isTaken) ...[
                Semantics(
                  button: true,
                  label: 'Marquer ${medication.name} comme pris',
                  child: IconButton(
                    icon: Icon(Icons.check_circle, color: scheme.primary),
                    onPressed: onTaken,
                    tooltip: 'Marquer comme pris',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Ignorer le rappel ${medication.name}',
                  child: IconButton(
                    icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                    onPressed: onIgnore,
                    tooltip: 'Ignorer',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle,
                  color: scheme.primary,
                  size: 32,
                  semanticLabel: 'Médicament pris',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
