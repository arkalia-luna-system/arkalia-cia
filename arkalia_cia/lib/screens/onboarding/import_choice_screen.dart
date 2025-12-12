import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../services/onboarding_service.dart';
import '../../services/health_portal_import_service.dart';
import '../../utils/error_helper.dart';
import 'import_progress_screen.dart';
import 'import_type.dart';
import '../home_page.dart';

class ImportChoiceScreen extends StatefulWidget {
  const ImportChoiceScreen({super.key});

  @override
  State<ImportChoiceScreen> createState() => _ImportChoiceScreenState();
}

class _ImportChoiceScreenState extends State<ImportChoiceScreen> {
  void _showImportManualGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Importer depuis un portail santé',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choisissez votre portail :',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Andaman 7
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickAndImportPDFs('andaman7');
              },
              icon: const Icon(Icons.medical_services),
              label: const Text('Andaman 7'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            
            // MaSanté
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickAndImportPDFs('masante');
              },
              icon: const Icon(Icons.health_and_safety),
              label: const Text('MaSanté'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            
            // Instructions
            ExpansionTile(
              title: const Text('Comment exporter depuis le portail ?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionStep('1', 'Ouvrez l\'app Andaman 7 ou le portail MaSanté'),
                      _buildInstructionStep('2', 'Allez dans "Mes documents" ou "Exporter"'),
                      _buildInstructionStep('3', 'Sélectionnez "Exporter en PDF"'),
                      _buildInstructionStep('4', 'Sauvegardez le PDF sur votre appareil'),
                      _buildInstructionStep('5', 'Revenez ici et uploadez le PDF'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImportPDFs([String? portal]) async {
    try {
      // Si portail spécifié, utiliser le nouveau service d'import portail
      if (portal != null && (portal == 'andaman7' || portal == 'masante')) {
        await _importFromPortal(portal);
        return;
      }

      // Sinon, import PDF générique (comportement existant)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          final fileDataList = <Map<String, dynamic>>[];
          for (final file in result.files) {
            if (file.bytes != null) {
              fileDataList.add({
                'name': file.name,
                'bytes': file.bytes!,
              });
            }
          }
          
          if (fileDataList.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aucun fichier valide sélectionné')),
              );
            }
            return;
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ImportProgressScreen(
                importType: ImportType.manualPDF,
                fileDataList: fileDataList,
              ),
            ),
          );
        } else {
          final filePaths = result.files
              .where((file) => file.path != null)
              .map((file) => file.path!)
              .toList();

          if (filePaths.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aucun fichier valide sélectionné')),
              );
            }
            return;
          }

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ImportProgressScreen(
                importType: ImportType.manualPDF,
                filePaths: filePaths,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ErrorHelper.logError('ImportChoiceScreen._pickAndImportPDFs', e);
      if (mounted) {
        final userMessage = ErrorHelper.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur sélection fichiers: $userMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importFromPortal(String portal) async {
    try {
      // Sélectionner fichier PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false, // Un seul fichier pour import portail
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.first;
      
      if (kIsWeb) {
        // Sur web, on ne peut pas utiliser File directement
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import portail non disponible sur web. Utilisez l\'import PDF générique.'),
            ),
          );
        }
        return;
      }

      if (pickedFile.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chemin fichier invalide')),
          );
        }
        return;
      }

      final file = File(pickedFile.path!);
      
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fichier non trouvé')),
          );
        }
        return;
      }

      // Afficher progression
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Import depuis $portal...'),
            ],
          ),
        ),
      );

      // Upload vers backend
      final uploadResult = await HealthPortalImportService.uploadPortalPDF(
        file,
        portal: portal,
      );

      // Fermer dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Afficher résultat
      if (mounted) {
        if (uploadResult['success'] == true) {
          final count = uploadResult['imported_count'] ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $count document(s) importé(s) avec succès depuis $portal'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          
          // Rediriger vers home après succès
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          final error = uploadResult['error'] ?? 'Erreur inconnue';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      ErrorHelper.logError('ImportChoiceScreen._importFromPortal', e);
      if (mounted) {
        Navigator.pop(context); // Fermer dialog si ouvert
        final userMessage = ErrorHelper.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur import: $userMessage'),
            backgroundColor: Colors.red,
          ),
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
        child: SingleChildScrollView(
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
              
              // Option 1 : Import manuel PDF (gratuit, fonctionne immédiatement) - PRIORITÉ
              _buildImportOption(
                context,
                icon: Icons.upload_file,
                title: 'Importer vos documents PDF (GRATUIT)',
                description: 'Exportez depuis Andaman 7 ou MaSanté\n'
                    'Puis uploadez vos PDFs ici - Fonctionne immédiatement',
                color: Colors.green,
                onTap: () => _showImportManualGuide(context),
              ),
              
              const SizedBox(height: 16),
              
              // Option 2 : Import eHealth (si accréditation obtenue)
              _buildImportOption(
                context,
                icon: Icons.cloud_download,
                title: 'Import automatique eHealth',
                description: 'Accréditation requise (1-3 mois)\n'
                    'Import automatique depuis eHealth',
                color: Colors.blue,
                onTap: () {
                  // Note: L'import automatique eHealth nécessite accréditation (1-3 mois)
                  // Voir INTEGRATION_EHEALTH_DETAILLEE.md pour procédure
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import eHealth - Accréditation requise (voir documentation)'),
                      duration: Duration(seconds: 4),
                    ),
                  );
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
              
              const SizedBox(height: 32),
              
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
              const SizedBox(height: 24),
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

