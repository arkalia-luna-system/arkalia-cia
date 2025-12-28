import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/lock_screen.dart';
import 'screens/auth/welcome_auth_screen.dart';
import 'screens/home_page.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'services/local_storage_service.dart';
import 'services/calendar_service.dart';
import 'services/theme_service.dart';
import 'services/auto_sync_service.dart';
import 'services/auth_api_service.dart';
import 'services/backend_config_service.dart';
import 'services/google_auth_service.dart';
import 'services/auth_service.dart';
import 'services/pin_auth_service.dart';
import 'services/onboarding_service.dart';
import 'services/offline_cache_service.dart';
import 'services/notification_service.dart';
import 'services/runtime_security_service.dart';
import 'services/accessibility_service.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser databaseFactory pour le web (si nécessaire)
  if (kIsWeb) {
    // Pour le web, sqflite nécessite sqflite_common_ffi
    // Si le package n'est pas disponible, on continue sans initialisation
    // Les services géreront l'erreur gracieusement
    // Note: Le try-catch a été supprimé car le bloc était vide
    AppLogger.debug('Mode web: sqflite_common_ffi géré par les services si nécessaire.');
  }
  
  await LocalStorageService.init();
  await CalendarService.init();
  // Initialiser le service de notifications au démarrage
  await NotificationService.initialize();
  // Initialiser le service de sécurité runtime
  await RuntimeSecurityService.initialize();
  // Nettoyer automatiquement les caches expirés au démarrage et appliquer limite LRU
  await OfflineCacheService.cleanupOnStartup();
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
      // Nettoyer les caches expirés quand l'app revient au premier plan
      OfflineCacheService.clearExpiredCaches();
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
    return FutureBuilder<AccessibilityTextSize>(
      future: AccessibilityService.getTextSize(),
      builder: (context, snapshot) {
        final textSize = snapshot.data ?? AccessibilityTextSize.normal;
        final textScaler = TextScaler.linear(textSize.multiplier);
        
        return MaterialApp(
          title: 'Arkalia CIA',
          theme: ThemeService.getThemeData('light', MediaQuery.platformBrightnessOf(context)),
          darkTheme: ThemeService.getThemeData('dark', Brightness.dark),
          themeMode: _themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: child!,
            );
          },
          home: const _InitialScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
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
      final hasToken = await AuthApiService.isLoggedIn();
      
      if (mounted) {
        if (hasToken) {
          // Token présent : tenter de vérifier sa validité
          // Si le backend n'est pas accessible, on assume que le token est valide
          // (mode offline-first : on garde le token même si le backend est temporairement inaccessible)
          final backendUrl = await BackendConfigService.getBackendURL();
          if (backendUrl.isNotEmpty && !backendUrl.contains('localhost') && !backendUrl.contains('127.0.0.1')) {
            try {
              // Tenter un refresh silencieux (sans déconnecter en cas d'erreur réseau)
              final refreshResult = await AuthApiService.refreshToken();
              
              // Si le refresh échoue avec une erreur réseau, on garde le token
              // Seulement si c'est une erreur d'authentification (401/403), on déconnecte
              if (refreshResult['success'] == false && 
                  refreshResult['error']?.contains('Session expirée') == true) {
                // Token invalide : déconnecter et aller à WelcomeAuthScreen
                await AuthApiService.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const WelcomeAuthScreen()),
                  );
                }
                return;
              }
            } catch (e) {
              // Erreur réseau ou autre : on garde le token (mode offline-first)
              // Ne pas déconnecter l'utilisateur en cas d'erreur réseau
            }
          }
          
          // Token valide ou erreur réseau (on garde le token) : vérifier si auth activée
          // SIMPLIFIÉ : Aller à LockScreen seulement si authentification activée ET configurée
          // Sinon, vérifier onboarding et aller à WelcomeScreen ou HomePage
          final shouldShowLock = await _shouldShowLockScreen();
          if (mounted) {
            if (shouldShowLock) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LockScreen()),
              );
            } else {
              // Pas de LockScreen : vérifier onboarding avant d'aller à HomePage
              final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
              if (mounted) {
                if (!onboardingCompleted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              }
            }
          }
        } else {
          // Pas de token : aller à WelcomeAuthScreen pour login/register
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeAuthScreen()),
          );
        }
      }
    } else {
      // Backend non activé : vérifier Google Sign-In ou proposer WelcomeAuthScreen
      final isGoogleSignedIn = await GoogleAuthService.isSignedIn();
      
      if (mounted) {
        if (isGoogleSignedIn) {
          // SIMPLIFIÉ : Utilisateur connecté avec Google : vérifier si auth activée
          final shouldShowLock = await _shouldShowLockScreen();
          if (mounted) {
            if (shouldShowLock) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LockScreen()),
              );
            } else {
              // Pas de LockScreen : vérifier onboarding avant d'aller à HomePage
              final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
              if (mounted) {
                if (!onboardingCompleted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              }
            }
          }
        } else {
          // Pas de connexion Google : proposer WelcomeAuthScreen
          // L'utilisateur peut choisir de se connecter avec Google ou continuer sans compte (mode offline)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeAuthScreen()),
          );
        }
      }
    }
  }

  /// SIMPLIFIÉ : Vérifie si LockScreen doit être affiché
  /// LockScreen s'affiche seulement si authentification activée ET configurée
  Future<bool> _shouldShowLockScreen() async {
    final authEnabled = await AuthService.isAuthEnabled();
    if (!authEnabled) return false;
    
    final shouldAuthOnStartup = await AuthService.shouldAuthenticateOnStartup();
    if (!shouldAuthOnStartup) return false;
    
    // Sur web, vérifier si PIN configuré
    if (kIsWeb) {
      final pinConfigured = await PinAuthService.isPinConfigured();
      return pinConfigured;
    }
    
    // Sur mobile, authentification désactivée - pas de LockScreen
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: isDark ? Colors.white : Colors.green[700],
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: isDark ? Colors.white : Colors.green[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cela peut prendre quelques instants',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
