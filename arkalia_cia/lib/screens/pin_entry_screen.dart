import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/pin_auth_service.dart';

/// Écran de saisie du PIN pour le web
class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final _pinController = TextEditingController();
  bool _isAuthenticating = false;
  String _errorMessage = '';
  int _attempts = 0;
  static const int _maxAttempts = 5;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer votre code PIN';
      });
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final isValid = await PinAuthService.verifyPin(pin).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Timeout après 10 secondes pour éviter les blocages
          return false;
        },
      );

      if (!mounted) {
        setState(() {
          _isAuthenticating = false;
        });
        return;
      }

      if (isValid) {
        // PIN correct, retourner true
        Navigator.of(context).pop(true);
      } else {
        _attempts++;
        setState(() {
          _errorMessage = _attempts >= _maxAttempts
              ? 'Trop de tentatives. Veuillez réessayer plus tard.'
              : 'Code PIN incorrect. Tentatives restantes: ${_maxAttempts - _attempts}';
          _isAuthenticating = false;
          _pinController.clear();
        });

        if (_attempts >= _maxAttempts) {
          // Bloquer temporairement (30 secondes)
          await Future.delayed(const Duration(seconds: 30));
          if (mounted) {
            setState(() {
              _attempts = 0;
              _isAuthenticating = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: $e';
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ne pas afficher sur mobile (on utilise l'authentification biométrique)
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
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
                    const Text(
                      'Entrez votre code PIN',
                      style: TextStyle(
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

                  // Champ PIN
                  TextField(
                    controller: _pinController,
                    decoration: InputDecoration(
                      labelText: 'Code PIN',
                      hintText: 'Entrez votre code PIN',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _authenticate(),
                  ),
                  const SizedBox(height: 32),

                  // Bouton d'authentification
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
                        : const Icon(Icons.lock_open),
                    label: Text(
                      _isAuthenticating ? 'Vérification...' : 'Déverrouiller',
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

