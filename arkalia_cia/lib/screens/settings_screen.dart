import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/auth_api_service.dart';
import '../services/auto_sync_service.dart';
import '../services/backend_config_service.dart';
import '../services/health_portal_auth_service.dart' show HealthPortalAuthService, HealthPortal;
import '../services/offline_cache_service.dart';
import '../services/accessibility_service.dart';
import '../services/google_auth_service.dart';
import '../utils/app_logger.dart';
import 'auth/login_screen.dart';
import 'auth/welcome_auth_screen.dart';
import 'stats_screen.dart';
import 'user_profile_screen.dart';

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
  AccessibilityTextSize _textSize = AccessibilityTextSize.normal;
  AccessibilityIconSize _iconSize = AccessibilityIconSize.normal;
  bool _simplifiedMode = false;

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
    final textSize = await AccessibilityService.getTextSize();
    final iconSize = await AccessibilityService.getIconSize();
    final simplifiedMode = await AccessibilityService.isSimplifiedModeEnabled();

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
        _textSize = textSize;
        _iconSize = iconSize;
        _simplifiedMode = simplifiedMode;
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Taille du texte'),
                  subtitle: Text(_textSize.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTextSizeDialog(),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Taille des icônes'),
                  subtitle: Text(_iconSize.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showIconSizeDialog(),
                ),
                const Divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.accessibility_new),
                  title: const Text('Mode simplifié'),
                  subtitle: const Text('Masquer les fonctionnalités avancées'),
                  value: _simplifiedMode,
                  onChanged: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await AccessibilityService.setSimplifiedMode(value);
                    if (!mounted) return;
                    setState(() {
                      _simplifiedMode = value;
                    });
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(value 
                          ? 'Mode simplifié activé' 
                          : 'Mode simplifié désactivé'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
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
                if (_backendEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Profil utilisateur'),
                    subtitle: FutureBuilder<String?>(
                      future: AuthApiService.getUsername(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Text('Connecté en tant que: ${snapshot.data}');
                        }
                        return const Text('Non connecté');
                      },
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Déconnexion'),
                    subtitle: const Text('Se déconnecter du compte'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      if (!mounted) return;
                      final isLoggedIn = await AuthApiService.isLoggedIn();
                      if (!mounted) return;
                      if (isLoggedIn) {
                        // Afficher dialog de déconnexion
                        if (!mounted) return;
                        final dialogContext = context;
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously - mounted vérifié juste avant
                        final shouldLogout = await showDialog<bool>(
                          context: dialogContext, // ignore: use_build_context_synchronously
                          builder: (context) => AlertDialog(
                            title: const Text('Déconnexion'),
                            content: const Text('Voulez-vous vous déconnecter ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Déconnexion'),
                              ),
                            ],
                          ),
                        );
                        
                        if (shouldLogout == true) {
                          if (!mounted) return;
                          
                          // Vérifier si l'utilisateur est connecté avec Google et déconnecter
                          try {
                            final isGoogleSignedIn = await GoogleAuthService.isSignedIn();
                            if (isGoogleSignedIn) {
                              await GoogleAuthService.signOut();
                            }
                          } catch (e) {
                            // Ignorer les erreurs de déconnexion Google
                            AppLogger.debug('Erreur lors de la déconnexion Google: $e');
                          }
                          
                          // Déconnexion backend si nécessaire
                          await AuthApiService.logout();
                          if (!mounted) return;
                          final navContext = context; // Capturer context après await
                          if (navContext.mounted) {
                            Navigator.of(navContext).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const WelcomeAuthScreen()),
                              (route) => false,
                            );
                          }
                        }
                      } else {
                        if (!mounted) return;
                        // Rediriger vers login
                        final navContext = context; // Capturer context après await
                        if (navContext.mounted) {
                          Navigator.of(navContext).push(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      }
                    },
                  ),
                ],
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
                              style: const TextStyle(fontSize: 16),
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
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Version'),
                  subtitle: Text('1.3.1+1'),
                ),
                const ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Licence'),
                  subtitle: Text('MIT'),
                ),
                ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: const Text('Avertissement médical'),
                  subtitle: const Text('Voir les mentions légales'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMedicalDisclaimer(),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Politique de confidentialité'),
                  subtitle: const Text('Voir les informations'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyInfo(),
                ),
              ],
            ),
          ),

          // Section Portails Santé
          _buildSectionTitle('Portails Santé'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.health_and_safety),
                  title: const Text('Configuration Portails'),
                  subtitle: const Text('Configurer les credentials OAuth'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPortalCredentialsDialog(),
                ),
              ],
            ),
          ),

          // Section Statistiques
          _buildSectionTitle('Statistiques'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Statistiques détaillées'),
                  subtitle: const Text('Voir graphiques et analyses complètes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Cache
          _buildSectionTitle('Cache'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Nettoyer le cache'),
                  subtitle: const Text('Supprimer tous les caches'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearCacheDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPortalName(HealthPortal portal) {
    switch (portal) {
      case HealthPortal.ehealth:
        return 'eHealth';
      case HealthPortal.andaman7:
        return 'Andaman 7';
      case HealthPortal.masante:
        return 'MaSanté';
    }
  }

  Future<void> _showPortalCredentialsDialog() async {
    final portal = await showDialog<HealthPortal>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir un portail'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('eHealth'),
              onTap: () => Navigator.pop(context, HealthPortal.ehealth),
            ),
            ListTile(
              title: const Text('Andaman 7'),
              onTap: () => Navigator.pop(context, HealthPortal.andaman7),
            ),
            ListTile(
              title: const Text('MaSanté'),
              onTap: () => Navigator.pop(context, HealthPortal.masante),
            ),
          ],
        ),
      ),
    );

    if (portal == null) return;

    final service = HealthPortalAuthService();
    final credentials = await service.getPortalCredentials(portal);
    
    final clientIdController = TextEditingController(text: credentials['client_id'] ?? '');
    final clientSecretController = TextEditingController(text: credentials['client_secret'] ?? '');

    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Credentials ${_getPortalName(portal)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                hintText: 'Entrez le Client ID OAuth',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: clientSecretController,
              decoration: const InputDecoration(
                labelText: 'Client Secret',
                hintText: 'Entrez le Client Secret OAuth',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result == true) {
      await service.setPortalCredentials(
        portal,
        clientIdController.text.trim(),
        clientSecretController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credentials sauvegardés')),
        );
      }
    }
  }

  Future<void> _showClearCacheDialog() async {
    if (!mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nettoyer le cache'),
        content: const Text(
          'Voulez-vous supprimer tous les caches ? Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nettoyer'),
          ),
        ],
      ),
    );

    if (result == true) {
      await OfflineCacheService.clearAllCaches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache nettoyé avec succès')),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  void _showMedicalDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.medical_services, color: Colors.red),
            SizedBox(width: 8),
            Text('Avertissement Médical'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IMPORTANT : Arkalia CIA n\'est PAS un dispositif médical ou un outil de diagnostic.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'L\'application :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('❌ Ne fournit PAS de conseils médicaux, de diagnostics ou de traitements'),
              SizedBox(height: 8),
              Text('❌ Ne remplace PAS les conseils de professionnels de santé'),
              SizedBox(height: 8),
              Text('✅ Est un outil d\'organisation pour gérer vos documents et rappels'),
              SizedBox(height: 16),
              Text(
                'Toujours consulter un professionnel de santé qualifié pour toute décision médicale.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Nous ne sommes pas responsables des décisions médicales prises sur la base d\'informations stockées dans l\'application.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('J\'ai compris'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taille du texte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AccessibilityTextSize.values.map((size) {
            return RadioListTile<AccessibilityTextSize>(
              title: Text(
                size.label,
                style: TextStyle(fontSize: (14 * size.multiplier)),
              ),
              subtitle: Text(
                'Exemple de texte avec cette taille',
                style: TextStyle(fontSize: (12 * size.multiplier)),
              ),
              value: size,
              groupValue: _textSize,
              onChanged: (value) async {
                if (value != null) {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  await AccessibilityService.setTextSize(value);
                  if (!mounted) return;
                  setState(() {
                    _textSize = value;
                  });
                  if (!mounted) return;
                  navigator.pop();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Taille du texte : ${value.label}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showIconSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taille des icônes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AccessibilityIconSize.values.map((size) {
            return RadioListTile<AccessibilityIconSize>(
              title: Text(size.label),
              subtitle: Row(
                children: [
                  Icon(Icons.home, size: (24.0 * size.multiplier)),
                  const SizedBox(width: 8),
                  Icon(Icons.settings, size: (24.0 * size.multiplier)),
                  const SizedBox(width: 8),
                  Icon(Icons.favorite, size: (24.0 * size.multiplier)),
                ],
              ),
              value: size,
              groupValue: _iconSize,
              onChanged: (value) async {
                if (value != null) {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  await AccessibilityService.setIconSize(value);
                  if (!mounted) return;
                  setState(() {
                    _iconSize = value;
                  });
                  if (!mounted) return;
                  navigator.pop();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Taille des icônes : ${value.label}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: Colors.blue),
            SizedBox(width: 8),
            Text('Politique de Confidentialité'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arkalia CIA respecte votre vie privée :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('✅ Aucune collecte de données'),
              Text('   Toutes vos données restent sur votre appareil'),
              SizedBox(height: 8),
              Text('✅ Aucune transmission'),
              Text('   Vos données ne quittent jamais votre téléphone'),
              SizedBox(height: 8),
              Text('✅ Chiffrement AES-256'),
              Text('   Tous vos documents sont chiffrés localement'),
              SizedBox(height: 8),
              Text('✅ Stockage 100% local'),
              Text('   Aucun cloud, aucun serveur externe'),
              SizedBox(height: 16),
              Text(
                'Vous avez le contrôle total sur vos données. Vous pouvez les exporter ou les supprimer à tout moment.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

