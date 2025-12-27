import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/pin_auth_service.dart';
import '../services/onboarding_service.dart';
import '../utils/app_logger.dart';
import 'home_page.dart';
import 'onboarding/welcome_screen.dart';
import 'pin_entry_screen.dart';

/// Écran de verrouillage avec authentification PIN (web uniquement)
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Initialise l'authentification
  /// LockScreen s'affiche seulement si authentification activée ET configurée (web uniquement)
  Future<void> _initializeAuth() async {
    AppLogger.debug('LockScreen: Initialisation authentification');
    
    // VÉRIFICATION FINALE : Si l'auth n'est pas vraiment disponible/configurée, aller directement à HomePage
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
        // Pas de PIN configuré sur web : permettre accès direct
        _unlockApp();
        return;
      }
    } else {
      // Sur mobile, authentification désactivée - accès direct
      _unlockApp();
      return;
    }
    
    // Lancer l'authentification au démarrage (web uniquement)
    await _authenticateOnStartup();
  }

  Future<void> _authenticateOnStartup() async {
    // Sur web uniquement, gérer l'authentification PIN
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
      if (!pinConfigured) {
        _unlockApp();
        return;
      }
      
      // PIN configuré, demander l'authentification
      await Future.delayed(const Duration(milliseconds: 500));
      await _authenticate();
      return;
    }
    
    // Sur mobile, authentification désactivée - accès direct
    _unlockApp();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    // Sur web uniquement, utiliser l'écran de saisie PIN
    if (kIsWeb) {
      if (mounted) {
        try {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PinEntryScreen()),
          );
          if (result == true) {
            // PIN correct, déverrouiller l'app
            _unlockApp();
          } else {
            // PIN incorrect ou annulé
            if (mounted) {
              setState(() {
                _errorMessage = '';
              });
            }
          }
        } catch (e) {
          AppLogger.error('Erreur navigation PinEntryScreen', e);
          if (mounted) {
            setState(() {
              _errorMessage = '';
            });
          }
        }
      }
      return;
    }

    // Sur mobile, authentification désactivée - accès direct
    _unlockApp();
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
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
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
                        : 'Authentification désactivée',
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
                  
                  // Bouton d'authentification (web uniquement)
                  if (kIsWeb)
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
                          : const Icon(Icons.lock),
                      label: Text(
                        _isAuthenticating
                            ? 'Authentification...'
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

