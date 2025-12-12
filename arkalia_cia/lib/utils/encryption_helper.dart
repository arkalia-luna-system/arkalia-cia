import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Helper pour le chiffrement AES-256 des données sensibles
class EncryptionHelper {
  static const String _keyStorageKey = 'encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Lit la clé depuis le stockage sécurisé ou SharedPreferences (fallback)
  static Future<String?> _readKey() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyStorageKey);
    } else {
      try {
        return await _secureStorage.read(key: _keyStorageKey);
      } on MissingPluginException {
        // Fallback vers SharedPreferences si flutter_secure_storage n'est pas disponible
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_keyStorageKey);
      } catch (e) {
        // Autre erreur, fallback vers SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_keyStorageKey);
      }
    }
  }

  /// Écrit la clé dans le stockage sécurisé ou SharedPreferences (fallback)
  static Future<void> _writeKey(String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStorageKey, value);
    } else {
      try {
        await _secureStorage.write(key: _keyStorageKey, value: value);
      } on MissingPluginException {
        // Fallback vers SharedPreferences si flutter_secure_storage n'est pas disponible
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyStorageKey, value);
      } catch (e) {
        // Autre erreur, fallback vers SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyStorageKey, value);
      }
    }
  }

  /// Génère ou récupère la clé de chiffrement
  static Future<encrypt.Key> _getEncryptionKey() async {
    try {
      // Essayer de récupérer la clé depuis le stockage sécurisé
      String? keyString = await _readKey();

      if (keyString == null || keyString.isEmpty) {
        // Générer une nouvelle clé
        final key = encrypt.Key.fromSecureRandom(32); // 256 bits
        await _writeKey(key.base64);
        return key;
      }

      return encrypt.Key.fromBase64(keyString);
    } catch (e) {
      // En cas d'erreur, générer une nouvelle clé
      final key = encrypt.Key.fromSecureRandom(32);
      await _writeKey(key.base64);
      return key;
    }
  }

  /// Chiffre une chaîne de caractères
  static Future<String> encryptString(String plainText) async {
    try {
      final key = await _getEncryptionKey();
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Retourner IV + données chiffrées en base64
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      throw Exception('Erreur lors du chiffrement: $e');
    }
  }

  /// Déchiffre une chaîne de caractères
  static Future<String> decryptString(String encryptedText) async {
    try {
      final key = await _getEncryptionKey();
      final parts = encryptedText.split(':');
      
      if (parts.length != 2) {
        throw Exception('Format de données chiffrées invalide');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Erreur lors du déchiffrement: $e');
    }
  }

  /// Chiffre un objet Map avant stockage
  static Future<String> encryptMap(Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    return await encryptString(jsonString);
  }

  /// Déchiffre un objet Map après récupération
  static Future<Map<String, dynamic>> decryptMap(String encryptedData) async {
    final jsonString = await decryptString(encryptedData);
    return Map<String, dynamic>.from(json.decode(jsonString));
  }

  /// Génère un hash SHA-256 pour vérification d'intégrité
  static String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

