import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ARIAScreen extends StatefulWidget {
  const ARIAScreen({super.key});

  @override
  State<ARIAScreen> createState() => _ARIAScreenState();
}

class _ARIAScreenState extends State<ARIAScreen> {
  bool _isARIAConnected = false;

  @override
  void initState() {
    super.initState();
    _checkARIAConnection();
  }

  Future<void> _checkARIAConnection() async {
    // Simulation de vérification de connexion ARIA
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isARIAConnected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARKALIA ARIA'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec statut
            _buildHeader(),

            const SizedBox(height: 24),

            // Description
            _buildDescription(),

            const SizedBox(height: 24),

            // Actions principales
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionButton(
                    context,
                    icon: MdiIcons.heartPulse,
                    title: 'Saisie Rapide',
                    subtitle: '3 questions',
                    color: Colors.red,
                    onTap: () => _launchARIA('quick-entry'),
                  ),

                  _buildActionButton(
                    context,
                    icon: MdiIcons.chartLine,
                    title: 'Historique',
                    subtitle: 'Voir les données',
                    color: Colors.blue,
                    onTap: () => _launchARIA('history'),
                  ),

                  _buildActionButton(
                    context,
                    icon: MdiIcons.brain,
                    title: 'Patterns',
                    subtitle: 'Analyse IA',
                    color: Colors.purple,
                    onTap: () => _launchARIA('patterns'),
                  ),

                  _buildActionButton(
                    context,
                    icon: MdiIcons.download,
                    title: 'Export Psy',
                    subtitle: 'Pour psychologue',
                    color: Colors.green,
                    onTap: () => _launchARIA('export'),
                  ),
                ],
              ),
            ),

            // Bouton d'accès direct
            _buildDirectAccessButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: _isARIAConnected ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _isARIAConnected ? MdiIcons.checkCircle : MdiIcons.alertCircle,
                  color: _isARIAConnected ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isARIAConnected ? 'ARIA Connecté' : 'ARIA Déconnecté',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isARIAConnected ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text(
                        _isARIAConnected
                          ? 'Laboratoire de recherche santé opérationnel'
                          : 'Vérifiez que le serveur ARIA est démarré',
                        style: TextStyle(
                          color: _isARIAConnected ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
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

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(MdiIcons.information, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'À propos d\'ARIA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'ARKALIA ARIA est votre laboratoire de recherche santé personnel. '
              'Il vous permet de :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Enregistrer vos douleurs rapidement (3 questions)\n'
              '• Analyser vos patterns avec l\'IA\n'
              '• Prédire les épisodes difficiles\n'
              '• Exporter vos données pour votre psychologue',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectAccessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isARIAConnected ? () => _launchARIA('home') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(MdiIcons.openInApp),
        label: Text(
          _isARIAConnected ? 'Ouvrir ARIA dans le navigateur' : 'ARIA non disponible',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _launchARIA(String page) async {
    if (!_isARIAConnected) {
      _showError('ARIA n\'est pas connecté');
      return;
    }

    String url;
    switch (page) {
      case 'quick-entry':
        url = 'http://localhost:8080/#/quick-entry';
        break;
      case 'history':
        url = 'http://localhost:8080/#/history';
        break;
      case 'patterns':
        url = 'http://localhost:8080/#/patterns';
        break;
      case 'export':
        url = 'http://localhost:8080/#/export';
        break;
      default:
        url = 'http://localhost:8080';
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Impossible d\'ouvrir ARIA');
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
