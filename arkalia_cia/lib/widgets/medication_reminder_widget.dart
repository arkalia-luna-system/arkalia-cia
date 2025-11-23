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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isTaken ? 1 : 3,
      color: isTaken ? Colors.grey[200] : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icône médicament
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isTaken ? Colors.grey : Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication,
                color: Colors.blue,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // Informations
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
                      color: isTaken ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (medication.dosage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dosage: ${medication.dosage}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Boutons d'action
            if (!isTaken) ...[
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: onTaken,
                tooltip: 'Marquer comme pris',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: onIgnore,
                tooltip: 'Ignorer',
              ),
            ] else ...[
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

