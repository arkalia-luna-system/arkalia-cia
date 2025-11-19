import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';
import '../home_page.dart';
import 'import_type.dart';

class ImportProgressScreen extends StatefulWidget {
  final ImportType importType;
  final List<String>? portalIds;

  const ImportProgressScreen({
    super.key,
    required this.importType,
    this.portalIds,
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
    setState(() {
      _progress = 0.1;
      _currentStep = 'Préparation import PDF...';
    });

    // Simuler progression import
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _progress = 0.3;
      _currentStep = 'Analyse des documents...';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _progress = 0.6;
      _currentStep = 'Extraction données essentielles...';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _progress = 0.9;
      _currentStep = 'Création historique...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // Extraction intelligente (simulée pour l'instant)
    final result = {
      'doctors': 0,
      'exams': 0,
      'dates': 0,
      'summary': 'Aucun document importé pour le moment',
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

    // TODO: Implémenter import portails
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _progress = 1.0;
      _currentStep = 'Import portails - À venir bientôt !';
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
            ],
          ),
        ),
      ),
    );
  }
}

