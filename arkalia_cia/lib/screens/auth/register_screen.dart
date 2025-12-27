import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/auth_api_service.dart';
import '../../services/backend_config_service.dart';
import '../../services/onboarding_service.dart';
import '../../utils/app_logger.dart';
import 'login_screen.dart';
import '../onboarding/welcome_screen.dart';
import '../home_page.dart';

/// Écran d'inscription pour créer un compte utilisateur
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // SIMPLIFIÉ : Backend optionnel - suggérer Google Sign-In si non configuré
      final backendConfigured = await BackendConfigService.isBackendEnabled();
      if (!backendConfigured) {
        setState(() {
          _errorMessage = '⚙️ Backend non configuré.\n\n'
              'Pour créer un compte avec backend, configurez l\'URL dans les paramètres (⚙️ > Backend API).\n\n'
              '💡 Alternative : Utilisez "Continuer avec Google" sur l\'écran précédent pour vous connecter sans backend.';
          _isLoading = false;
        });
        return;
      }
      
      // Vérifier que l'URL du backend est valide (seulement si backend activé)
      final backendUrl = await BackendConfigService.getBackendURL();
      if (backendUrl.isEmpty || (backendUrl.contains('localhost') && !kIsWeb) || backendUrl.contains('127.0.0.1')) {
        setState(() {
          _errorMessage = '⚙️ URL du backend invalide.\n\n'
              'L\'URL du backend doit être une adresse valide.\n\n'
              '💡 Alternative : Utilisez "Continuer avec Google" pour vous connecter sans backend.';
          _isLoading = false;
        });
        return;
      }

      final result = await AuthApiService.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      if (result['success'] == true) {
        if (!mounted) return;
        
        setState(() {
          _successMessage = 'Compte créé avec succès ! Connexion automatique...';
          _isLoading = false;
        });

        // S'assurer qu'aucune session précédente n'est active
        await AuthApiService.logout();
        
        // Se connecter automatiquement après inscription
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        
        final loginResult = await AuthApiService.login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
        
        if (!mounted) return;
        
        if (loginResult['success'] == true) {
          // Vérifier que la session est bien active
          final isLoggedIn = await AuthApiService.isLoggedIn();
          if (!isLoggedIn) {
            if (mounted) {
              setState(() {
                _errorMessage = 'Erreur lors de la connexion automatique. Veuillez vous connecter manuellement.';
                _isLoading = false;
              });
            }
            return;
          }
          
          // Vérifier l'onboarding
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
        } else {
          // Échec connexion automatique, rediriger vers login avec message
          if (mounted) {
            setState(() {
              _errorMessage = loginResult['error'] ?? 'Erreur lors de la connexion automatique. Veuillez vous connecter manuellement.';
              _isLoading = false;
            });
            // Ne pas rediriger immédiatement, laisser l'utilisateur voir l'erreur
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Erreur lors de l\'inscription';
          _isLoading = false;
        });
      }
    } catch (e) {
      // SIMPLIFIÉ : Messages d'erreur plus précis et actionnables
      final errorString = e.toString().toLowerCase();
      String errorMsg;
      
      if (errorString.contains('timeout') || errorString.contains('timed out')) {
        errorMsg = '⏱️ Le serveur met trop de temps à répondre.\n\n'
            'Vérifiez votre connexion internet et réessayez.';
      } else if (errorString.contains('connection refused') || 
                 errorString.contains('failed host lookup') ||
                 errorString.contains('network')) {
        errorMsg = '🌐 Problème de connexion réseau.\n\n'
            'Vérifiez votre connexion internet et que le backend est accessible.';
      } else if (errorString.contains('backend non configuré') ||
                 errorString.contains('url')) {
        errorMsg = '⚙️ Backend non configuré.\n\n'
            'Veuillez configurer l\'URL du backend dans les paramètres de l\'application.';
      } else {
        // Afficher l'erreur réelle pour débogage
        errorMsg = '❌ Erreur lors de l\'inscription.\n\n'
            'Détails: ${e.toString()}';
      }
      
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
      
      // Log pour débogage
      AppLogger.error('Erreur inscription', e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo ou icône
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Créer un compte',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Inscrivez-vous pour accéder à Arkalia CIA',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Message de succès
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Message d'erreur
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Champ nom d'utilisateur
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur *',
                    hintText: 'Choisissez un nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le nom d\'utilisateur est requis';
                    }
                    if (value.trim().length < 3) {
                      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                    }
                    if (value.trim().length > 50) {
                      return 'Le nom d\'utilisateur ne peut pas dépasser 50 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ email (optionnel mais recommandé pour récupération)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (recommandé)',
                    hintText: 'votre@email.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    helperText: 'Permet la récupération de compte si vous oubliez votre mot de passe',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Format d\'email invalide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe *',
                    hintText: 'Au moins 8 caractères',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est requis';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe *',
                    hintText: 'Répétez votre mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La confirmation du mot de passe est requise';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Bouton d'inscription
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Créer le compte',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Lien vers connexion
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

