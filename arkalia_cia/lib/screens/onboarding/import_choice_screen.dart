import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/onboarding_service.dart';
import 'import_progress_screen.dart';
import '../home_page.dart';

class ImportChoiceScreen extends StatefulWidget {
  const ImportChoiceScreen({super.key});

  @override
  State<ImportChoiceScreen> createState() => _ImportChoiceScreenState();
}

class _ImportChoiceScreenState extends State<ImportChoiceScreen> {
  Future<void> _pickAndImportPDFs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // Rediriger vers écran progression
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ImportProgressScreen(
              importType: ImportType.manualPDF,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur sélection fichiers: $e')),
        );
      }
    }
  }

  Future<void> _skipImport() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import de vos données'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer votre historique médical',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Nous pouvons importer automatiquement vos données depuis vos portails santé pour créer votre historique complet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Option 1 : Import portails santé
              _buildImportOption(
                context,
                icon: Icons.cloud_download,
                title: 'Import automatique depuis portails santé',
                description: 'eHealth, Andaman 7, MaSanté\n'
                    'Création automatique historique intelligent',
                color: Colors.blue,
                onTap: () {
                  // TODO: Implémenter import portails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import portails - À venir bientôt !'),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Option 2 : Import manuel PDF
              _buildImportOption(
                context,
                icon: Icons.upload_file,
                title: 'Importer mes documents PDF',
                description: 'Sélectionner vos PDF médicaux\n'
                    'Extraction automatique données essentielles',
                color: Colors.green,
                onTap: () async {
                  await _pickAndImportPDFs();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Option 3 : Commencer vide
              _buildImportOption(
                context,
                icon: Icons.add_circle_outline,
                title: 'Commencer sans import',
                description: 'Créer votre historique manuellement\n'
                    'Vous pourrez importer plus tard',
                color: Colors.grey,
                onTap: _skipImport,
              ),
              
              const Spacer(),
              
              // Note importante
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'L\'import peut prendre quelques minutes, mais vous aurez un historique complet dès le départ.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

