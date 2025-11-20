import 'package:flutter/material.dart';
import 'screens/lock_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/local_storage_service.dart';
import 'services/calendar_service.dart';
import 'services/theme_service.dart';
import 'services/auto_sync_service.dart';
import 'services/auth_api_service.dart';
import 'services/backend_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await CalendarService.init();
  runApp(const ArkaliaCIAApp());
}

class ArkaliaCIAApp extends StatefulWidget {
  const ArkaliaCIAApp({super.key});

  @override
  State<ArkaliaCIAApp> createState() => _ArkaliaCIAAppState();
}

class _ArkaliaCIAAppState extends State<ArkaliaCIAApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
    _checkAutoSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AutoSyncService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Synchroniser quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed) {
      AutoSyncService.syncIfNeeded();
    }
  }

  Future<void> _checkAutoSync() async {
    // Synchroniser au démarrage si activé
    final syncOnStartup = await AutoSyncService.isSyncOnStartupEnabled();
    if (syncOnStartup) {
      // Attendre un peu pour que l'app soit complètement chargée
      Future.delayed(const Duration(seconds: 2), () {
        AutoSyncService.syncIfNeeded(force: true);
      });
    }
    
    // Démarrer la synchronisation périodique si activée
    final autoSyncEnabled = await AutoSyncService.isAutoSyncEnabled();
    if (autoSyncEnabled) {
      AutoSyncService.setAutoSyncEnabled(true);
    }
  }

  Future<void> _loadTheme() async {
    final themeMode = await ThemeService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arkalia CIA',
      theme: ThemeService.getThemeData('light', MediaQuery.platformBrightnessOf(context)),
      darkTheme: ThemeService.getThemeData('dark', Brightness.dark),
      themeMode: _themeMode,
      home: const _InitialScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Écran initial qui vérifie l'authentification API avant d'afficher LockScreen ou LoginScreen
class _InitialScreen extends StatefulWidget {
  const _InitialScreen();

  @override
  State<_InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<_InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Vérifier si le backend est configuré et activé
    final backendEnabled = await BackendConfigService.isBackendEnabled();
    
    if (backendEnabled) {
      // Si backend activé, vérifier l'authentification API
      final isLoggedIn = await AuthApiService.isLoggedIn();
      
      if (mounted) {
        if (isLoggedIn) {
          // Utilisateur connecté, aller à LockScreen (authentification biométrique locale)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LockScreen()),
          );
        } else {
          // Utilisateur non connecté, aller à LoginScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } else {
      // Backend non activé, aller directement à LockScreen (mode offline)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LockScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
