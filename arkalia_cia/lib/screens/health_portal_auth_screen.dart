import 'package:flutter/material.dart';
import '../services/health_portal_auth_service.dart';
import 'onboarding/import_progress_screen.dart';
import 'onboarding/import_type.dart';

class HealthPortalAuthScreen extends StatefulWidget {
  final HealthPortal portal;

  const HealthPortalAuthScreen({super.key, required this.portal});

  @override
  State<HealthPortalAuthScreen> createState() => _HealthPortalAuthScreenState();
}

class _HealthPortalAuthScreenState extends State<HealthPortalAuthScreen> {
  final HealthPortalAuthService _authService = HealthPortalAuthService();
  bool _isAuthenticating = false;
  String? _error;

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });

    try {
      final result = await _authService.authenticatePortal(widget.portal);
      
      if (result['success'] == true) {
        // L'authentification OAuth a été lancée dans le navigateur
        // L'utilisateur sera redirigé vers l'app via deep link avec le code
        // Note: En production, utiliser un listener de deep link pour capturer le callback
        // Pour l'instant, afficher un message d'attente
        
        if (mounted) {
          // Afficher dialogue d'attente
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Authentification en cours'),
              content: const Text(
                'Veuillez compléter l\'authentification dans le navigateur.\n'
                'Vous serez redirigé automatiquement vers l\'application.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isAuthenticating = false;
                    });
                  },
                  child: const Text('Annuler'),
                ),
              ],
            ),
          );
        }
        
        // Note: En production, le callback OAuth sera géré par un listener de deep link
        // qui appellera handleOAuthCallback() puis fetchPortalData()
        // Pour l'instant, simuler avec un délai
        await Future.delayed(const Duration(seconds: 3));
        
        // Vérifier si un token a été sauvegardé (via callback)
        final token = await _authService.getAccessToken(widget.portal);
        if (token != null) {
          // Récupérer les données du portail
          await _authService.fetchPortalData(widget.portal, token);
          
          if (mounted) {
            Navigator.of(context).pop(); // Fermer dialogue d'attente
            // Naviguer vers écran progression import
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ImportProgressScreen(
                  importType: ImportType.portals,
                  portalIds: ['portal_${widget.portal.name}'],
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.of(context).pop(); // Fermer dialogue d'attente
            setState(() {
              _error = 'Authentification non complétée. Veuillez réessayer.';
              _isAuthenticating = false;
            });
          }
        }
      } else {
        setState(() {
          _error = result['error'] ?? 'Erreur lors de l\'authentification';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentification ${HealthPortalAuthService.getPortalName(widget.portal)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Connexion à ${HealthPortalAuthService.getPortalName(widget.portal)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Vous allez être redirigé vers le portail pour vous authentifier.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAuthenticating ? null : _authenticate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isAuthenticating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Se connecter',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

