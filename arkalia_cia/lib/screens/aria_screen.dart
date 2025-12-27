import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/aria_service.dart';

class ARIAScreen extends StatefulWidget {
  const ARIAScreen({super.key});

  @override
  State<ARIAScreen> createState() => _ARIAScreenState();
}

class _ARIAScreenState extends State<ARIAScreen> {
  bool _isARIAConnected = false;
  bool _isChecking = false;
  String? _ariaIP;
  String? _ariaPort;

  @override
  void initState() {
    super.initState();
    _loadARIAConfig();
    _checkARIAConnection();
  }

  Future<void> _loadARIAConfig() async {
    final ip = await ARIAService.getARIAIP();
    final port = await ARIAService.getARIAPort();
    setState(() {
      _ariaIP = ip;
      _ariaPort = port;
    });
  }

  Future<void> _checkARIAConnection() async {
    setState(() {
      _isChecking = true;
    });

    final isConnected = await ARIAService.checkConnection();
    
    setState(() {
      _isARIAConnected = isConnected;
      _isChecking = false;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showConfigDialog,
            tooltip: 'Configuration',
          ),
          IconButton(
            icon: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isChecking ? null : _checkARIAConnection,
            tooltip: 'Vérifier la connexion',
          ),
        ],
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
                          : 'Vérifiez que le serveur ARIA est démarré\n(Configuration disponible dans les paramètres)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isARIAConnected ? Colors.green[600] : Colors.red[600],
                        ),
                      ),
                      if (_ariaIP != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Serveur: $_ariaIP:$_ariaPort',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isARIAConnected ? Colors.green[600] : Colors.red[600],
                          ),
                        ),
                      ],
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
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Enregistrer vos douleurs rapidement (3 questions)\n'
              '• Analyser vos patterns avec l\'IA\n'
              '• Prédire les épisodes difficiles\n'
              '• Exporter vos données pour votre psychologue',
              style: TextStyle(fontSize: 16),
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
                  fontSize: 14,
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
          _isARIAConnected 
            ? 'Accéder à ARIA' 
            : 'ARIA non disponible',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _launchARIA(String page) async {
    if (!_isARIAConnected) {
      _showError('ARIA n\'est pas connecté. Vérifiez que le serveur ARIA est démarré.');
      return;
    }

    // Sur mobile, l'accès ARIA via navigateur n'est pas disponible
    // Afficher un message clair à l'utilisateur
    _showError(
      'L\'accès ARIA via navigateur n\'est pas disponible sur mobile.\n\n'
      'Utilisez l\'application ARIA dédiée ou accédez-y depuis votre ordinateur.',
    );
    
    // Ne pas essayer d'ouvrir localhost sur mobile
    // (commenté pour référence future si besoin d'implémenter WebView)
    /*
    try {
      final url = await ARIAService.getPageURL(page);
      if (url == null) {
        _showError('Configuration ARIA incomplète. Définissez l\'IP du serveur.');
        return;
      }

      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Impossible d\'ouvrir ARIA. Vérifiez que le serveur est accessible.');
      }
    } catch (e) {
      _showError('Erreur: $e');
    }
    */
  }

  Future<void> _showConfigDialog() async {
    final ipController = TextEditingController(text: _ariaIP ?? '');
    final portController = TextEditingController(text: _ariaPort ?? '8080');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuration ARIA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'Adresse IP du serveur',
                hintText: '192.168.1.100',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '8080',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final detectedIP = await ARIAService.detectARIA();
                if (detectedIP != null) {
                  ipController.text = detectedIP;
                  _showSuccess('Serveur ARIA détecté: $detectedIP');
                } else {
                  _showError('Aucun serveur ARIA détecté automatiquement.');
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Détecter automatiquement'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ARIAService.setARIAIP(ipController.text.trim());
      await ARIAService.setARIAPort(portController.text.trim());
      await _loadARIAConfig();
      await _checkARIAConnection();
      _showSuccess('Configuration sauvegardée');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
