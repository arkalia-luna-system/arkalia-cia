import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../home_page.dart';
import '../onboarding/welcome_screen.dart';
import '../../services/google_auth_service.dart';
import '../../services/onboarding_service.dart';
import '../../services/backend_config_service.dart';

/// Écran d'accueil pour l'authentification
/// Propose plusieurs options : Gmail/Google, créer un compte, ou continuer sans compte
class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _backendEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
    _checkBackendStatus();
  }
  
  /// SIMPLIFIÉ : Vérifier si backend est configuré pour afficher/masquer Login/Register
  Future<void> _checkBackendStatus() async {
    final enabled = await BackendConfigService.isBackendEnabled();
    if (mounted) {
      setState(() {
        _backendEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// SIMPLIFIÉ : Mode offline - aller directement à HomePage
  /// LockScreen s'affichera automatiquement au prochain démarrage si authentification activée
  Future<void> _handleContinueWithoutAccount(BuildContext context) async {
    if (!context.mounted) return;
    
    // Vérifier l'onboarding
    final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
    
    if (!context.mounted) return;
    
    if (!onboardingCompleted) {
      // Première connexion : afficher onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      // Onboarding complété : aller directement à l'accueil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  /// Gestion de la connexion Google Sign In
  /// 
  /// **Mode gratuit et offline-first** :
  /// - Utilise Google Sign In pour authentifier l'utilisateur
  /// - Stocke les informations localement (email, nom, photo)
  /// - Aucun backend requis, 100% gratuit
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (!context.mounted) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final result = await GoogleAuthService.signIn();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fermer le dialog de chargement

      if (result['success'] == true) {
        // SIMPLIFIÉ : Connexion réussie, aller directement à HomePage
        // LockScreen s'affichera automatiquement au prochain démarrage si authentification activée
        if (!context.mounted) return;
        
        // Vérifier l'onboarding
        final onboardingCompleted = await OnboardingService.isOnboardingCompleted();
        
        if (!context.mounted) return;
        
        if (!onboardingCompleted) {
          // Première connexion : afficher onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        } else {
          // Onboarding complété : aller directement à l'accueil
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // SIMPLIFIÉ : Afficher l'erreur seulement si ce n'est pas une annulation
        if (result['error'] != 'Connexion annulée' && context.mounted) {
          // Afficher un dialog avec l'erreur détaillée et actionnable
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Erreur de connexion Google'),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  result['error'] ?? 'Erreur lors de la connexion',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
                if (result['error']?.contains('Configuration') == true ||
                    result['error']?.contains('not registered') == true)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Optionnel : ouvrir l'URL Google Cloud Console
                    },
                    child: const Text('Voir la config'),
                  ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.blue[900]!,
                    Colors.blue[800]!,
                    Colors.purple[900]!,
                  ]
                : [
                    Colors.blue[400]!,
                    Colors.blue[600]!,
                    Colors.purple[500]!,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo/Icone avec effets visuels discrets et animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: -2,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback si l'image ne se charge pas
                            return Icon(
                              Icons.health_and_safety,
                              size: 80,
                              color: Colors.blue[800],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Titre
                  const Text(
                    'Arkalia CIA',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Sous-titre
                  const Text(
                    'Votre Carnet de Santé',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Bouton Google (unique, fonctionne avec Gmail aussi)
                  ElevatedButton.icon(
                    onPressed: () => _handleGoogleSignIn(context),
                    icon: const Icon(Icons.account_circle, size: 24),
                    label: const Text(
                      'Continuer avec Google',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                  
                  // SIMPLIFIÉ : Afficher Login/Register seulement si backend configuré
                  if (_backendEnabled) ...[
                    const SizedBox(height: 24),
                    
                    // Séparateur
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton Créer un compte (seulement si backend configuré)
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CRÉER UN COMPTE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bouton Se connecter (seulement si backend configuré)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'J\'ai déjà un compte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Message informatif si backend non configuré
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pour créer un compte avec backend, configurez l\'URL dans les paramètres (⚙️ > Backend API)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Bouton Continuer sans compte (discret)
                  TextButton(
                    onPressed: () => _handleContinueWithoutAccount(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white60,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Continuer sans compte',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

