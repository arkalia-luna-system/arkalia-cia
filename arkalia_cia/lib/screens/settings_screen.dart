import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await ThemeService.getTheme();
    final biometricEnabled = await AuthService.isAuthEnabled();
    final authOnStartup = await AuthService.shouldAuthenticateOnStartup();

    setState(() {
      _currentTheme = theme;
      _biometricEnabled = biometricEnabled;
      _authOnStartup = authOnStartup;
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

          // Section À propos
          _buildSectionTitle('À propos'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.1.0+1'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Licence'),
                  subtitle: const Text('MIT'),
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
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'light',
              groupValue: _currentTheme,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Sombre'),
              value: 'dark',
              groupValue: _currentTheme,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<String>(
              title: const Text('Système'),
              value: 'system',
              groupValue: _currentTheme,
              onChanged: (value) => Navigator.pop(context, value),
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

