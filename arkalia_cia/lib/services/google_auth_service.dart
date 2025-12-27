import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service d'authentification Google pour Arkalia CIA
/// 
/// **Mode gratuit et offline-first** :
/// - Utilise Google Sign In pour authentifier l'utilisateur
/// - Stocke les informations localement (email, nom, photo)
/// - Aucun backend requis, 100% gratuit
/// - Les données restent sur l'appareil
class GoogleAuthService {
  // Configuration Google Sign-In avec clientId pour le web
  // Sur mobile : utilise automatiquement la config Google Cloud Console via package name et SHA-1
  // Sur web : nécessite le clientId explicite
  // 
  // ⚠️ IMPORTANT pour le web : Les URI de redirection doivent être configurées dans Google Cloud Console
  // Aller dans : https://console.cloud.google.com/apis/credentials?project=arkalia-cia
  // Cliquer sur "Client Web 1" > "URIs de redirection autorisées" > Ajouter :
  //   - http://localhost:8080
  //   - http://localhost:8080/
  //   - http://localhost:8081 (si port alternatif)
  //   - https://votre-domaine.com (pour production)
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Client ID Web pour le web (nécessaire sur web)
    // Client ID: 1062485264410-mc24cenl8rq8qj71enrrp36mibrsep79.apps.googleusercontent.com
    clientId: kIsWeb 
        ? '1062485264410-mc24cenl8rq8qj71enrrp36mibrsep79.apps.googleusercontent.com'
        : null, // Sur mobile, null = détection automatique
  );

  /// Connecte l'utilisateur avec Google
  /// 
  /// SIMPLIFIÉ : Gestion d'erreurs améliorée et plus claire
  /// Retourne un Map avec :
  /// - 'success': bool
  /// - 'user': GoogleSignInAccount? (si succès)
  /// - 'error': String? (si erreur)
  static Future<Map<String, dynamic>> signIn() async {
    try {
      // SIMPLIFIÉ : Tentative de connexion directe
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        // L'utilisateur a annulé la connexion (pas une erreur)
        return {
          'success': false,
          'error': 'Connexion annulée',
          'user': null,
        };
      }

      // SIMPLIFIÉ : Sauvegarder les informations localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_user_id', account.id);
      await prefs.setString('google_user_email', account.email);
      await prefs.setString('google_user_name', account.displayName ?? '');
      await prefs.setString('google_user_photo', account.photoUrl ?? '');
      await prefs.setBool('google_signed_in', true);

      return {
        'success': true,
        'user': account,
        'error': null,
      };
    } catch (e, stackTrace) {
      // Log détaillé pour débogage
      AppLogger.error('Erreur Google Sign-In', e, stackTrace);
      
      // SIMPLIFIÉ : Messages d'erreur plus clairs et actionnables
      final errorMessage = e.toString();
      String userFriendlyMessage;
      
      if (errorMessage.contains('DEVELOPER_ERROR') ||
          errorMessage.contains('10:') ||
          errorMessage.contains('not registered') ||
          errorMessage.contains('OAuth2.0') ||
          errorMessage.contains('configuration') ||
          errorMessage.contains('SignInException')) {
        userFriendlyMessage = 
            '⚠️ Configuration Google Sign-In manquante.\n\n'
            'Vérifiez dans Google Cloud Console :\n'
            '1. Package name : com.arkalia.cia\n'
            '2. SHA-1 Debug : 2C:68:D5:C0:92:A8:7F:59:E7:6A:7C:5B:7C:F9:77:54:9E:68:14:6E\n\n'
            'URL : https://console.cloud.google.com/apis/credentials?project=arkalia-cia';
      } else if (errorMessage.contains('redirect_uri_mismatch') ||
                 errorMessage.contains('redirect') ||
                 errorMessage.contains('400')) {
        // Erreur spécifique redirect_uri_mismatch pour le web
        userFriendlyMessage = 
            '🔧 Erreur redirect_uri_mismatch (Erreur 400)\n\n'
            '⚠️ Les URI de redirection ne sont pas configurées dans Google Cloud Console.\n\n'
            '📋 ACTION REQUISE :\n'
            '1. Aller sur : https://console.cloud.google.com/apis/credentials?project=arkalia-cia\n'
            '2. Cliquer sur "Client Web 1"\n'
            '3. Dans "URIs de redirection autorisées", ajouter :\n'
            '   • http://localhost:8080\n'
            '   • http://localhost:8080/\n'
            '4. Cliquer sur "ENREGISTRER"\n'
            '5. Attendre 1-2 minutes puis réessayer\n\n'
            '📖 Guide complet : docs/guides/FIX_REDIRECT_URI_MISMATCH.md';
      } else if (errorMessage.contains('NETWORK_ERROR') ||
                 errorMessage.contains('7:') ||
                 errorMessage.contains('network') ||
                 errorMessage.contains('SocketException') ||
                 errorMessage.contains('timeout')) {
        userFriendlyMessage = 
            '🌐 Erreur de connexion réseau.\n\n'
            'Vérifiez votre connexion internet et réessayez.';
      } else if (errorMessage.contains('SIGN_IN_CANCELLED') ||
                 errorMessage.contains('12501') ||
                 errorMessage.contains('cancelled')) {
        userFriendlyMessage = 'Connexion annulée';
      } else if (errorMessage.contains('PlatformException')) {
        // Extraire le code d'erreur de PlatformException
        final codeMatch = RegExp(r'code:\s*([^,]+)').firstMatch(errorMessage);
        final messageMatch = RegExp(r'message:\s*([^,}]+)').firstMatch(errorMessage);
        final code = codeMatch?.group(1)?.trim() ?? 'UNKNOWN';
        final message = messageMatch?.group(1)?.trim() ?? errorMessage;
        
        userFriendlyMessage = 'Erreur Google Sign-In\nCode: $code\n$message';
      } else {
        userFriendlyMessage = 'Erreur lors de la connexion\n${e.toString()}';
      }
      
      return {
        'success': false,
        'error': userFriendlyMessage,
        'user': null,
      };
    }
  }

  /// Déconnecte l'utilisateur de Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('google_user_id');
      await prefs.remove('google_user_email');
      await prefs.remove('google_user_name');
      await prefs.remove('google_user_photo');
      await prefs.setBool('google_signed_in', false);
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  /// Vérifie si l'utilisateur est connecté avec Google
  static Future<bool> isSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSignedIn = prefs.getBool('google_signed_in') ?? false;
      
      // Vérifier aussi avec Google Sign In
      if (isSignedIn) {
        final account = await _googleSignIn.signInSilently();
        if (account == null) {
          // L'utilisateur n'est plus connecté, mettre à jour les préférences
          await prefs.setBool('google_signed_in', false);
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Récupère les informations de l'utilisateur connecté
  static Future<Map<String, String>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSignedIn = prefs.getBool('google_signed_in') ?? false;
      
      if (!isSignedIn) {
        return null;
      }

      return {
        'id': prefs.getString('google_user_id') ?? '',
        'email': prefs.getString('google_user_email') ?? '',
        'name': prefs.getString('google_user_name') ?? '',
        'photo': prefs.getString('google_user_photo') ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  /// Récupère le compte Google actuel (pour accès aux tokens si nécessaire)
  static Future<GoogleSignInAccount?> getCurrentAccount() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      return null;
    }
  }
}

