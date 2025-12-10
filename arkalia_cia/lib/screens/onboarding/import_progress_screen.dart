import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/onboarding_service.dart';
import '../../services/file_storage_service.dart';
import '../../services/local_storage_service.dart';
import '../home_page.dart';
import 'import_type.dart';

class ImportProgressScreen extends StatefulWidget {
  final ImportType importType;
  final List<String>? portalIds;
  final List<String>? filePaths;
  final List<Map<String, dynamic>>? fileDataList; // Pour le web: {name, bytes}

  const ImportProgressScreen({
    super.key,
    required this.importType,
    this.portalIds,
    this.filePaths,
    this.fileDataList,
  });

  @override
  State<ImportProgressScreen> createState() => _ImportProgressScreenState();
}

class _ImportProgressScreenState extends State<ImportProgressScreen> {
  double _progress = 0.0;
  String _currentStep = 'Initialisation...';
  Map<String, dynamic>? _importResult;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    try {
      if (widget.importType == ImportType.manualPDF) {
        await _importManualPDF();
      } else if (widget.importType == ImportType.portals) {
        await _importFromPortals();
      } else {
        await _skipImport();
      }
    } catch (e) {
      setState(() {
        _currentStep = 'Erreur: $e';
      });
    }
  }

  Future<void> _importManualPDF() async {
    if (kIsWeb) {
      await _importManualPDFWeb();
    } else {
      await _importManualPDFMobile();
    }
  }

  Future<void> _importManualPDFWeb() async {
    final fileDataList = widget.fileDataList ?? [];
    
    if (fileDataList.isEmpty) {
      setState(() {
        _currentStep = 'Aucun fichier à importer';
        _isComplete = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      _completeOnboarding();
      return;
    }

    int importedCount = 0;
    int totalFiles = fileDataList.length;

    setState(() {
      _progress = 0.1;
      _currentStep = 'Préparation import de $totalFiles fichier(s)...';
    });

    for (int i = 0; i < fileDataList.length; i++) {
      final fileData = fileDataList[i];
      final fileName = fileData['name'] as String;
      final bytes = fileData['bytes'] as Uint8List;

      try {
        setState(() {
          _progress = 0.1 + (i / totalFiles) * 0.7;
          _currentStep = 'Import du fichier ${i + 1}/$totalFiles...';
        });

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$fileName';

        // Sur le web, on stocke directement dans LocalStorageService
        // On ne peut pas utiliser FileStorageService car il nécessite path_provider
        final document = {
          'id': '${timestamp}_$i',
          'name': uniqueFileName,
          'original_name': fileName,
          'path': uniqueFileName, // Sur web, on utilise le nom comme identifiant
          'file_size': bytes.length,
          'category': 'Médical',
          'created_at': DateTime.now().toIso8601String(),
          'bytes': bytes, // Stocker les bytes pour le web
        };

        await LocalStorageService.saveDocument(document);
        importedCount++;
      } catch (e) {
        // Ignorer les erreurs et continuer
      }
    }

    setState(() {
      _progress = 1.0;
      _currentStep = '$importedCount fichier(s) importé(s) avec succès !';
      _isComplete = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    _completeOnboarding();
  }

  Future<void> _importManualPDFMobile() async {
    final filePaths = widget.filePaths ?? [];
    
    if (filePaths.isEmpty) {
      setState(() {
        _currentStep = 'Aucun fichier à importer';
        _isComplete = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      _completeOnboarding();
      return;
    }

    int importedCount = 0;
    int totalFiles = filePaths.length;

    setState(() {
      _progress = 0.1;
      _currentStep = 'Préparation import de $totalFiles fichier(s)...';
    });

    for (int i = 0; i < filePaths.length; i++) {
      final filePath = filePaths[i];
      final file = File(filePath);
      
      if (!await file.exists()) {
        continue;
      }

      try {
        setState(() {
          _progress = 0.1 + (i / totalFiles) * 0.7;
          _currentStep = 'Import du fichier ${i + 1}/$totalFiles...';
        });

        // Obtenir le nom du fichier
        final fileName = file.path.split('/').last;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueFileName = '${timestamp}_$fileName';

        // Copier le fichier vers le répertoire documents
        final savedFile = await FileStorageService.copyToDocumentsDirectory(
          file,
          uniqueFileName,
        );

        // Sauvegarder les métadonnées
        final document = {
          'id': '${timestamp}_$i',
          'name': uniqueFileName,
          'original_name': fileName,
          'path': savedFile.path,
          'file_size': await savedFile.length(),
          'category': 'Médical',
          'created_at': DateTime.now().toIso8601String(),
        };

        await LocalStorageService.saveDocument(document);
        importedCount++;

        // Petit délai pour l'animation
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        // Continuer avec le fichier suivant en cas d'erreur
        continue;
      }
    }

    setState(() {
      _progress = 0.9;
      _currentStep = 'Finalisation...';
    });

    await Future.delayed(const Duration(seconds: 1));

    final result = {
      'doctors': 0,
      'exams': 0,
      'dates': 0,
      'summary': '$importedCount document(s) importé(s) avec succès',
    };

    setState(() {
      _progress = 1.0;
      _currentStep = 'Terminé !';
      _importResult = result;
      _isComplete = true;
    });

    // Attendre 2 secondes puis rediriger
    await Future.delayed(const Duration(seconds: 2));
    _completeOnboarding();
  }

  Future<void> _importFromPortals() async {
    setState(() {
      _progress = 0.1;
      _currentStep = 'Connexion aux portails...';
    });

    // Note: L'import automatique nécessite les APIs OAuth des portails santé
    // La structure est prête (HealthPortalAuthService), mais nécessite
    // la configuration des endpoints OAuth pour eHealth, Andaman 7, MaSanté
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _progress = 1.0;
      _currentStep = 'Import portails - Nécessite configuration APIs OAuth';
      _isComplete = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    _completeOnboarding();
  }

  Future<void> _skipImport() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icône
              Icon(
                Icons.cloud_download,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              
              const SizedBox(height: 32),
              
              // Titre
              Text(
                'Import en cours',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Étape actuelle
              Text(
                _currentStep,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Barre progression
              LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
              ),
              
              const SizedBox(height: 16),
              
              // Pourcentage
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Résultat import (si terminé)
              if (_importResult != null && _isComplete)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Historique créé avec succès !',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _importResult!['summary'] ?? '',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
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
}

