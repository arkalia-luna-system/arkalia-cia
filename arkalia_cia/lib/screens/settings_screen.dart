import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/auto_sync_service.dart';

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

    setState(() {
      _currentTheme = theme;
      _biometricEnabled = biometricEnabled;
      _authOnStartup = authOnStartup;
      _autoSyncEnabled = autoSyncEnabled;
      _syncOnStartup = syncOnStartup;
      _syncOnlyOnWifi = syncOnlyOnWifi;
      _lastSyncTime = lastSyncTime;
      _lastSyncStats = lastSyncStats;
    });
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
                              style: const TextStyle(fontSize: 11),
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

          // Section À propos
          _buildSectionTitle('À propos'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.1.0+1'),
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
}

