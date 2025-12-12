import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/pin_auth_service.dart';
import '../services/onboarding_service.dart';
import 'home_page.dart';
import 'onboarding/welcome_screen.dart';
import 'pin_entry_screen.dart';

/// Écran de verrouillage avec authentification biométrique
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;
  bool _isBiometricAvailable = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Initialise l'authentification : vérifie la disponibilité, puis lance l'auth
  /// SIMPLIFIÉ : LockScreen s'affiche seulement si authentification activée ET configurée
  /// La vérification de connexion est faite dans main.dart, pas besoin de la refaire ici
  Future<void> _initializeAuth() async {
    // Vérifier la disponibilité biométrique
    await _checkBiometricAvailability();
    
    // VÉRIFICATION FINALE : Si l'auth n'est pas vraiment disponible/configurée, aller directement à HomePage
    // (au cas où l'utilisateur arrive quand même sur LockScreen)
    final authEnabled = await AuthService.isAuthEnabled();
    if (!authEnabled) {
      _unlockApp();
      return;
    }
    
    final shouldAuth = await AuthService.shouldAuthenticateOnStartup();
    if (!shouldAuth) {
      _unlockApp();
      return;
    }
    
    if (kIsWeb) {
      final pinConfigured = await PinAuthService.isPinConfigured();
      if (!pinConfigured) {
        _unlockApp();
        return;
      }
    } else {
      if (!_isBiometricAvailable) {
        // Biométrie non disponible : permettre l'accès direct
        _unlockApp();
        return;
      }
    }
    
    // Lancer l'authentification au démarrage
    await _authenticateOnStartup();
  }

  Future<void> _checkBiometricAvailability() async {
    if (kIsWeb) {
      setState(() {
        _isBiometricAvailable = false;
      });
      return;
    }
    
    try {
      final available = await AuthService.isBiometricAvailable();
      final biometrics = await AuthService.getAvailableBiometrics();
      
      setState(() {
        _isBiometricAvailable = available && biometrics.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _authenticateOnStartup() async {
    // Sur web, gérer l'authentification PIN
    if (kIsWeb) {
      final pinConfigured = await PinAuthService.isPinConfigured();
      final shouldAuth = await AuthService.shouldAuthenticateOnStartup();
      final authEnabled = await AuthService.isAuthEnabled();
      
      // Si l'authentification est désactivée, permettre l'accès direct
      if (!authEnabled) {
        _unlockApp();
        return;
      }
      
      // Si l'authentification au démarrage est désactivée, permettre l'accès direct
      if (!shouldAuth) {
        _unlockApp();
        return;
      }
      
      // Si aucun PIN n'est configuré, permettre l'accès direct
      // L'utilisateur est déjà connecté (vérifié dans _initializeAuth)
      // Le PIN est optionnel pour la sécurité supplémentaire
      if (!pinConfigured) {
        // Pas de PIN configuré mais utilisateur connecté : permettre l'accès direct
        _unlockApp();
        return;
      }
      
      // PIN configuré, demander l'authentification
      await Future.delayed(const Duration(milliseconds: 500));
      await _authenticate();
      return;
    }
    
    // Sur mobile, utiliser l'authentification biométrique
    final shouldAuth = await AuthService.shouldAuthenticateOnStartup();
    final authEnabled = await AuthService.isAuthEnabled();
    
    // Si l'authentification est désactivée, permettre l'accès direct
    if (!authEnabled) {
      _unlockApp();
      return;
    }
    
    // Si l'authentification au démarrage est désactivée, permettre l'accès direct
    if (!shouldAuth) {
      _unlockApp();
      return;
    }
    
    // Authentification requise : lancer l'authentification
    // Même si la biométrie n'est pas disponible, le système proposera un code PIN
    // (biometricOnly: false dans AuthService.authenticate)
    await Future.delayed(const Duration(milliseconds: 500));
    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    // Sur web, utiliser l'écran de saisie PIN
    if (kIsWeb) {
      if (mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PinEntryScreen()),
        );
        if (result == true) {
          // PIN correct, déverrouiller l'app
          _unlockApp();
        } else {
          // PIN incorrect ou annulé
          setState(() {
            _errorMessage = 'Authentification échouée. Réessayez.';
          });
        }
      }
      return;
    }

    // Sur mobile, utiliser l'authentification biométrique
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final authenticated = await AuthService.authenticate(
        reason: 'Authentification requise pour accéder à Arkalia CIA',
      );

      if (authenticated) {
        _unlockApp();
      } else {
        setState(() {
          _errorMessage = 'Authentification échouée. Réessayez.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _unlockApp() async {
    // Vérifier si l'onboarding est complété
    final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
    
    if (!mounted) return;
    
    if (!onboardingCompleted) {
      // Première connexion : afficher onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      // Onboarding complété : aller à l'accueil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[600]!,
              Colors.blue[800]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icone avec effets visuels discrets
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha:0.1),
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Titre
                  const Text(
                    'Arkalia CIA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    kIsWeb
                        ? 'Authentification requise\n(Code PIN)'
                        : _isBiometricAvailable
                            ? 'Authentification requise\n(Empreinte ou code PIN de votre téléphone)'
                            : 'Authentification requise\n(Code PIN de votre téléphone)',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Message d'erreur
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Bouton d'authentification
                  // Toujours afficher le bouton, même si la biométrie n'est pas disponible
                  // Le système proposera automatiquement le PIN du téléphone
                  ElevatedButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(_isBiometricAvailable ? Icons.fingerprint : Icons.lock),
                    label: Text(
                      _isAuthenticating
                          ? 'Authentification...'
                          : kIsWeb
                              ? 'S\'authentifier (code PIN)'
                              : _isBiometricAvailable
                                  ? 'S\'authentifier (empreinte ou PIN)'
                                  : 'S\'authentifier (code PIN)',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

