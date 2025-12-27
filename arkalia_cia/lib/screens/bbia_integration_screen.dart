import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Écran d'intégration BBIA - Robot Cognitif Reachy Mini
/// Affiche les informations sur le projet BBIA et la roadmap d'intégration
class BBIAIntegrationScreen extends StatelessWidget {
  const BBIAIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intégration BBIA'),
        backgroundColor: Colors.deepPurple[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section avec icône robot améliorée
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple[400]!,
                    Colors.deepPurple[600]!,
                    Colors.deepPurple[800]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Icône robot avec effet
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      MdiIcons.robot,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Titre
                  Text(
                    'BBIA - Robot Cognitif',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Sous-titre
                  Text(
                    'Moteur cognitif pour Reachy Mini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Description enrichie
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.deepPurple[600],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'À propos de BBIA',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BBIA-SIM est un moteur de robot cognitif avancé conçu pour le robot Reachy Mini. '
                      'Il intègre des capacités d\'IA pour les émotions, la vision par ordinateur, '
                      'la reconnaissance vocale et les interactions gestuelles.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTechChip(context, 'Python', Colors.blue),
                        _buildTechChip(context, 'MuJoCo', Colors.orange),
                        _buildTechChip(context, 'IA Émotions', Colors.pink),
                        _buildTechChip(context, 'Vision', Colors.green),
                        _buildTechChip(context, 'Reachy Mini', Colors.deepPurple),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Fonctionnalités prévues
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          MdiIcons.robotIndustrial,
                          color: Colors.deepPurple[600],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Fonctionnalités prévues',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      context,
                      MdiIcons.microphone,
                      'Commandes vocales',
                      'Contrôler l\'application via commandes vocales avec reconnaissance vocale avancée',
                      Colors.blue,
                    ),
                    _buildFeatureItem(
                      context,
                      MdiIcons.monitor,
                      'Affichage sur robot',
                      'Visualiser vos données santé sur l\'écran du robot Reachy Mini en temps réel',
                      Colors.green,
                    ),
                    _buildFeatureItem(
                      context,
                      MdiIcons.handWave,
                      'Interaction gestuelle',
                      'Interagir avec le robot par gestes et postures détectées par MediaPipe Pose',
                      Colors.orange,
                    ),
                    _buildFeatureItem(
                      context,
                      MdiIcons.medicalBag,
                      'Assistant santé robotique',
                      'Le robot vous aide avec vos rappels médicaux, questions santé et suivi de pathologies',
                      Colors.red,
                    ),
                    _buildFeatureItem(
                      context,
                      MdiIcons.emoticonHappy,
                      'Reconnaissance d\'émotions',
                      'Détection des émotions via DeepFace pour une interaction plus naturelle et empathique',
                      Colors.pink,
                    ),
                    _buildFeatureItem(
                      context,
                      MdiIcons.eye,
                      'Vision par ordinateur',
                      'Reconnaissance faciale, détection d\'objets et analyse d\'images médicales',
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statut du projet
            Card(
              color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Statut du projet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'BBIA-SIM v1.3.2 est actuellement disponible avec support Python 3.11+, '
                      'CI/CD complet, documentation et archives. L\'intégration avec Arkalia CIA '
                      'est en cours de développement et sera disponible dans une future version.',
                      style: TextStyle(
                        color: isDark ? Colors.blue[200] : Colors.blue[900],
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '1362 tests collectés • 68.86% coverage • SDK officiel validé',
                            style: TextStyle(
                              color: isDark ? Colors.blue[200] : Colors.blue[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Liens vers projets GitHub
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ressources',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildLinkButton(
                      context,
                      'BBIA-SIM sur GitHub',
                      'Moteur cognitif Reachy Mini',
                      'https://github.com/arkalia-luna-system/bbia-sim',
                      MdiIcons.github,
                      Colors.deepPurple,
                    ),
                    const SizedBox(height: 12),
                    _buildLinkButton(
                      context,
                      'BBIA Branding',
                      'Identité visuelle et assets',
                      'https://github.com/arkalia-luna-system/bbia_branding',
                      MdiIcons.palette,
                      Colors.pink,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Spécifications techniques
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          MdiIcons.information,
                          color: Colors.deepPurple[600],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Spécifications techniques',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSpecItem(context, 'Modèle', 'Reachy Mini Wireless'),
                    _buildSpecItem(context, 'Simulateur', 'MuJoCo'),
                    _buildSpecItem(context, 'Format', 'MJCF (MuJoCo XML)'),
                    _buildSpecItem(context, 'Articulations', '16 au total'),
                    _buildSpecItem(context, 'Assets', '41 fichiers STL officiels'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context,
    String title,
    String subtitle,
    String url,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

