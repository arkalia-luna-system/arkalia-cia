import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service d'authentification Google pour Arkalia CIA
/// 
/// **Mode gratuit et offline-first** :
/// - Utilise Google Sign In pour authentifier l'utilisateur
/// - Stocke les informations localement (email, nom, photo)
/// - Aucun backend requis, 100% gratuit
/// - Les données restent sur l'appareil
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Connecte l'utilisateur avec Google
  /// 
  /// Retourne un Map avec :
  /// - 'success': bool
  /// - 'user': GoogleSignInAccount? (si succès)
  /// - 'error': String? (si erreur)
  static Future<Map<String, dynamic>> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        // L'utilisateur a annulé la connexion
        return {
          'success': false,
          'error': 'Connexion annulée',
          'user': null,
        };
      }

      // Sauvegarder les informations de l'utilisateur localement
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
    } catch (e) {
      // Gestion d'erreurs spécifiques pour messages utilisateur clairs
      final errorMessage = e.toString();
      String userFriendlyMessage;
      
      if (errorMessage.contains('DEVELOPER_ERROR') ||
          errorMessage.contains('10:') ||
          errorMessage.contains('configuration')) {
        userFriendlyMessage = 
            'Erreur de configuration. Vérifiez que le SHA-1 est correctement '
            'configuré dans Google Cloud Console.';
      } else if (errorMessage.contains('NETWORK_ERROR') ||
                 errorMessage.contains('7:') ||
                 errorMessage.contains('network')) {
        userFriendlyMessage = 
            'Erreur de connexion réseau. Vérifiez votre connexion internet.';
      } else if (errorMessage.contains('SIGN_IN_CANCELLED') ||
                 errorMessage.contains('12501') ||
                 errorMessage.contains('cancelled')) {
        userFriendlyMessage = 'Connexion annulée';
      } else {
        userFriendlyMessage = 'Erreur lors de la connexion: ${e.toString()}';
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

