import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion de la connexion ARIA
class ARIAService {
  static const String _ariaIpKey = 'aria_server_ip';
  static const String _ariaPortKey = 'aria_server_port';
  static const String _defaultPort = '8080';

  /// Récupère l'IP du serveur ARIA depuis les préférences
  static Future<String?> getARIAIP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ariaIpKey);
  }

  /// Définit l'IP du serveur ARIA
  static Future<void> setARIAIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ariaIpKey, ip);
  }

  /// Récupère le port du serveur ARIA
  static Future<String> getARIAPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ariaPortKey) ?? _defaultPort;
  }

  /// Définit le port du serveur ARIA
  static Future<void> setARIAPort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ariaPortKey, port);
  }

  /// Construit l'URL de base ARIA
  /// Supporte les URLs complètes (https://xxx.onrender.com) et les IPs locales
  static Future<String?> getBaseURL() async {
    final ip = await getARIAIP();
    if (ip == null || ip.isEmpty) return null;
    final port = await getARIAPort();
    
    // Si c'est déjà une URL complète (http:// ou https://), la retourner telle quelle
    if (ip.startsWith('http://') || ip.startsWith('https://')) {
      return ip;
    }
    
    // Si le port est 443, utiliser HTTPS (pour les services hébergés)
    if (port == '443') {
      return 'https://$ip';
    }
    
    // Si le port est 80, utiliser HTTP sans port
    if (port == '80') {
      return 'http://$ip';
    }
    
    // Sinon, utiliser HTTP avec port (pour les services locaux)
    return 'http://$ip:$port';
  }

  /// Vérifie si ARIA est connecté et accessible
  static Future<bool> checkConnection() async {
    try {
      final baseUrl = await getBaseURL();
      if (baseUrl == null) return false;

      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Construit l'URL pour une page spécifique d'ARIA
  static Future<String?> getPageURL(String page) async {
    final baseUrl = await getBaseURL();
    if (baseUrl == null) return null;

    switch (page) {
      case 'quick-entry':
        return '$baseUrl/#/quick-entry';
      case 'history':
        return '$baseUrl/#/history';
      case 'patterns':
        return '$baseUrl/#/patterns';
      case 'export':
        return '$baseUrl/#/export';
      default:
        return baseUrl;
    }
  }

  /// Détecte automatiquement le serveur ARIA sur le réseau local
  static Future<String?> detectARIA() async {
    // Tentative de détection sur les IPs communes du réseau local
    final commonIPs = [
      '192.168.1.100',
      '192.168.1.1',
      '192.168.0.100',
      '192.168.0.1',
      '10.0.0.100',
      'localhost',
      '127.0.0.1',
    ];

    for (final ip in commonIPs) {
      try {
        final url = 'http://$ip:$_defaultPort';
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          await setARIAIP(ip);
          return ip;
        }
      } catch (e) {
        // Continuer avec la prochaine IP
      }
    }

    return null;
  }
}

