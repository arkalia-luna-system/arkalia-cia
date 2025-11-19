import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

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
    _checkBiometricAvailability();
    _authenticateOnStartup();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await AuthService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = available;
    });
  }

  Future<void> _authenticateOnStartup() async {
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
    
    // Si la biométrie n'est pas disponible, permettre l'accès direct
    if (!_isBiometricAvailable) {
      _unlockApp();
      return;
    }
    
    // Authentification requise et disponible
    await Future.delayed(const Duration(milliseconds: 500));
    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

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

  void _unlockApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
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
                  // Logo/Icone
                  const Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.white,
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
                    _isBiometricAvailable
                        ? 'Authentification biométrique requise'
                        : 'App verrouillée',
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
                  if (_isBiometricAvailable)
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
                          : const Icon(Icons.fingerprint),
                      label: Text(
                        _isAuthenticating
                            ? 'Authentification...'
                            : 'S\'authentifier',
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
                    )
                  else
                    ElevatedButton(
                      onPressed: _unlockApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        'Accéder sans biométrie',
                        style: TextStyle(fontSize: 18),
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

