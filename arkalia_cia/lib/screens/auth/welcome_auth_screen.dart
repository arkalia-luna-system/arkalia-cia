import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../lock_screen.dart';

/// Écran d'accueil pour l'authentification
/// Propose plusieurs options : Gmail/Google, créer un compte, ou continuer sans compte
class WelcomeAuthScreen extends StatelessWidget {
  const WelcomeAuthScreen({super.key});

  Future<void> _handleContinueWithoutAccount(BuildContext context) async {
    // Mode offline : aller directement à LockScreen (qui proposera PIN si nécessaire)
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LockScreen()),
      );
    }
  }

  /// Gestion de la connexion Google Sign In
  /// 
  /// **Fonctionnalité future** : Implémentation prévue avec `google_sign_in` package
  /// - Nécessite configuration OAuth dans Google Cloud Console
  /// - Intégration avec backend pour authentification JWT
  /// 
  /// Pour l'instant, affiche un message informatif à l'utilisateur
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion Google - Bientôt disponible !'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Gestion de la connexion Gmail Sign In
  /// 
  /// **Fonctionnalité future** : Implémentation prévue avec `google_sign_in` package
  /// - Nécessite configuration OAuth dans Google Cloud Console
  /// - Intégration avec backend pour authentification JWT
  /// 
  /// Pour l'instant, affiche un message informatif à l'utilisateur
  Future<void> _handleGmailSignIn(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion Gmail - Bientôt disponible !'),
          duration: Duration(seconds: 2),
        ),
      );
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
                  
                  // Logo/Icone
                  Icon(
                    Icons.health_and_safety,
                    size: 100,
                    color: Colors.white,
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
                  
                  // Bouton Gmail (prioritaire, bien visible)
                  ElevatedButton.icon(
                    onPressed: () => _handleGmailSignIn(context),
                    icon: const Icon(Icons.email, size: 24),
                    label: const Text(
                      'Continuer avec Gmail',
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
                  
                  const SizedBox(height: 12),
                  
                  // Bouton Google
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
                  
                  const SizedBox(height: 24),
                  
                  // Séparateur
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Bouton Créer un compte
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
                  
                  // Bouton Se connecter (plus petit, moins visible)
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

