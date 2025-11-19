import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/auto_sync_service.dart';
import '../services/backend_config_service.dart';

/// Écran de paramètres de l'application
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentTheme = 'system';
  bool _biometricEnabled = true;
  bool _authOnStartup = true;
  bool _autoSyncEnabled = true;
  bool _syncOnStartup = true;
  bool _syncOnlyOnWifi = false;
  DateTime? _lastSyncTime;
  Map<String, dynamic>? _lastSyncStats;
  String _backendUrl = '';
  bool _backendEnabled = false;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir les statistiques quand on revient sur l'écran
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await ThemeService.getTheme();
    final biometricEnabled = await AuthService.isAuthEnabled();
    final authOnStartup = await AuthService.shouldAuthenticateOnStartup();
    final autoSyncEnabled = await AutoSyncService.isAutoSyncEnabled();
    final syncOnStartup = await AutoSyncService.isSyncOnStartupEnabled();
    final syncOnlyOnWifi = await AutoSyncService.isSyncOnlyOnWifi();
    final lastSyncTime = await AutoSyncService.getLastSyncTime();
    final lastSyncStats = await AutoSyncService.getLastSyncStats();
    final backendUrl = await BackendConfigService.getBackendURL();
    final backendEnabled = await BackendConfigService.isBackendEnabled();

    if (mounted) {
      setState(() {
        _currentTheme = theme;
        _biometricEnabled = biometricEnabled;
        _authOnStartup = authOnStartup;
        _autoSyncEnabled = autoSyncEnabled;
        _syncOnStartup = syncOnStartup;
        _syncOnlyOnWifi = syncOnlyOnWifi;
        _lastSyncTime = lastSyncTime;
        _lastSyncStats = lastSyncStats;
        _backendUrl = backendUrl;
        _backendEnabled = backendEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Apparence
          _buildSectionTitle('Apparence'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Thème'),
                  subtitle: Text(_getThemeLabel(_currentTheme)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Sécurité
          _buildSectionTitle('Sécurité'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Authentification biométrique'),
                  subtitle: const Text('Protéger l\'application avec empreinte/visage'),
                  value: _biometricEnabled,
                  onChanged: (value) async {
                    await AuthService.setAuthEnabled(value);
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.lock),
                  title: const Text('Verrouillage au démarrage'),
                  subtitle: const Text('Demander authentification à l\'ouverture'),
                  value: _authOnStartup,
                  onChanged: (value) async {
                    await AuthService.setAuthOnStartup(value);
                    setState(() {
                      _authOnStartup = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Synchronisation
          _buildSectionTitle('Synchronisation'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.sync),
                  title: const Text('Synchronisation automatique'),
                  subtitle: const Text('Synchroniser automatiquement quand l\'app est active'),
                  value: _autoSyncEnabled,
                  onChanged: (value) async {
                    await AutoSyncService.setAutoSyncEnabled(value);
                    setState(() {
                      _autoSyncEnabled = value;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.refresh),
                  title: const Text('Synchroniser au démarrage'),
                  subtitle: const Text('Synchroniser automatiquement à l\'ouverture de l\'app'),
                  value: _syncOnStartup,
                  onChanged: (value) async {
                    await AutoSyncService.setSyncOnStartup(value);
                    setState(() {
                      _syncOnStartup = value;
                    });
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.wifi),
                  title: const Text('Synchroniser uniquement sur WiFi'),
                  subtitle: const Text('Économiser les données mobiles'),
                  value: _syncOnlyOnWifi,
                  onChanged: (value) async {
                    await AutoSyncService.setSyncOnlyOnWifi(value);
                    setState(() {
                      _syncOnlyOnWifi = value;
                    });
                  },
                ),
                if (_lastSyncTime != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.sync, color: Colors.orange),
                    title: const Text('Dernière synchronisation'),
                    subtitle: Text(
                      AutoSyncService.formatLastSyncTime(_lastSyncTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: _lastSyncStats != null
                        ? Chip(
                            label: Text(
                              '${_lastSyncStats!['docs'] ?? 0} docs, ${_lastSyncStats!['reminders'] ?? 0} rappels, ${_lastSyncStats!['contacts'] ?? 0} contacts',
                              style: const TextStyle(fontSize: 14),
                            ),
                            backgroundColor: Colors.green[100],
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Backend
          _buildSectionTitle('Backend API'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.cloud),
                  title: const Text('Activer le backend'),
                  subtitle: Text(_backendUrl.isEmpty 
                    ? 'Configurez l\'URL du backend ci-dessous'
                    : 'Backend: $_backendUrl'),
                  value: _backendEnabled,
                  onChanged: _backendUrl.isEmpty ? null : (value) async {
                    await BackendConfigService.setBackendEnabled(value);
                    setState(() {
                      _backendEnabled = value;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('URL du backend'),
                  subtitle: Text(_backendUrl.isEmpty 
                    ? 'Non configuré (ex: http://192.168.1.100:8000)'
                    : _backendUrl),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_backendUrl.isNotEmpty && !_isTestingConnection)
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: _testBackendConnection,
                          tooltip: 'Tester la connexion',
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: _showBackendConfigDialog,
                ),
                if (_isTestingConnection)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section À propos
          _buildSectionTitle('À propos'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.2.0+1'),
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Licence'),
                  subtitle: Text('MIT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      default:
        return 'Système';
    }
  }

  Future<void> _showThemeDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clair'),
              leading: Icon(
                _currentTheme == 'light' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _currentTheme == 'light' ? Theme.of(context).primaryColor : null,
              ),
              onTap: () => Navigator.pop(context, 'light'),
            ),
            ListTile(
              title: const Text('Sombre'),
              leading: Icon(
                _currentTheme == 'dark' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _currentTheme == 'dark' ? Theme.of(context).primaryColor : null,
              ),
              onTap: () => Navigator.pop(context, 'dark'),
            ),
            ListTile(
              title: const Text('Système'),
              leading: Icon(
                _currentTheme == 'system' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _currentTheme == 'system' ? Theme.of(context).primaryColor : null,
              ),
              onTap: () => Navigator.pop(context, 'system'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await ThemeService.setTheme(result);
      if (!mounted) return;
      setState(() {
        _currentTheme = result;
      });
      // Recharger l'app pour appliquer le thème
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redémarrez l\'application pour appliquer le thème'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showBackendConfigDialog() async {
    final urlController = TextEditingController(text: _backendUrl);
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuration Backend'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrez l\'URL du backend API.\n\n'
                'Sur mobile (iPad/S25), utilisez l\'IP locale de votre Mac, par exemple:\n'
                'http://192.168.1.100:8000\n\n'
                '⚠️ Ne pas utiliser localhost sur mobile !',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL du backend',
                  hintText: 'http://192.168.1.100:8000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                Navigator.pop(context, {'url': url});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL invalide. Doit commencer par http:// ou https://'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result != null && result['url'] != null) {
      await BackendConfigService.setBackendURL(result['url'] as String);
      await _loadSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL du backend enregistrée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _testBackendConnection() async {
    if (_backendUrl.isEmpty) return;
    
    setState(() {
      _isTestingConnection = true;
    });

    final isConnected = await BackendConfigService.testConnection(_backendUrl);
    
    if (mounted) {
      setState(() {
        _isTestingConnection = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected 
            ? '✅ Connexion réussie au backend !'
            : '❌ Impossible de se connecter au backend. Vérifiez l\'URL et que le backend est démarré.'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

