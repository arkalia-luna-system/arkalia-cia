import 'dart:async';
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

  // Nouvelle API google_sign_in 7.2.0 : utiliser le singleton
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _initialized = false;

  /// Initialise Google Sign-In (nécessaire pour la version 7.2.0+)
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      clientId:
          kIsWeb
              ? '1062485264410-mc24cenl8rq8qj71enrrp36mibrsep79.apps.googleusercontent.com'
              : null, // Sur mobile, null = détection automatique
    );
    _initialized = true;
  }

  /// Connecte l'utilisateur avec Google
  ///
  /// SIMPLIFIÉ : Gestion d'erreurs améliorée et plus claire
  /// Retourne un Map avec :
  /// - 'success': bool
  /// - 'user': GoogleSignInAccount? (si succès)
  /// - 'error': String? (si erreur)
  static Future<Map<String, dynamic>> signIn() async {
    try {
      await _ensureInitialized();

      // CORRECTION : Essayer d'abord attemptLightweightAuthentication() pour éviter le sélecteur de compte
      // Si l'utilisateur est déjà connecté, on récupère directement le compte
      // Sinon, on utilise authenticate() pour afficher le sélecteur
      GoogleSignInAccount? account;

      try {
        // Essayer d'abord une connexion silencieuse (sans popup)
        // Nouvelle API 7.2.0 : attemptLightweightAuthentication() remplace signInSilently()
        final lightweightResult =
            await _googleSignIn.attemptLightweightAuthentication();
        if (lightweightResult != null) {
          account = lightweightResult;
          AppLogger.info(
            '✅ Connexion Google silencieuse réussie: ${account.email}',
          );
        }
      } catch (e) {
        // attemptLightweightAuthentication() a échoué, on va utiliser authenticate() normalement
        AppLogger.debug(
          'attemptLightweightAuthentication() échoué, utilisation de authenticate(): $e',
        );
      }

      // Si attemptLightweightAuthentication() n'a pas fonctionné, utiliser authenticate() normalement
      // SIMPLIFIÉ : Tentative de connexion avec sélecteur de compte
      // Sur le web, la page de consentement peut rester bloquée, donc on ajoute un timeout
      // Nouvelle API 7.2.0 : authenticate() remplace signIn()
      account ??= await _googleSignIn
          .authenticate(scopeHint: ['email', 'profile'])
          .timeout(
            const Duration(
              minutes: 2,
            ), // Timeout de 2 minutes pour éviter blocage infini
            onTimeout: () {
              AppLogger.warning('Google Sign-In timeout après 2 minutes');
              throw TimeoutException(
                'La connexion Google a pris trop de temps. '
                'Vérifiez votre connexion internet et réessayez.',
                const Duration(minutes: 2),
              );
            },
          );

      // SIMPLIFIÉ : Sauvegarder les informations localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_user_id', account.id);
      // email est non-null selon GoogleSignInAccount
      await prefs.setString('google_user_email', account.email);
      await prefs.setString(
        'google_user_name',
        account.displayName ?? '',
      ); // displayName peut être null
      await prefs.setString('google_user_photo', account.photoUrl ?? '');
      await prefs.setBool('google_signed_in', true);

      return {'success': true, 'user': account, 'error': null};
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
      } else if (errorMessage.contains('403') ||
          errorMessage.contains('PERMISSION_DENIED') ||
          errorMessage.contains('People API') ||
          errorMessage.contains('SERVICE_DISABLED') ||
          errorMessage.contains('people.googleapis.com')) {
        // Erreur People API non activée (403)
        userFriendlyMessage =
            '🔧 Erreur People API non activée (Erreur 403)\n\n'
            '⚠️ L\'API People API n\'est pas activée dans Google Cloud Console.\n\n'
            '📋 ACTION REQUISE (1 minute) :\n\n'
            '1️⃣ Ouvrir ce lien pour activer l\'API :\n'
            '   👉 https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1062485264410\n\n'
            '2️⃣ Cliquer sur "ACTIVER" (bouton bleu)\n\n'
            '3️⃣ Attendre 1-2 minutes puis réessayer\n\n'
            '💡 Alternative : Simplifier les scopes pour ne pas utiliser People API';
      } else if (errorMessage.contains('redirect_uri_mismatch') ||
          errorMessage.contains('redirect') ||
          (errorMessage.contains('400') && kIsWeb)) {
        // Erreur spécifique redirect_uri_mismatch pour le web
        // Sur le web, Flutter utilise automatiquement l'origine de la page comme redirect_uri
        // Il faut donc ajouter exactement cette URI dans Google Cloud Console
        // Détecter l'origine actuelle pour donner des instructions précises
        // Sur web, on peut utiliser l'URL actuelle
        // Note: En production, cela sera https://arkalia-luna-system.github.io/arkalia-cia/
        // (La variable currentOrigin n'est pas utilisée dans le message, donc on la supprime)

        userFriendlyMessage =
            '🔧 Erreur redirect_uri_mismatch (Erreur 400)\n\n'
            '⚠️ Les URI de redirection ne sont pas configurées OU pas encore propagées.\n\n'
            '📋 VÉRIFICATION (2 minutes) :\n\n'
            '1️⃣ Ouvrir Google Cloud Console :\n'
            '   👉 https://console.cloud.google.com/apis/credentials?project=arkalia-cia\n\n'
            '2️⃣ Cliquer sur "Client Web 1"\n\n'
            '3️⃣ Vérifier "Origines JavaScript autorisées" contient :\n'
            '   ✅ http://localhost:8080\n'
            '   ✅ https://arkalia-luna-system.github.io\n\n'
            '4️⃣ Vérifier "URIs de redirection autorisées" contient :\n'
            '   ✅ http://localhost:8080\n'
            '   ✅ http://localhost:8080/\n'
            '   ✅ https://arkalia-luna-system.github.io/arkalia-cia/\n'
            '   ✅ https://arkalia-luna-system.github.io/arkalia-cia\n\n'
            '5️⃣ Si manquant, ajouter puis "ENREGISTRER"\n\n'
            '6️⃣ ⏰ ATTENDRE 5-10 minutes (propagation Google)\n\n'
            '7️⃣ Vider le cache navigateur (Cmd+Shift+Delete) puis réessayer\n\n'
            '💡 Si vous venez de configurer, attendez encore quelques minutes.\n'
            '   La propagation Google peut prendre jusqu\'à 10 minutes.\n\n'
            '📖 Guide détaillé : docs/guides/FIX_REDIRECT_URI_MISMATCH.md';
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
        final messageMatch = RegExp(
          r'message:\s*([^,}]+)',
        ).firstMatch(errorMessage);
        final code = codeMatch?.group(1)?.trim() ?? 'UNKNOWN';
        final message = messageMatch?.group(1)?.trim() ?? errorMessage;

        userFriendlyMessage = 'Erreur Google Sign-In\nCode: $code\n$message';
      } else {
        userFriendlyMessage = 'Erreur lors de la connexion\n${e.toString()}';
      }

      return {'success': false, 'error': userFriendlyMessage, 'user': null};
    }
  }

  /// Déconnecte l'utilisateur de Google
  static Future<void> signOut() async {
    try {
      await _ensureInitialized();
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
  ///
  /// Mode web : Évite signInSilently() au démarrage pour éviter erreurs WebSocket
  /// Utilise uniquement SharedPreferences pour une vérification rapide
  static Future<bool> isSignedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSignedIn = prefs.getBool('google_signed_in') ?? false;

      // Sur web, éviter signInSilently() au démarrage car Flutter peut ne pas être prêt
      // On vérifie uniquement SharedPreferences pour une réponse rapide
      // La vérification réelle avec Google sera faite plus tard si nécessaire
      if (kIsWeb) {
        return isSignedIn;
      }

      // Sur mobile, on peut vérifier avec Google Sign In
      if (isSignedIn) {
        try {
          await _ensureInitialized();
          // Nouvelle API 7.2.0 : attemptLightweightAuthentication() remplace signInSilently()
          final account =
              await _googleSignIn.attemptLightweightAuthentication();
          if (account == null) {
            // L'utilisateur n'est plus connecté, mettre à jour les préférences
            await prefs.setBool('google_signed_in', false);
            return false;
          }
          return true;
        } catch (e) {
          // En cas d'erreur, on assume que l'utilisateur est connecté (basé sur SharedPreferences)
          // Cela évite de déconnecter l'utilisateur en cas d'erreur réseau temporaire
          AppLogger.debug(
            'GoogleAuthService.isSignedIn: Erreur attemptLightweightAuthentication, utilisation SharedPreferences: $e',
          );
          return isSignedIn;
        }
      }
      return false;
    } catch (e) {
      AppLogger.debug('GoogleAuthService.isSignedIn: Erreur, retour false: $e');
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
      await _ensureInitialized();
      // Nouvelle API 7.2.0 : attemptLightweightAuthentication() remplace signInSilently()
      return await _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      return null;
    }
  }
}
