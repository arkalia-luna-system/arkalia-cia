import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Écran placeholder pour l'intégration future avec BBIA
/// Affiche les informations sur le projet BBIA et la roadmap d'intégration
class BBIAIntegrationScreen extends StatelessWidget {
  const BBIAIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intégration BBIA'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône robot
            Center(
              child: Icon(
                Icons.smart_toy,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Titre
            Text(
              'BBIA - Robot Cognitif',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'L\'intégration avec BBIA permettra d\'utiliser un robot cognitif pour interagir avec vos données de santé de manière naturelle.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Fonctionnalités prévues
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fonctionnalités prévues',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      context,
                      Icons.voice_chat,
                      'Commandes vocales',
                      'Contrôler l\'application via commandes vocales',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.screen_share,
                      'Affichage sur robot',
                      'Visualiser vos données santé sur l\'écran du robot',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.gesture,
                      'Interaction gestuelle',
                      'Interagir avec le robot par gestes',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.medical_services,
                      'Assistant santé robotique',
                      'Le robot vous aide avec vos rappels et questions santé',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Statut
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Cette fonctionnalité est en cours de développement. '
                        'Elle sera disponible dans une future version.',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Lien vers projet BBIA
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('https://github.com/arkalia-luna-system/bbia-sim');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Voir le projet BBIA sur GitHub'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

